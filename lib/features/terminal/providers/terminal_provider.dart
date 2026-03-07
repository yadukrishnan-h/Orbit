import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum TerminalStatus { idle, connecting, connected, disconnecting, error }

class TerminalState {
  const TerminalState({
    this.selectedServer,
    this.status = TerminalStatus.idle,
    this.outputLines = const [],
    this.errorMessage,
  });

  final Server? selectedServer;
  final TerminalStatus status;
  final List<String> outputLines;
  final String? errorMessage;

  bool get isConnected => status == TerminalStatus.connected;
  bool get isBusy =>
      status == TerminalStatus.connecting ||
      status == TerminalStatus.disconnecting;

  TerminalState copyWith({
    Server? selectedServer,
    TerminalStatus? status,
    List<String>? outputLines,
    String? errorMessage,
    bool clearError = false,
    bool clearServer = false,
  }) {
    return TerminalState(
      selectedServer:
          clearServer ? null : (selectedServer ?? this.selectedServer),
      status: status ?? this.status,
      outputLines: outputLines ?? this.outputLines,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class TerminalNotifier extends StateNotifier<TerminalState> {
  TerminalNotifier(this._ref) : super(const TerminalState());

  final Ref _ref;

  SSHClient? _client;
  SSHSession? _session;
  StreamSubscription<Uint8List>? _stdoutSub;
  StreamSubscription<Uint8List>? _stderrSub;

  // Batching: accumulate raw bytes between timer ticks to minimise rebuilds.
  final List<String> _pendingLines = [];
  String _lineBuffer = '';
  Timer? _flushTimer;
  static const _flushInterval = Duration(milliseconds: 32); // ~30 fps

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  Future<void> connectToServer(Server server) async {
    if (state.isBusy) return;

    state = state.copyWith(
      selectedServer: server,
      status: TerminalStatus.connecting,
      outputLines: [],
      clearError: true,
    );

    try {
      final sshService = _ref.read(sshServiceProvider);
      _client = await sshService.connect(
        server.hostname,
        server.port,
        server.username,
        server.password,
      );

      // Request a PTY-backed interactive shell
      _session = await _client!.shell(
        pty: const SSHPtyConfig(
          type: 'xterm-256color',
          width: 220,
          height: 50,
        ),
      );

      state = state.copyWith(status: TerminalStatus.connected);

      _stdoutSub = _session!.stdout.listen(
        _onData,
        onDone: _onSessionDone,
        onError: _onStreamError,
        cancelOnError: false,
      );

      _stderrSub = _session!.stderr.listen(
        _onData,
        onError: _onStreamError,
        cancelOnError: false,
      );
    } catch (e) {
      await _cleanup();
      state = state.copyWith(
        status: TerminalStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Send a text command (appends newline).
  void sendCommand(String text) {
    if (!state.isConnected || _session == null) return;
    _session!.stdin.add(utf8.encode('$text\n'));
  }

  /// Send raw bytes — e.g. Ctrl-C `\x03`, Ctrl-D `\x04`.
  void sendRaw(String raw) {
    if (!state.isConnected || _session == null) return;
    _session!.stdin.add(utf8.encode(raw));
  }

  void clearOutput() => state = state.copyWith(outputLines: []);

  Future<void> disconnect() async {
    if (state.status == TerminalStatus.idle) return;
    state = state.copyWith(status: TerminalStatus.disconnecting);
    await _cleanup();
    state = const TerminalState();
  }

  // -------------------------------------------------------------------------
  // Private — data processing
  // -------------------------------------------------------------------------

  /// Called for every incoming byte chunk from the server.
  /// We accumulate into [_lineBuffer], split on newlines, and schedule a
  /// batched state update via [_flushTimer] to cap rebuilds at ~30 fps.
  void _onData(Uint8List data) {
    final raw = utf8.decode(data, allowMalformed: true);
    _lineBuffer += _stripAnsi(raw);

    final parts = _lineBuffer.split('\n');
    _lineBuffer = parts.removeLast(); // save incomplete last segment

    for (final part in parts) {
      final line = part.replaceAll('\r', '');
      _pendingLines.add(line);
    }

    // Start / reset the debounce timer.
    _flushTimer ??= Timer.periodic(_flushInterval, (_) => _flush());
  }

  /// Pushes accumulated lines into state in one rebuild.
  void _flush() {
    if (_pendingLines.isEmpty) return;
    final lines = List<String>.from(_pendingLines);
    _pendingLines.clear();
    state = state.copyWith(
      outputLines: [...state.outputLines, ...lines],
    );
  }

  void _onSessionDone() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _flush(); // drain any remaining lines

    // Flush incomplete buffer line
    if (_lineBuffer.isNotEmpty) {
      state = state.copyWith(
        outputLines: [
          ...state.outputLines,
          _lineBuffer.replaceAll('\r', ''),
        ],
      );
      _lineBuffer = '';
    }

    _cleanup();
    state = const TerminalState();
  }

  void _onStreamError(Object error) {
    _cleanup();
    state = state.copyWith(
      status: TerminalStatus.error,
      errorMessage: error.toString(),
    );
  }

  Future<void> _cleanup() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    _pendingLines.clear();
    _lineBuffer = '';
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;
    _session?.close();
    _session = null;
    _client?.close();
    _client = null;
  }

  // Compiled once — reused for every strip call.
  static final _ansiPattern = RegExp(
    r'(?:\x1B[@-Z\\-_]|\x1B\[[0-?]*[ -/]*[@-~]|\x1B\][^\x07]*(?:\x07|\x1B\\))',
  );

  String _stripAnsi(String s) => s.replaceAll(_ansiPattern, '');

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final terminalProvider = StateNotifierProvider<TerminalNotifier, TerminalState>(
  (ref) => TerminalNotifier(ref),
);
