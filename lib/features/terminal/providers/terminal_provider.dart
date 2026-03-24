import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  TerminalNotifier(this._ref) : super(TerminalState());

  final Ref _ref;

  SSHClient? _client;
  SSHSession? _session;
  StreamSubscription<Uint8List>? _stdoutSub;
  StreamSubscription<Uint8List>? _stderrSub;

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

      // Bridge SSH -> Terminal
      _stdoutSub = _session!.stdout.listen(
        (data) => state.terminal.write(utf8.decode(data)),
        onDone: _onSessionDone,
        onError: _onStreamError,
        cancelOnError: false,
      );

      _stderrSub = _session!.stderr.listen(
        (data) => state.terminal.write(utf8.decode(data)),
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
    if (state.status == TerminalStatus.idle) return;
    state = state.copyWith(status: TerminalStatus.disconnecting);
    await _cleanup();
    state = TerminalState(terminal: state.terminal);
  }

  // -------------------------------------------------------------------------
  // Private — data processing
  // -------------------------------------------------------------------------

  void _onSessionDone() {
    _cleanup();
    state = TerminalState(terminal: state.terminal);
  }

  void _onStreamError(Object error) {
    _cleanup();
    state = state.copyWith(
      status: TerminalStatus.error,
      errorMessage: error.toString(),
    );
  }

  Future<void> _cleanup() async {
    await _stdoutSub?.cancel();
    await _stderrSub?.cancel();
    _stdoutSub = null;
    _stderrSub = null;
    _session?.close();
    _session = null;
    _client?.close();
    _client = null;

    // Important: remove callbacks to prevent memory leaks or unexpected behavior
    state.terminal.onOutput = null;
    state.terminal.onResize = null;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final terminalProvider =
    StateNotifierProvider.autoDispose<TerminalNotifier, TerminalState>(
      (ref) => TerminalNotifier(ref),
    );
