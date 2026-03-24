import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/localization/app_localization.dart';
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.p20,
                AppSizes.p8,
                AppSizes.p20,
                0,
              ),
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
                      child: const Icon(
                        LucideIcons.terminal,
                        size: 36,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Text(
                      ref.tr('open_terminal'),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p6),
                    Text(
                      ref.tr('select_server_shell'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p24),
                  ],
                ),
              ),
            ),

            // Divider
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: AppSizes.p12),

            // ── Server List ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.p16,
                  0,
                  AppSizes.p16,
                  AppSizes.p16,
                ),
                itemCount: servers.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSizes.p8),
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
        _TerminalStatusBar(server: state.selectedServer),
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
        _QuickKeysBar(terminal: state.terminal),
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

// ─────────────────────────────────────────────────────────────────────────────
// Server tile
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.server,
                  size: 20,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
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
              const Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TerminalStatusBar extends StatelessWidget {
  const _TerminalStatusBar({required this.server});

  final Server? server;

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
        ],
      ),
    );
  }
}

class _QuickKeysBar extends StatelessWidget {
  const _QuickKeysBar({required this.terminal});

  final Terminal terminal;

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
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 36,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.background,
                    foregroundColor: AppTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(44, 36),
                  ),
                  onPressed: () {
                    // For now, CTRL and ALT just send a dummy char or we can implement toggle logic later.
                    // But standard terminal keys are essential.
                    if (key.$2 == 'ctrl' || key.$2 == 'alt') {
                      // Placeholder for modifier logic
                      return;
                    }
                    terminal.onOutput?.call(key.$2);
                  },
                  child: Text(
                    key.$1,
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
