import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'; // WidgetsBindingObserver
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/utils/linux_parser.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/features/dashboard/models/ssh_connection_state.dart';
import 'package:orbit/features/dashboard/repositories/server_repository.dart';
import 'package:orbit/core/services/isar_service.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/providers/server_loading_provider.dart';
import 'package:orbit/core/services/geolocation_service.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Constants
// ──────────────────────────────────────────────────────────────────────────────

/// Hard limit for every SSH operation (connect + run). If exceeded the
/// operation is cancelled and the reconnect loop fires.
const Duration _kSshTimeout = Duration(seconds: 10);

/// Exponential-backoff delays for the reconnect loop (capped at last value).
const List<int> _kReconnectDelays = [3, 5, 10, 20, 30];

// ──────────────────────────────────────────────────────────────────────────────
// ViewModel
// ──────────────────────────────────────────────────────────────────────────────

/// Manages persistent SSH connections, background polling, connectivity
/// monitoring, and automatic session recovery.
///
/// Edge-cases handled:
/// - App going to background (via [WidgetsBindingObserver]): sessions paused.
/// - App returning to foreground: all sessions resumed.
/// - Device network lost/restored (via connectivity_plus): sessions paused/resumed.
/// - SSH hang / timeout: 10-second hard cap on every SSH operation.
/// - Race conditions: per-server `_isConnecting` mutex prevents duplicate conns.
/// - Zombie sockets: every failure path explicitly closes the SSH client.
class ServerMonitorViewModel extends AsyncNotifier<void>
    with WidgetsBindingObserver {
  // ── SSH state (per server) ─────────────────────────────────────────────
  final Map<String, SSHClient> _sshClients = {};
  final Map<String, Timer> _pollingTimers = {};
  final Map<String, _CpuState> _cpuStates = {};
  final Map<String, List<ServerStats>> _serverHistories = {};
  final Map<String, SshConnectionState> _connectionStates = {};

  // ── Concurrency guards ─────────────────────────────────────────────────
  /// [Fix 3] Mutex – prevents duplicate SSH connect attempts per server.
  final Map<String, bool> _isConnecting = {};

  /// Prevents duplicate reconnect loops per server.
  final Map<String, bool> _reconnectInProgress = {};

  // ── Network / lifecycle ────────────────────────────────────────────────
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isNetworkAvailable = true;

  /// Tracks whether the app is visible; set via [didChangeAppLifecycleState].
  bool _isAppInForeground = true;

  // ── Shared services ────────────────────────────────────────────────────
  late ServerRepository _repository;
  late dynamic _sshService;
  late ServerLoadingNotifier _loadingNotifier;

  static const int _maxHistoryPoints = 60;
  int _pollIntervalSeconds = 3;

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Future<void> build() async {
    final isar = await ref.watch(isarProvider.future);
    _repository = ServerRepository(isar);
    _sshService = ref.watch(sshServiceProvider);
    _loadingNotifier = ref.read(serverLoadingProvider.notifier);

    // Dynamic poll interval
    ref.listen<int>(pollIntervalProvider, (previous, next) {
      if (previous != next) {
        _pollIntervalSeconds = next;
        _restartAllTimers();
      }
    });
    _pollIntervalSeconds = ref.read(pollIntervalProvider);

    // [Fix 1] Register app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Network monitoring
    await _initConnectivityMonitoring();

    // Auto-start for all existing servers
    final servers = await _repository.watchAllServers().first;
    for (final server in servers) {
      await startMonitoring(server.id);
    }

    ref.onDispose(() {
      // [Fix 1] Deregister observer
      WidgetsBinding.instance.removeObserver(this);
      _connectivitySub?.cancel();
      stopAllMonitoring();
    });
  }

  // ── App Lifecycle Observer [Fix 1] ─────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (_isAppInForeground) {
          _isAppInForeground = false;
          debugPrint('ServerMonitor: App → background — suspending sessions');
          _suspendAllSessions();
        }
      case AppLifecycleState.resumed:
        if (!_isAppInForeground) {
          _isAppInForeground = true;
          debugPrint('ServerMonitor: App → foreground — resuming sessions');
          _resumeAllSessions();
        }
      case AppLifecycleState.inactive:
        // Nothing — transient state (e.g., during phone call)
        break;
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────

  List<ServerStats> getHistory(String serverId) =>
      _serverHistories[serverId] ?? [];

  SshConnectionState getConnectionState(String serverId) =>
      _connectionStates[serverId] ?? SshConnectionState.connecting;

  Future<void> startMonitoring(String serverId) async {
    if (_pollingTimers.containsKey(serverId)) return;

    _serverHistories.putIfAbsent(serverId, () => []);
    _setConnectionState(serverId, SshConnectionState.connecting);
    _loadingNotifier.startLoading(serverId);

    debugPrint('ServerMonitor: Starting monitoring for $serverId');
    await _connectAndStartPolling(serverId);
  }

  Future<void> stopMonitoring(String serverId) async {
    _pollingTimers[serverId]?.cancel();
    _pollingTimers.remove(serverId);
    _isConnecting.remove(serverId);
    _reconnectInProgress.remove(serverId);
    _closeClient(serverId); // [Fix 4] Always dispose socket
    _cpuStates.remove(serverId);
    _serverHistories.remove(serverId);
    _connectionStates.remove(serverId);
  }

  Future<void> stopAllMonitoring() async {
    for (final id in List<String>.from(_connectionStates.keys)) {
      await stopMonitoring(id);
    }
  }

  /// Tears down the existing SSH session for [serverId] and re-initiates a
  /// fresh connection using the latest credentials from the database.
  ///
  /// Call this immediately after an "Edit Server" save so that a stale
  /// SSH client is never used with invalid or outdated credentials.
  Future<void> reinitializeServer(String serverId) async {
    debugPrint('ServerMonitor: Reinitializing server $serverId after edit');

    // 1. Cancel any in-flight polling timer.
    _pollingTimers[serverId]?.cancel();
    _pollingTimers.remove(serverId);

    // 2. Close the stale SSH client.
    _closeClient(serverId);

    // 3. Release all concurrency guards so the fresh connect can proceed.
    _isConnecting[serverId] = false;
    _reconnectInProgress[serverId] = false;

    // 4. Reset CPU delta — the old state references the wrong session.
    _cpuStates.remove(serverId);

    // 5. Keep the server tracked but transition to connecting state.
    _connectionStates[serverId] = SshConnectionState.connecting;
    _loadingNotifier.startLoading(serverId);
    state = const AsyncValue.data(null);

    // 6. Kick off a new connection with fresh credentials from the DB.
    await _connectAndStartPolling(serverId);
  }

  // ── Lifecycle helpers ──────────────────────────────────────────────────

  /// Pauses all active sessions without removing servers from tracking.
  void _suspendAllSessions() {
    for (final id in List<String>.from(_connectionStates.keys)) {
      _pollingTimers[id]?.cancel();
      _pollingTimers.remove(id);
      _closeClient(id); // [Fix 4]
      _isConnecting[id] = false;
      _reconnectInProgress[id] = false;
      _setConnectionState(id, SshConnectionState.offline);
    }
  }

  /// Resumes sessions that were suspended due to backgrounding.
  void _resumeAllSessions() {
    if (!_isNetworkAvailable) return; // Network lost — wait for restore
    for (final id in List<String>.from(_connectionStates.keys)) {
      if (!_pollingTimers.containsKey(id)) {
        _reconnectServer(id);
      }
    }
  }

  // ── Connectivity monitoring ────────────────────────────────────────────

  Future<void> _initConnectivityMonitoring() async {
    final initial = await Connectivity().checkConnectivity();
    _isNetworkAvailable = initial.any(_isUsableNetwork);

    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    debugPrint(
        'ServerMonitor: Network monitoring started (${_isNetworkAvailable ? "online" : "offline"})');
  }

  bool _isUsableNetwork(ConnectivityResult r) =>
      r == ConnectivityResult.wifi ||
      r == ConnectivityResult.mobile ||
      r == ConnectivityResult.ethernet ||
      r == ConnectivityResult.vpn;

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasNetwork = results.any(_isUsableNetwork);
    if (!hasNetwork && _isNetworkAvailable) {
      _isNetworkAvailable = false;
      debugPrint('ServerMonitor: Network LOST — pausing all polling');
      _handleNetworkLost();
    } else if (hasNetwork && !_isNetworkAvailable) {
      _isNetworkAvailable = true;
      debugPrint('ServerMonitor: Network RESTORED — resuming polling');
      _handleNetworkRestored();
    }
  }

  void _handleNetworkLost() {
    for (final id in List<String>.from(_connectionStates.keys)) {
      _pollingTimers[id]?.cancel();
      _pollingTimers.remove(id);
      _isConnecting[id] = false;
      _reconnectInProgress[id] = false;
      _closeClient(id); // [Fix 4]
      _setConnectionState(id, SshConnectionState.offline);
      _repository.setStatus(id, ServerStatus.offline);
    }
  }

  void _handleNetworkRestored() {
    if (!_isAppInForeground) return; // App is in background — skip
    for (final id in List<String>.from(_connectionStates.keys)) {
      if (!_pollingTimers.containsKey(id)) {
        _reconnectServer(id);
      }
    }
  }

  // ── SSH Connect & Poll ─────────────────────────────────────────────────

  /// [Fix 3] Mutex-guarded connect. Returns early if a connection attempt is
  /// already in flight for this server.
  Future<void> _connectAndStartPolling(String serverId) async {
    if (_isConnecting[serverId] == true) {
      debugPrint(
          'ServerMonitor: Connect already in progress for $serverId — skipping');
      return;
    }
    _isConnecting[serverId] = true;

    final server = await _repository.getServerById(serverId);
    if (server == null) {
      _isConnecting[serverId] = false;
      _loadingNotifier.markError(serverId, 'Server not found');
      return;
    }

    try {
      // [Fix 2] Enforce 10-second timeout on SSH connect
      final client = await _sshService
          .connect(
              server.hostname, server.port, server.username, server.password)
          .timeout(_kSshTimeout);

      if (client == null) throw Exception('SSH connection returned null');

      _sshClients[serverId] = client;
      _cpuStates[serverId] = _CpuState(prevIdle: 0, prevTotal: 0);
      _setConnectionState(serverId, SshConnectionState.connected);
      await _repository.setStatus(serverId, ServerStatus.online);

      // Cancel any stale timer before creating a new one [Fix 3]
      _pollingTimers[serverId]?.cancel();
      _pollingTimers[serverId] = Timer.periodic(
        Duration(seconds: _pollIntervalSeconds),
        (_) => _pollServer(serverId),
      );

      await _pollServer(serverId);
      _loadingNotifier.markLoaded(serverId);
    } on TimeoutException {
      debugPrint('ServerMonitor: SSH connect timed out for $serverId');
      _closeClient(serverId);
      _setConnectionState(serverId, SshConnectionState.offline);
      await _repository.setStatus(serverId, ServerStatus.error);
      _loadingNotifier.markError(serverId, 'Connection Timed Out');
    } on SocketException catch (e) {
      debugPrint('ServerMonitor: SocketException for $serverId: $e');
      _closeClient(serverId);
      await _repository.setStatus(serverId, ServerStatus.error);
      _loadingNotifier.markError(
          serverId, 'Host Unreachable: Check IP or Port');
      _setConnectionState(serverId, SshConnectionState.offline);
    } catch (e) {
      final msg = e.toString();
      debugPrint('ServerMonitor: Initial connect failed for $serverId: $msg');
      _closeClient(serverId);
      await _repository.setStatus(serverId, ServerStatus.error);

      // Fallback message mapping if DartSSH2 throws generic exception for auth
      if (msg.toLowerCase().contains('auth')) {
        _loadingNotifier.markError(serverId,
            'Authentication Failed: Invalid Username or Password/Key');
      } else {
        _loadingNotifier.markError(serverId, msg);
      }

      _setConnectionState(serverId, SshConnectionState.offline);
    } finally {
      _isConnecting[serverId] = false; // Always release the mutex
    }
  }

  /// Poll a single server; triggers reconnect loop on any connection-level error.
  Future<void> _pollServer(String serverId) async {
    final client = _sshClients[serverId];
    final cpuState = _cpuStates[serverId];
    if (client == null || cpuState == null) return;

    try {
      const pollingCmd =
          r'cat /proc/stat; echo "|||"; free -b; echo "|||"; df -k /; echo "|||"; cat /proc/uptime; echo "|||"; hostname; echo "|||"; hostname -I || ip addr show; echo "|||"; cat /etc/os-release; echo "|||"; uname -r; exit';

      final stopwatch = Stopwatch()..start();

      // [Fix 2] Hard 10s timeout on SSH run
      final result = await client.run(pollingCmd).timeout(_kSshTimeout);
      stopwatch.stop();

      final rawOutput = utf8.decode(result).trim();
      final latencyMs = stopwatch.elapsedMilliseconds;

      ServerStats stats = await _parseInIsolate(
          rawOutput, cpuState.prevIdle, cpuState.prevTotal, latencyMs);

      // Geolocation (cached per server)
      String serverLoc = '';
      final current = await _repository.getServerById(serverId);
      if (current != null) serverLoc = current.serverLocation;
      if (serverLoc.isEmpty && stats.ipAddress.isNotEmpty) {
        try {
          serverLoc =
              await GeolocationService.getLocationFromIp(stats.ipAddress);
        } catch (_) {}
      }
      stats = stats.copyWith(serverLocation: serverLoc);

      _cpuStates[serverId] =
          _CpuState(prevIdle: stats.cpuIdle, prevTotal: stats.cpuTotal);

      final history = _serverHistories[serverId] ?? [];
      history.add(stats);
      if (history.length > _maxHistoryPoints) history.removeAt(0);
      _serverHistories[serverId] = history;

      if (_connectionStates[serverId] != SshConnectionState.connected) {
        _setConnectionState(serverId, SshConnectionState.connected);
      }

      state = const AsyncValue.data(null);
      await _repository.updateSnapshot(serverId, stats);
    } on TimeoutException catch (e) {
      debugPrint('ServerMonitor: Poll timed out for $serverId: $e');
      _triggerReconnect(serverId);
    } on SocketException catch (e) {
      debugPrint('ServerMonitor: Socket error for $serverId: $e');
      _triggerReconnect(serverId);
    } catch (e) {
      final msg = e.toString();
      debugPrint('ServerMonitor: Poll error for $serverId: $msg');
      if (_isConnectionError(msg)) {
        _triggerReconnect(serverId);
      } else {
        await _repository.setStatus(serverId, ServerStatus.offline);
        final ls = _loadingNotifier.getServerState(serverId);
        if (!ls.hasLoadedOnce) _loadingNotifier.markError(serverId, msg);
      }
    }
  }

  // ── Reconnect logic ────────────────────────────────────────────────────

  /// Stops the failing timer, closes dead client, and launches reconnect loop.
  void _triggerReconnect(String serverId) {
    if (_reconnectInProgress[serverId] == true) return;
    if (!_connectionStates.containsKey(serverId)) return;

    _pollingTimers[serverId]?.cancel();
    _pollingTimers.remove(serverId);
    _closeClient(serverId); // [Fix 4]
    _isConnecting[serverId] = false; // Release mutex so reconnect can proceed

    _setConnectionState(serverId, SshConnectionState.reconnecting);
    _repository.setStatus(serverId, ServerStatus.offline);

    _reconnectServer(serverId);
  }

  /// Exponential-backoff loop. Stops when server is reconnected or removed.
  Future<void> _reconnectServer(String serverId) async {
    if (_reconnectInProgress[serverId] == true) return;
    _reconnectInProgress[serverId] = true;

    int attempt = 0;

    while (true) {
      if (!_connectionStates.containsKey(serverId)) break; // Server deleted
      if (!_isNetworkAvailable) {
        debugPrint('ServerMonitor: Reconnect aborted — no network');
        _setConnectionState(serverId, SshConnectionState.offline);
        break;
      }
      if (!_isAppInForeground) {
        debugPrint('ServerMonitor: Reconnect aborted — app in background');
        _setConnectionState(serverId, SshConnectionState.offline);
        break;
      }

      final delay =
          _kReconnectDelays[attempt.clamp(0, _kReconnectDelays.length - 1)];
      debugPrint(
          'ServerMonitor: Reconnect attempt ${attempt + 1} for $serverId in ${delay}s');
      await Future.delayed(Duration(seconds: delay));

      if (!_connectionStates.containsKey(serverId)) break;

      final server = await _repository.getServerById(serverId);
      if (server == null) break;

      _setConnectionState(serverId, SshConnectionState.connecting);

      // [Fix 3] Check mutex before SSH attempt
      if (_isConnecting[serverId] == true) {
        attempt++;
        continue;
      }
      _isConnecting[serverId] = true;

      try {
        // [Fix 2] 10-second hard timeout on reconnect connect
        final client = await _sshService
            .connect(
                server.hostname, server.port, server.username, server.password)
            .timeout(_kSshTimeout);

        if (client == null) throw Exception('Connection returned null');

        _sshClients[serverId] = client;
        _cpuStates[serverId] = _CpuState(prevIdle: 0, prevTotal: 0);
        _setConnectionState(serverId, SshConnectionState.connected);
        await _repository.setStatus(serverId, ServerStatus.online);

        // Cancel stale timer before starting new one [Fix 3]
        _pollingTimers[serverId]?.cancel();
        _pollingTimers[serverId] = Timer.periodic(
          Duration(seconds: _pollIntervalSeconds),
          (_) => _pollServer(serverId),
        );
        await _pollServer(serverId);

        debugPrint(
            'ServerMonitor: Reconnected $serverId after ${attempt + 1} attempt(s)');
        break; // Success — exit loop
      } on TimeoutException {
        debugPrint('ServerMonitor: Reconnect timed out for $serverId');
        _closeClient(serverId);
        _setConnectionState(serverId, SshConnectionState.reconnecting);
        _loadingNotifier.markError(serverId, 'Connection Timed Out');
        attempt++;
      } on SocketException catch (e) {
        debugPrint('ServerMonitor: Reconnect socket error for $serverId: $e');
        _closeClient(serverId);
        _setConnectionState(serverId, SshConnectionState.reconnecting);
        _loadingNotifier.markError(
            serverId, 'Host Unreachable: Check IP or Port');
        attempt++;
      } catch (e) {
        final msg = e.toString();
        debugPrint(
            'ServerMonitor: Reconnect attempt failed for $serverId: $msg');
        _closeClient(serverId);

        // HALT ON AUTH FAILURE
        if (msg.toLowerCase().contains('auth')) {
          debugPrint(
              'ServerMonitor: FATAL auth error. Aborting reconnect loop.');
          _loadingNotifier.markError(serverId,
              'Authentication Failed: Invalid Username or Password/Key');
          _setConnectionState(serverId, SshConnectionState.offline);
          await _repository.setStatus(serverId, ServerStatus.error);
          break; // Exit the while(true) loop immediately
        }

        _setConnectionState(serverId, SshConnectionState.reconnecting);
        _loadingNotifier.markError(serverId, msg);
        attempt++;
      } finally {
        _isConnecting[serverId] = false; // Always release [Fix 3]
      }
    }

    _reconnectInProgress.remove(serverId);
  }

  // ── Timer management ───────────────────────────────────────────────────

  void _restartAllTimers() {
    for (final id in List<String>.from(_pollingTimers.keys)) {
      _pollingTimers[id]?.cancel(); // [Fix 3] Cancel before replacing
      _pollingTimers[id] = Timer.periodic(
        Duration(seconds: _pollIntervalSeconds),
        (_) => _pollServer(id),
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  /// [Fix 4] Safe client close — swallows errors from dead sockets.
  void _closeClient(String serverId) {
    try {
      _sshClients[serverId]?.close();
    } catch (e) {
      debugPrint(
          'ServerMonitor: Error closing client for $serverId (safe to ignore): $e');
    } finally {
      _sshClients.remove(serverId);
    }
  }

  void _setConnectionState(String serverId, SshConnectionState s) {
    _connectionStates[serverId] = s;
    state = const AsyncValue.data(null);
  }

  bool _isConnectionError(String message) {
    final m = message.toLowerCase();
    return m.contains('socket') ||
        m.contains('connection') ||
        m.contains('ssh') ||
        m.contains('closed') ||
        m.contains('reset') ||
        m.contains('broken pipe') ||
        m.contains('timeout') ||
        m.contains('eof');
  }

  // ── Isolate parsing ────────────────────────────────────────────────────

  Future<ServerStats> _parseInIsolate(
    String rawOutput,
    int prevIdle,
    int prevTotal,
    int latencyMs,
  ) =>
      compute(
        _parseInIsolateHelper,
        _ParseParams(
          rawOutput: rawOutput,
          prevIdle: prevIdle,
          prevTotal: prevTotal,
          latencyMs: latencyMs,
        ),
      );

  static ServerStats _parseInIsolateHelper(_ParseParams params) {
    try {
      final statsMap = LinuxParser.parseAll(
        params.rawOutput,
        prevIdle: params.prevIdle,
        prevTotal: params.prevTotal,
      );
      return ServerStats(
        cpuPct: statsMap['cpuPct'],
        ramPct: statsMap['ramPct'],
        diskPct: statsMap['diskPct'],
        uptime: statsMap['uptime'],
        cpuIdle: statsMap['cpuIdle'],
        cpuTotal: statsMap['cpuTotal'],
        latencyMs: params.latencyMs,
        timestamp: DateTime.now(),
        hostname: statsMap['hostname'],
        ipAddress: statsMap['ipAddress'],
        osDistro: statsMap['osDistro'],
        kernelVersion: statsMap['kernelVersion'],
        diskUsed: statsMap['diskUsed'] ?? 0,
        diskTotal: statsMap['diskTotal'] ?? 0,
      );
    } catch (_) {
      return ServerStats(
        cpuPct: 0.0,
        ramPct: 0.0,
        diskPct: 0.0,
        uptime: 'Error',
        cpuIdle: params.prevIdle,
        cpuTotal: params.prevTotal,
        latencyMs: params.latencyMs,
        timestamp: DateTime.now(),
      );
    }
  }
}

// ── Supporting types ─────────────────────────────────────────────────────────

class _CpuState {
  final int prevIdle;
  final int prevTotal;
  const _CpuState({required this.prevIdle, required this.prevTotal});
}

class _ParseParams {
  final String rawOutput;
  final int prevIdle;
  final int prevTotal;
  final int latencyMs;
  const _ParseParams({
    required this.rawOutput,
    required this.prevIdle,
    required this.prevTotal,
    required this.latencyMs,
  });
}
