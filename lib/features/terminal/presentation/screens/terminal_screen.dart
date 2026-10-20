import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/utils/error_mapper.dart';
import 'package:orbit/features/terminal/providers/terminal_provider.dart';
import 'package:xterm/xterm.dart' hide TerminalState;

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class TerminalScreen extends ConsumerStatefulWidget {
  const TerminalScreen({super.key});

  @override
  ConsumerState<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends ConsumerState<TerminalScreen> {
  final _terminalController = TerminalController();
  bool _ctrlActive = false;
  bool _altActive = false;

  void _processTerminalInput(String data) {
    if (data.isEmpty) return;
    String processed = data;
    if (_ctrlActive || _altActive) {
      final buffer = StringBuffer();
      for (int i = 0; i < data.length; i++) {
        final code = data.codeUnitAt(i);
        String char = data[i];
        if (_ctrlActive) {
          // Convert ASCII '@' through '_' and 'a' through 'z' to control bytes 0x00..0x1F [UI-001]
          if ((code >= 64 && code <= 95) || (code >= 97 && code <= 122)) {
            char = String.fromCharCode(code & 0x1F);
          }
        }
        if (_altActive) {
          char = '\x1b$char';
        }
        buffer.write(char);
      }
      processed = buffer.toString();
      setState(() {
        _ctrlActive = false;
        _altActive = false;
      });
    }
    ref.read(terminalProvider.notifier).sendRaw(processed);
  }

  Terminal? _attachedTerminal;

  void _attachTerminal(Terminal terminal) {
    if (_attachedTerminal == terminal &&
        terminal.onOutput == _processTerminalInput) {
      return;
    }
    _attachedTerminal = terminal;
    terminal.onOutput = _processTerminalInput;
  }

  Future<void> _handlePaste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      ref.read(terminalProvider.notifier).sendRaw(data.text!);
    }
  }

  @override
  void initState() {
    super.initState();
    // [UI-001]: Attach input interceptor once during initialization rather than inside build()
    _attachTerminal(ref.read(terminalProvider).terminal);
    ref.listenManual(terminalProvider, (previous, next) {
      if (previous?.terminal != next.terminal) {
        _attachTerminal(next.terminal);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final args = GoRouterState.of(context).extra;
        if (args is Server) {
          ref.read(terminalProvider.notifier).connectToServer(args);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _terminalController.dispose();
    super.dispose();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(terminalProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(state),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: switch (state.status) {
          TerminalStatus.idle => _buildServerSelector(),
          TerminalStatus.connecting => _buildOverlay(
            key: const ValueKey('connecting'),
          ),
          TerminalStatus.connected => _buildTerminalView(state),
          TerminalStatus.disconnecting => _buildOverlay(
            key: const ValueKey('disconnecting'),
            label: 'Disconnecting…',
          ),
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
          const Icon(
            LucideIcons.terminal,
            size: 18,
            color: AppTheme.textPrimary,
          ),
          const SizedBox(width: AppSizes.p8),
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
            padding: const EdgeInsets.only(right: AppSizes.p4),
            child: Container(
              width: AppSizes.p8,
              height: AppSizes.p8,
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
        child: Text(
          ErrorMapper.userFriendlyMessage(e),
          style: const TextStyle(color: AppTheme.critical),
          textAlign: TextAlign.center,
        ),
      ),
      data: (servers) {
        if (servers.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.p32),
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
                      child: const Icon(
                        LucideIcons.terminal,
                        size: 52,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p28),
                  Text(
                    ref.tr('no_servers_yet'),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p10),
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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Select a system to initiate a secure shell (SSH) session and manage your server via the command line.',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            Text('AVAILABLE SESSIONS', style: AppTheme.sectionTitleStyle),
            const SizedBox(height: 12),
            ...List.generate(servers.length, (index) {
              final server = servers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSessionCard(
                  server: server,
                  onTap: () => ref
                      .read(terminalProvider.notifier)
                      .connectToServer(server),
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        );
      },
    );
  }

  Widget _buildSessionCard({
    required Server server,
    required VoidCallback onTap,
  }) {
    final isOnline = server.status == ServerStatus.online;
    final statusColor = isOnline
        ? AppTheme.terminalMint
        : const Color(0xFF7E8492);
    final statusBgColor = isOnline
        ? AppTheme.terminalMint.withValues(alpha: 0.12)
        : const Color(0xFF7E8492).withValues(alpha: 0.12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Leading icon tile
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOnline
                    ? AppTheme.terminalMint.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOnline
                      ? AppTheme.terminalMint.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: Icon(
                LucideIcons.terminal,
                size: 20,
                color: isOnline
                    ? AppTheme.terminalMint
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            // Server name & technical subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    server.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${server.username}@${server.hostname}:${server.port}',
                    style: GoogleFonts.firaCode(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Pill status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: isOnline
                          ? [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Connecting / Disconnecting Overlay ───────────────────────────────────

  Widget _buildOverlay({required Key key, String label = 'Connecting…'}) {
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
                border: Border.all(
                  color: AppTheme.critical.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                LucideIcons.wifiOff,
                size: 32,
                color: AppTheme.critical,
              ),
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
                  color: AppTheme.critical.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 16,
                    color: AppTheme.critical,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ErrorMapper.userFriendlyMessage(state.errorMessage),
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
                      horizontal: 20,
                      vertical: 14,
                    ),
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
                      horizontal: 20,
                      vertical: 14,
                    ),
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
        _TerminalStatusBar(
          server: state.selectedServer,
          onDisconnect: () => ref.read(terminalProvider.notifier).disconnect(),
        ),
        Expanded(
          child: TerminalView(
            state.terminal,
            controller: _terminalController,
            autofocus: true,
            textStyle: TerminalStyle(
              fontFamily: GoogleFonts.firaCode().fontFamily!,
              fontSize: 13,
            ),
            theme: _getTerminalTheme(),
          ),
        ),
        _QuickKeysBar(
          terminal: state.terminal,
          isCtrlActive: _ctrlActive,
          isAltActive: _altActive,
          onCtrlToggle: () {
            setState(() {
              _ctrlActive = !_ctrlActive;
            });
          },
          onAltToggle: () {
            setState(() {
              _altActive = !_altActive;
            });
          },
          onKeyPress: _processTerminalInput,
          onPaste: _handlePaste,
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  TerminalTheme _getTerminalTheme() {
    return TerminalTheme(
      cursor: AppTheme.primary,
      selection: AppTheme.primary.withValues(alpha: 0.3),
      foreground: AppTheme.textPrimary,
      background: AppTheme.background,
      black: Colors.black,
      red: AppTheme.critical,
      green: AppTheme.success,
      yellow: AppTheme.warning,
      blue: Colors.blue,
      magenta: Colors.pink,
      cyan: Colors.cyan,
      white: Colors.white,
      brightBlack: Colors.grey,
      brightRed: AppTheme.critical,
      brightGreen: AppTheme.success,
      brightYellow: AppTheme.warning,
      brightBlue: Colors.blueAccent,
      brightMagenta: Colors.pinkAccent,
      brightCyan: Colors.cyanAccent,
      brightWhite: Colors.white,
      searchHitBackground: AppTheme.warning.withValues(alpha: 0.5),
      searchHitBackgroundCurrent: AppTheme.warning,
      searchHitForeground: Colors.black,
    );
  }
}

class _TerminalStatusBar extends StatelessWidget {
  const _TerminalStatusBar({required this.server, this.onDisconnect});

  final Server? server;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    if (server == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
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
                  blurRadius: 5,
                ),
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
            style: GoogleFonts.firaCode(fontSize: 10, color: AppTheme.disabled),
          ),
          if (onDisconnect != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(
                LucideIcons.power,
                size: 16,
                color: AppTheme.critical,
              ),
              tooltip: 'Disconnect',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onDisconnect,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickKeysBar extends StatelessWidget {
  const _QuickKeysBar({
    required this.terminal,
    required this.isCtrlActive,
    required this.isAltActive,
    required this.onCtrlToggle,
    required this.onAltToggle,
    required this.onKeyPress,
    required this.onPaste,
  });

  final Terminal terminal;
  final bool isCtrlActive;
  final bool isAltActive;
  final VoidCallback onCtrlToggle;
  final VoidCallback onAltToggle;
  final ValueChanged<String> onKeyPress;
  final VoidCallback onPaste;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ('ESC', '\x1b'),
      ('TAB', '\t'),
      ('CTRL', 'ctrl'),
      ('ALT', 'alt'),
      ('UP', '\x1b[A'),
      ('DOWN', '\x1b[B'),
      ('LEFT', '\x1b[D'),
      ('RIGHT', '\x1b[C'),
      ('/', '/'),
      ('-', '-'),
      ('|', '|'),
      ('HOME', '\x1b[H'),
      ('END', '\x1b[F'),
    ];

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          // Dedicated Paste button [UI-004]
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 36,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.terminalMint.withValues(
                      alpha: 0.12,
                    ),
                    foregroundColor: AppTheme.terminalMint,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: AppTheme.terminalMint.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    minimumSize: const Size(64, 36),
                  ),
                  onPressed: onPaste,
                  icon: const Icon(LucideIcons.clipboardPaste, size: 14),
                  label: Text(
                    'PASTE',
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.terminalMint,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...keys.map((key) {
            final isCtrl = key.$1 == 'CTRL';
            final isAlt = key.$1 == 'ALT';
            final isKeyActive =
                (isCtrl && isCtrlActive) || (isAlt && isAltActive);
            final isModifier =
                key.$1 == 'ESC' || key.$1 == 'TAB' || isCtrl || isAlt;

            Color backgroundColor;
            Color foregroundColor;
            Color borderColor;

            if (isKeyActive) {
              backgroundColor = AppTheme.terminalMint;
              foregroundColor = const Color(0xFF111318);
              borderColor = AppTheme.terminalMint;
            } else if (isModifier) {
              backgroundColor = AppTheme.terminalMint.withValues(alpha: 0.12);
              foregroundColor = AppTheme.terminalMint;
              borderColor = AppTheme.terminalMint.withValues(alpha: 0.3);
            } else {
              backgroundColor = const Color(0xFF181A20);
              foregroundColor = AppTheme.textPrimary;
              borderColor = Colors.white.withValues(alpha: 0.08);
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 36,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: backgroundColor,
                      foregroundColor: foregroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: borderColor,
                          width: isKeyActive ? 1.5 : 0.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: const Size(44, 36),
                    ),
                    onPressed: () {
                      if (isCtrl) {
                        onCtrlToggle();
                        return;
                      }
                      if (isAlt) {
                        onAltToggle();
                        return;
                      }
                      onKeyPress(key.$2);
                    },
                    child: Text(
                      key.$1,
                      style: GoogleFonts.firaCode(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
