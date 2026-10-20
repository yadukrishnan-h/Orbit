import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:xterm/xterm.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

enum TerminalStatus { idle, connecting, connected, disconnecting, error }

class TerminalState {
  TerminalState({
    this.selectedServer,
    this.status = TerminalStatus.idle,
    this.errorMessage,
    Terminal? terminal,
  }) : terminal = terminal ?? Terminal();

  final Server? selectedServer;
  final TerminalStatus status;
  final String? errorMessage;
  final Terminal terminal;

  bool get isConnected => status == TerminalStatus.connected;
  bool get isBusy =>
      status == TerminalStatus.connecting ||
      status == TerminalStatus.disconnecting;

  TerminalState copyWith({
    Server? selectedServer,
    TerminalStatus? status,
    String? errorMessage,
    Terminal? terminal,
    bool clearError = false,
    bool clearServer = false,
  }) {
    return TerminalState(
      selectedServer: clearServer
          ? null
          : (selectedServer ?? this.selectedServer),
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      terminal: terminal ?? this.terminal,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class TerminalNotifier extends StateNotifier<TerminalState> {
  TerminalNotifier(this._ref) : super(TerminalState()) {
    // Clean up active session if the current server is deleted from the database [LOGIC-008]
    _ref.listen<AsyncValue<List<Server>>>(serverListStreamProvider, (
      prev,
      next,
    ) {
      final serverId = state.selectedServer?.id;
      if (serverId != null) {
        final servers = next.asData?.value;
        if (servers != null && !servers.any((s) => s.id == serverId)) {
          disconnect();
        }
      }
    });
  }

  final Ref _ref;

  SSHClient? _client;
  SSHSession? _session;
  StreamSubscription<String>? _stdoutSub;
  StreamSubscription<String>? _stderrSub;
  final StringBuffer _outputBuffer = StringBuffer();
  Timer? _flushTimer;
  static const int _maxBufferSize = 64 * 1024; // 64 KB backpressure threshold

  void _handleTerminalOutput(String text) {
    _outputBuffer.write(text);

    // Apply backpressure if buffered text exceeds 64KB before flush timer fires [LOGIC-004]
    if (_outputBuffer.length >= _maxBufferSize) {
      _stdoutSub?.pause();
      _stderrSub?.pause();
    }

    _flushTimer ??= Timer(const Duration(milliseconds: 16), _flushOutputBuffer);
  }

  void _flushOutputBuffer() {
    if (_outputBuffer.isNotEmpty) {
      state.terminal.write(_outputBuffer.toString());
      _outputBuffer.clear();
    }
    _stdoutSub?.resume();
    _stderrSub?.resume();
    _flushTimer = null;
  }

  // -------------------------------------------------------------------------
  // Public API
  // -------------------------------------------------------------------------

  Future<void> connectToServer(Server server) async {
    if (state.isBusy) return;

    // reset terminal for new connection
    state.terminal.write('\x1b[2J\x1b[H');

    state = state.copyWith(
      selectedServer: server,
      status: TerminalStatus.connecting,
      clearError: true,
    );

    try {
      final sshService = _ref.read(sshServiceProvider);
      _client = await sshService.connect(
        server.hostname,
        server.port,
        server.username,
        server.id,
      );

      // Request a PTY-backed interactive shell
      _session = await _client!.shell(
        pty: SSHPtyConfig(
          type: 'xterm-256color',
          width: state.terminal.viewWidth,
          height: state.terminal.viewHeight,
        ),
      );

      state = state.copyWith(status: TerminalStatus.connected);

      // Bridge Terminal -> SSH
      state.terminal.onOutput = (data) {
        _session?.stdin.add(utf8.encode(data));
      };

      // Bridge Terminal -> Resize
      state.terminal.onResize = (width, height, pixelWidth, pixelHeight) {
        _session?.resizeTerminal(width, height);
      };

      // Bridge SSH -> Terminal [LOGIC-003, LOGIC-004]
      // Use stateful Utf8Decoder so multibyte chars split across TCP chunks never throw
      _stdoutSub = _session!.stdout
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(
            _handleTerminalOutput,
            onDone: _onSessionDone,
            onError: _onStreamError,
            cancelOnError: false,
          );

      _stderrSub = _session!.stderr
          .cast<List<int>>()
          .transform(const Utf8Decoder(allowMalformed: true))
          .listen(
            _handleTerminalOutput,
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

  void clearOutput() => state.terminal.write('\x1b[2J\x1b[H');

  Future<void> disconnect() async {
    if (!mounted || state.status == TerminalStatus.idle) return;
    state = state.copyWith(status: TerminalStatus.disconnecting);
    await _cleanup();
    if (mounted) {
      state = TerminalState(terminal: state.terminal);
    }
  }

  // -------------------------------------------------------------------------
  // Private — data processing
  // -------------------------------------------------------------------------

  void _onSessionDone() {
    _cleanup();
    if (mounted) {
      state = TerminalState(terminal: state.terminal);
    }
  }

  void _onStreamError(Object error) {
    _cleanup();
    if (mounted) {
      state = state.copyWith(
        status: TerminalStatus.error,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> _cleanup() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    final term = mounted ? state.terminal : null;
    if (_outputBuffer.isNotEmpty) {
      term?.write(_outputBuffer.toString());
      _outputBuffer.clear();
    }

    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;
    _session?.close();
    _session = null;
    _client?.close();
    _client = null;

    // Important: remove callbacks to prevent memory leaks or unexpected behavior
    term?.onOutput = null;
    term?.onResize = null;
  }

  @override
  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
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
