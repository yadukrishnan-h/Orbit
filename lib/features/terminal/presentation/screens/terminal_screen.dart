import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/features/terminal/providers/terminal_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode = FocusNode();

  final List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = GoRouterState.of(context).extra;
      if (args is Server) {
        ref.read(terminalProvider.notifier).connectToServer(args);
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // ─── Scroll ───────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Input ────────────────────────────────────────────────────────────────

  void _sendCommand() {
    final text = _inputController.text;
    if (text.isEmpty) return;
    ref.read(terminalProvider.notifier).sendCommand(text);
    _history.insert(0, text);
    _historyIndex = -1;
    _inputController.clear();
    _inputFocusNode.requestFocus();
  }

  void _navigateHistory(bool up) {
    if (_history.isEmpty) return;
    setState(() {
      _historyIndex = up
          ? (_historyIndex + 1).clamp(0, _history.length - 1)
          : (_historyIndex - 1).clamp(-1, _history.length - 1);
      _inputController.text =
          _historyIndex == -1 ? '' : _history[_historyIndex];
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: _inputController.text.length),
      );
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(terminalProvider);

    if (state.isConnected && state.outputLines.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(state),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: switch (state.status) {
          TerminalStatus.idle => _buildServerSelector(),
          TerminalStatus.connecting =>
            _buildOverlay(key: const ValueKey('connecting')),
          TerminalStatus.connected => _buildTerminalView(state),
          TerminalStatus.disconnecting => _buildOverlay(
              key: const ValueKey('disconnecting'), label: 'Disconnecting…'),
          TerminalStatus.error => _buildErrorView(state),
        },
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(TerminalState state) {
    final server = state.selectedServer;

    Widget titleWidget;
    if (server != null && state.status != TerminalStatus.idle) {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.terminal,
              size: 18, color: AppTheme.textPrimary),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  server.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${server.username}@${server.hostname}',
                  style: GoogleFonts.firaCode(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      titleWidget = Text(
        ref.tr('nav_terminal'),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      );
    }

    return AppBar(
      backgroundColor: AppTheme.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: titleWidget,
      actions: [
        if (state.isConnected) ...[
          // Connected indicator dot
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.success.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          // Clear output
          IconButton(
            icon: const Icon(LucideIcons.eraser, size: 18),
            color: AppTheme.textPrimary,
            tooltip: 'Clear output',
            onPressed: () => ref.read(terminalProvider.notifier).clearOutput(),
          ),
          // Disconnect
          IconButton(
            icon: const Icon(LucideIcons.plugZap, size: 18),
            color: AppTheme.textPrimary,
            tooltip: 'Disconnect',
            onPressed: () => ref.read(terminalProvider.notifier).disconnect(),
          ),
        ],
        if (state.status == TerminalStatus.error)
          IconButton(
            icon: const Icon(LucideIcons.x, size: 18),
            color: AppTheme.textSecondary,
            onPressed: () => ref.read(terminalProvider.notifier).disconnect(),
          ),
        // Always show the server picker shortcut
        IconButton(
          icon: const Icon(LucideIcons.server, size: 18),
          color: AppTheme.textPrimary,
          tooltip: 'Change server',
          onPressed: state.isBusy
              ? null
              : () => ref.read(terminalProvider.notifier).disconnect(),
        ),
      ],
    );
  }

  // ─── Server Selector ──────────────────────────────────────────────────────

  Widget _buildServerSelector() {
    final serverListAsync = ref.watch(serverListStreamProvider);

    return serverListAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (e, _) => Center(
        child: Text('$e', style: const TextStyle(color: AppTheme.critical)),
      ),
      data: (servers) {
        if (servers.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.terminal,
                          size: 52, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    ref.tr('no_servers_yet'),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ref.tr('add_server_prompt_terminal'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.terminal,
                          size: 36, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ref.tr('open_terminal'),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ref.tr('select_server_shell'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Divider
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 12),

            // ── Server List ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: servers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _ServerTile(server: servers[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Connecting / Disconnecting Overlay ───────────────────────────────────

  Widget _buildOverlay({
    required Key key,
    String label = 'Connecting…',
  }) {
    return BackdropFilter(
      key: key,
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: AppTheme.background.withValues(alpha: 0.55),
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
          decoration: BoxDecoration(
            color: AppTheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error View ───────────────────────────────────────────────────────────

  Widget _buildErrorView(TerminalState state) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.critical.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border:
                    Border.all(color: AppTheme.critical.withValues(alpha: 0.3)),
              ),
              child: const Icon(LucideIcons.wifiOff,
                  size: 32, color: AppTheme.critical),
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Failed',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Error box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.critical.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppTheme.critical.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(LucideIcons.alertCircle,
                      size: 16, color: AppTheme.critical),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.errorMessage ?? 'Unknown error.',
                      style: GoogleFonts.firaCode(
                        fontSize: 12,
                        color: AppTheme.critical,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(terminalProvider.notifier).disconnect(),
                  icon: const Icon(LucideIcons.arrowLeft, size: 16),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    final server = state.selectedServer;
                    if (server != null) {
                      ref
                          .read(terminalProvider.notifier)
                          .connectToServer(server);
                    }
                  },
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Terminal View ────────────────────────────────────────────────────────

  Widget _buildTerminalView(TerminalState state) {
    return Column(
      children: [
        // Status bar
        _TerminalStatusBar(server: state.selectedServer),

        // Output — isolated in its own widget to limit rebuild scope
        Expanded(
          child: RepaintBoundary(
            child: _TerminalOutput(
              lines: state.outputLines,
              scrollController: _scrollController,
            ),
          ),
        ),

        // Input bar
        Container(
          color: AppTheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(color: AppTheme.border, height: 1),
              _buildInputBar(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Prompt character
          Text(
            '\$',
            style: GoogleFonts.firaCode(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 10),

          // Text field
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    _navigateHistory(true);
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    _navigateHistory(false);
                  } else if (event.logicalKey == LogicalKeyboardKey.keyC &&
                      HardwareKeyboard.instance.isControlPressed) {
                    ref.read(terminalProvider.notifier).sendRaw('\x03');
                  } else if (event.logicalKey == LogicalKeyboardKey.keyD &&
                      HardwareKeyboard.instance.isControlPressed) {
                    ref.read(terminalProvider.notifier).sendRaw('\x04');
                  } else if (event.logicalKey == LogicalKeyboardKey.keyL &&
                      HardwareKeyboard.instance.isControlPressed) {
                    ref.read(terminalProvider.notifier).clearOutput();
                  }
                }
              },
              child: TextField(
                controller: _inputController,
                focusNode: _inputFocusNode,
                autofocus: true,
                style: GoogleFonts.firaCode(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
                cursorColor: AppTheme.primary,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 2),
                  hintText: 'Enter command…',
                  hintStyle: TextStyle(color: AppTheme.disabled, fontSize: 13),
                ),
                onSubmitted: (_) => _sendCommand(),
                textInputAction: TextInputAction.send,
              ),
            ),
          ),

          // Send button
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: _sendCommand,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: const Icon(LucideIcons.cornerDownLeft,
                    size: 16, color: AppTheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Server tile — extracted to avoid rebuilding the whole list on state changes
// ─────────────────────────────────────────────────────────────────────────────

class _ServerTile extends ConsumerWidget {
  const _ServerTile({required this.server});

  final Server server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = server.status == ServerStatus.online;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            ref.read(terminalProvider.notifier).connectToServer(server),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // Server icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.server,
                    size: 20, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${server.username}@${server.hostname}:${server.port}',
                      style: GoogleFonts.firaCode(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isOnline ? AppTheme.success : AppTheme.disabled)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? AppTheme.success : AppTheme.disabled,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isOnline ? AppTheme.success : AppTheme.disabled,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight,
                  size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status bar — thin themed bar showing current path / connection info
// ─────────────────────────────────────────────────────────────────────────────

class _TerminalStatusBar extends StatelessWidget {
  const _TerminalStatusBar({required this.server});

  final Server? server;

  @override
  Widget build(BuildContext context) {
    if (server == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          bottom: BorderSide(color: AppTheme.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: AppTheme.success.withValues(alpha: 0.4),
                    blurRadius: 5),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'SSH',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${server!.username}@${server!.hostname}:${server!.port}',
              style: GoogleFonts.firaCode(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            'xterm-256color',
            style: GoogleFonts.firaCode(
              fontSize: 10,
              color: AppTheme.disabled,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Output list — isolated widget so only it rebuilds when lines arrive
// ─────────────────────────────────────────────────────────────────────────────

class _TerminalOutput extends StatelessWidget {
  const _TerminalOutput({
    required this.lines,
    required this.scrollController,
  });

  final List<String> lines;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) {
      return Center(
        child: Text(
          'Waiting for shell…',
          style: GoogleFonts.firaCode(
            fontSize: 13,
            color: AppTheme.disabled,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: lines.length,
      // Lines are immutable once appended — skip keep-alives and boundaries
      // for pure perf gain in a dense text list.
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      itemBuilder: (_, index) => _TerminalLine(line: lines[index]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single terminal output line
// ─────────────────────────────────────────────────────────────────────────────

class _TerminalLine extends StatelessWidget {
  const _TerminalLine({required this.line});

  final String line;

  static Color _colorForLine(String line) {
    if (line.isEmpty) return const Color(0xFF71717A); // zinc-500 blank
    if (line.contains('error') ||
        line.contains('Error') ||
        line.contains('FAILED') ||
        line.contains('fatal') ||
        line.contains('Fatal')) {
      return AppTheme.critical;
    }
    if (line.contains('warning') ||
        line.contains('Warning') ||
        line.contains('WARN')) {
      return AppTheme.warning;
    }
    if (line.startsWith('\$') ||
        line.startsWith('#') ||
        line.startsWith('➜') ||
        line.startsWith('→')) {
      return AppTheme.primary;
    }
    return const Color(0xFFD4D4D4); // VS Code terminal default
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText(
      line.isEmpty ? ' ' : line, // keep height on blank lines
      style: GoogleFonts.firaCode(
        fontSize: 12.5,
        height: 1.55,
        color: _colorForLine(line),
        letterSpacing: 0.15,
      ),
    );
  }
}
