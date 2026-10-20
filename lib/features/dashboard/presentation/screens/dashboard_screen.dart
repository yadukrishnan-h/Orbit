import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:uuid/uuid.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/providers/server_loading_provider.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/features/dashboard/models/ssh_connection_state.dart';
import 'package:orbit/features/dashboard/providers/dashboard_providers.dart';

import 'package:orbit/features/dashboard/widgets/cpu_line_chart.dart';
import 'package:orbit/features/dashboard/widgets/system_info_card.dart';

import 'package:orbit/features/dashboard/presentation/widgets/base_metric_card.dart';
import 'package:orbit/features/dashboard/widgets/disk_usage_gauge.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String serverId;

  const DashboardScreen({super.key, required this.serverId});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Watch loading state for this server for initial overlay
    final loadingState = ref.watch(
      serverLoadingProvider.select(
        (map) =>
            map[widget.serverId] ?? const ServerLoadingState(isLoading: true),
      ),
    );
    final isLoading = loadingState.isLoading && !loadingState.hasLoadedOnce;

    // 2. Watch SSH connection state for status banner
    final connState = ref.watch(serverConnectionStateProvider(widget.serverId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          ref.tr('system_monitor'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Loading spinner during background poll
          Consumer(
            builder: (context, ref, _) {
              final monitorState = ref.watch(serverMonitorViewModelProvider);
              return monitorState.isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(
              LucideIcons.moreVertical,
              color: AppTheme.textSecondary,
            ),
            onPressed: isLoading ? null : () => _showServerOptionsMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Connection State Banner ──────────────────────────────────
          _ConnectionStateBanner(connState: connState),

          // ── Main content ─────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () async {
                    ref
                        .read(serverMonitorViewModelProvider.notifier)
                        .clearServerHistory(widget.serverId);
                    ref.invalidate(serverHistoryProvider(widget.serverId));
                    ref.invalidate(serverStreamProvider(widget.serverId));
                    await ref
                        .read(serverMonitorViewModelProvider.notifier)
                        .reinitializeServer(widget.serverId);
                  },
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Header Info
                        SystemInfoMetricsCard(serverId: widget.serverId),
                        const SizedBox(
                          height: 32,
                        ), // Increased spacing for premium feel
                        // 2. CPU Chart
                        CpuMetricsCard(serverId: widget.serverId),
                        const SizedBox(height: 32),
                        // 3. Memory Usage
                        MemoryMetricsCard(serverId: widget.serverId),
                        const SizedBox(height: 32),
                        // 4. Disk Usage
                        DiskMetricsCard(serverId: widget.serverId),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 16,
                        ), // Bottom clearance for floating navbar
                      ],
                    ),
                  ),
                ),

                // Full-screen loading overlay — blocks interactions on first load
                if (isLoading)
                  Positioned.fill(
                    child: Container(
                      color: AppTheme.background.withValues(alpha: 0.9),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 48,
                              height: 48,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              ref.tr('establishing_connection'),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ref.tr('connecting_loading'),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (loadingState.errorMessage != null) ...[
                              const SizedBox(height: AppSizes.p16),
                              Container(
                                padding: const EdgeInsets.all(AppSizes.p12),
                                decoration: BoxDecoration(
                                  color: AppTheme.critical.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusMedium,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.critical.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.alertCircle,
                                      size: AppSizes.iconNormal,
                                      color: AppTheme.critical,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        loadingState.errorMessage!,
                                        style: const TextStyle(
                                          color: AppTheme.critical,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
              ], // closes Stack.children
            ), // closes Stack(
          ), // closes Expanded(
        ], // closes Column.children
      ), // closes body: Column(
    );
  }

  void _showServerOptionsMenu(BuildContext context) {
    final serverAsync = ref.read(serverStreamProvider(widget.serverId));
    final server = serverAsync.value;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0C).withValues(alpha: 0.82),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Drag handle ───────────────────────────────────────
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // ── Edit Server ───────────────────────────────────────
                    ListTile(
                      leading: const Icon(
                        LucideIcons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                      title: Text(
                        'Edit Connection',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (server != null) {
                          context.push('/add-server', extra: server);
                        }
                      },
                    ),
                    // ── Duplicate Server ──────────────────────────────────
                    ListTile(
                      leading: const Icon(
                        LucideIcons.copy,
                        color: Colors.white,
                        size: 20,
                      ),
                      title: Text(
                        'Duplicate',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (server != null) {
                          _duplicateServer(context, server);
                        }
                      },
                    ),
                    // ── Reboot Server ─────────────────────────────────────
                    ListTile(
                      leading: const Icon(
                        LucideIcons.refreshCw,
                        color: Colors.white,
                        size: 20,
                      ),
                      title: Text(
                        'Reboot',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (server != null) {
                          _showRebootConfirmDialog(context, server);
                        }
                      },
                    ),
                    // ── Divider before destructive ────────────────────────
                    Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.06),
                      indent: 20,
                      endIndent: 20,
                    ),
                    const SizedBox(height: 4),
                    // ── Power Off Server ──────────────────────────────────
                    ListTile(
                      leading: const Icon(
                        LucideIcons.power,
                        color: Color(0xFFFF5252),
                        size: 20,
                      ),
                      title: Text(
                        'Power Off',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF5252),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (server != null) {
                          _showPowerOffConfirmDialog(context, server);
                        }
                      },
                    ),
                    // ── Delete Server ─────────────────────────────────────
                    ListTile(
                      leading: const Icon(
                        LucideIcons.trash,
                        color: Color(0xFFFF5252),
                        size: 20,
                      ),
                      title: Text(
                        'Delete Server',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF5252),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showDeleteConfirmDialog(context);
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Text(
          'Delete Server',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this server? This action cannot be undone.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                color: AppTheme.critical,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final repository = await ref.read(
                serverRepositoryProvider.future,
              );
              await repository.deleteServer(widget.serverId);
              if (context.mounted) {
                context.go('/');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _duplicateServer(BuildContext context, Server server) async {
    try {
      final repository = await ref.read(serverRepositoryProvider.future);
      final fullServer = await repository.getServerWithCredentials(server.id);
      final newId = const Uuid().v4();
      final duplicated = fullServer.copyWith(
        id: newId,
        name: '${fullServer.name} (Copy)',
      );
      await repository.addServer(duplicated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Server duplicated as "${duplicated.name}"'),
            backgroundColor: AppTheme.terminalMint,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to duplicate server: $e'),
            backgroundColor: AppTheme.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showRebootConfirmDialog(
    BuildContext context,
    Server server,
  ) async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Text(
          'Reboot Server',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to reboot ${server.name}? Any running background processes will be interrupted.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          TextButton(
            child: Text(
              'Reboot',
              style: GoogleFonts.inter(
                color: AppTheme.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final ssh = ref.read(sshServiceProvider);
                await ssh.connectAndExecute(
                  server.hostname,
                  server.port,
                  server.username,
                  server.id,
                  'sudo reboot || reboot',
                  commandTimeoutSeconds: 5,
                );
              } catch (_) {
                // Sockets disconnect abruptly on reboot, which is normal
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reboot command sent to ${server.name}'),
                    backgroundColor: AppTheme.terminalMint,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showPowerOffConfirmDialog(
    BuildContext context,
    Server server,
  ) async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Text(
          'Power Off Server',
          style: GoogleFonts.inter(
            color: AppTheme.critical,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to power off ${server.name}? You will not be able to reconnect until it is manually powered on.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppTheme.textSecondary),
            ),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          TextButton(
            child: Text(
              'Power Off',
              style: GoogleFonts.inter(
                color: AppTheme.critical,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              try {
                final ssh = ref.read(sshServiceProvider);
                await ssh.connectAndExecute(
                  server.hostname,
                  server.port,
                  server.username,
                  server.id,
                  'sudo poweroff || poweroff',
                  commandTimeoutSeconds: 5,
                );
              } catch (_) {
                // Sockets disconnect abruptly on poweroff
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Power off command sent to ${server.name}'),
                    backgroundColor: AppTheme.critical,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Connection State Banner ────────────────────────────────────────────────────

/// Slim animated banner at the top of the dashboard body.
/// Hidden entirely when [SshConnectionState.connected]; coloured sliver otherwise.
class _ConnectionStateBanner extends StatelessWidget {
  final SshConnectionState connState;
  const _ConnectionStateBanner({required this.connState});

  @override
  Widget build(BuildContext context) {
    final isVisible = connState != SshConnectionState.connected;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isVisible ? _buildContent() : const SizedBox.shrink(),
    );
  }

  Widget _buildContent() {
    final (Color color, IconData icon, String label) = switch (connState) {
      SshConnectionState.offline => (
        AppTheme.critical,
        LucideIcons.wifiOff,
        'Offline — waiting for network',
      ),
      SshConnectionState.reconnecting => (
        AppTheme.warning,
        LucideIcons.refreshCw,
        'Reconnecting…',
      ),
      SshConnectionState.connecting => (
        AppTheme.textSecondary,
        LucideIcons.loader,
        'Connecting…',
      ),
      SshConnectionState.connected => (
        AppTheme.success,
        LucideIcons.checkCircle,
        'Connected',
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Refactored Metrics Widgets ───────────────────────────────────────────────

class SystemInfoMetricsCard extends ConsumerWidget {
  final String serverId;
  const SystemInfoMetricsCard({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverAsync = ref.watch(serverStreamProvider(serverId));

    return serverAsync.when(
      data: (server) {
        if (server == null) return const SizedBox.shrink();
        final currentStats = ServerStats(
          cpuPct: server.lastCpu ?? 0,
          ramPct: server.lastRam ?? 0,
          diskPct: server.lastDisk ?? 0,
          timestamp: server.lastSeen,
          latencyMs: server.lastLatency,
          uptime: server.uptime.isNotEmpty ? server.uptime : 'Unknown',
          hostname: server.hostnameInfo.isNotEmpty
              ? server.hostnameInfo
              : server.hostname,
          ipAddress: server.ipAddress.isNotEmpty ? server.ipAddress : '',
          osDistro: server.osDistro.isNotEmpty ? server.osDistro : 'Unknown',
          kernelVersion: server.kernelVersion.isNotEmpty
              ? server.kernelVersion
              : 'Unknown',
          serverLocation: server.serverLocation.isNotEmpty
              ? server.serverLocation
              : 'Unknown',
        );
        return FocalMetricHeader(stats: currentStats);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertCircle, color: AppTheme.critical),
            const SizedBox(height: 8),
            Text(
              ref.tr('error_loading_server'),
              style: AppTheme.infoLabelStyle,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                ref.invalidate(serverStreamProvider(serverId));
                ref.invalidate(serverHistoryProvider(serverId));
              },
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: Text(ref.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class CpuMetricsCard extends ConsumerStatefulWidget {
  final String serverId;
  const CpuMetricsCard({super.key, required this.serverId});

  @override
  ConsumerState<CpuMetricsCard> createState() => _CpuMetricsCardState();
}

class _CpuMetricsCardState extends ConsumerState<CpuMetricsCard> {
  bool _isExpanded = false;
  bool _isDynamicScale = true;
  ServerStats? _scrubbedStat;
  static final _scrubTimeFormat = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final serverAsync = ref.watch(serverStreamProvider(widget.serverId));
    final history = ref.watch(serverHistoryProvider(widget.serverId));

    return BaseMetricCard(
      title: ref.tr('cpu_usage'),
      height: 295,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      isExpanded: _isExpanded,
      onToggleExpansion: () => setState(() => _isExpanded = !_isExpanded),
      expansionChild: serverAsync.when(
        data: (server) {
          if (server == null) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetricRow(
                'CPU Model',
                server.cpuModel.isNotEmpty ? server.cpuModel : 'Generic CPU',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  height: 1,
                  color: AppTheme.border.withValues(alpha: 0.4),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricRow(
                      'Cores',
                      server.cpuCores > 0 ? '${server.cpuCores}' : 'Unknown',
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildMetricRow(
                      'Base Speed',
                      server.cpuSpeed.isNotEmpty ? server.cpuSpeed : 'N/A',
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
      child: serverAsync.when(
        data: (server) {
          final liveCpuPct = server?.lastCpu ?? 0.0;
          final displayedCpuPct = _scrubbedStat != null
              ? _scrubbedStat!.cpuPct
              : liveCpuPct;

          // Compute summary telemetry metrics across history window
          double? avgCpu;
          double? peakCpu;
          double? minCpu;
          if (history.isNotEmpty) {
            double sum = 0;
            double maxV = history.first.cpuPct;
            double minV = history.first.cpuPct;
            for (final s in history) {
              sum += s.cpuPct;
              if (s.cpuPct > maxV) maxV = s.cpuPct;
              if (s.cpuPct < minV) minV = s.cpuPct;
            }
            avgCpu = sum / history.length;
            peakCpu = maxV;
            minCpu = minV;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top control bar: Total Load / Scrub state + Scale Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _scrubbedStat != null && _scrubbedStat!.timestamp != null
                        ? 'Scrubbing (${_scrubTimeFormat.format(_scrubbedStat!.timestamp!)})'
                        : ref.tr('cpu_usage'),
                    style: AppTheme.cardTitleStyle,
                  ),

                  // Right: Dynamic Scale toggle pill button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isDynamicScale = !_isDynamicScale);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.zinc900.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isDynamicScale
                                  ? LucideIcons.maximize2
                                  : LucideIcons.minimize2,
                              size: 11,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isDynamicScale ? 'Auto Scale' : '100% Scale',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Metric Value & Summary Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Primary Reading
                  Text(
                    formatPercent(displayedCpuPct),
                    style: GoogleFonts.firaCode(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  // Telemetry mini-chips (AVG, PEAK, MIN)
                  if (avgCpu != null && peakCpu != null && minCpu != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatChip('AVG', '${avgCpu.toStringAsFixed(1)}%'),
                        const SizedBox(width: 6),
                        _buildStatChip(
                          'PEAK',
                          '${peakCpu.toStringAsFixed(1)}%',
                        ),
                        const SizedBox(width: 6),
                        _buildStatChip('MIN', '${minCpu.toStringAsFixed(1)}%'),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Interactive Line Chart with fl_chart
              Expanded(
                child: CpuLineChart(
                  history: history,
                  primaryColor: AppTheme.terminalMint,
                  isDynamicScale: _isDynamicScale,
                  valueFormatter: (val) => '${val.toStringAsFixed(1)}%',
                  onSpotSelected: (stat) =>
                      setState(() => _scrubbedStat = stat),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Icon(LucideIcons.alertCircle, color: AppTheme.critical),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.zinc900.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.firaCode(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class MemoryMetricsCard extends ConsumerStatefulWidget {
  final String serverId;
  const MemoryMetricsCard({super.key, required this.serverId});

  @override
  ConsumerState<MemoryMetricsCard> createState() => _MemoryMetricsCardState();
}

class _MemoryMetricsCardState extends ConsumerState<MemoryMetricsCard> {
  bool _isExpanded = false;
  bool _isDynamicScale = true;
  ServerStats? _scrubbedStat;
  static final _scrubTimeFormat = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final serverAsync = ref.watch(serverStreamProvider(widget.serverId));
    final history = ref.watch(serverHistoryProvider(widget.serverId));

    return BaseMetricCard(
      title: ref.tr('memory_usage'),
      height: 295,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      isExpanded: _isExpanded,
      onToggleExpansion: () => setState(() => _isExpanded = !_isExpanded),
      expansionChild: serverAsync.when(
        data: (server) {
          if (server == null) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricRow(
                      'Total RAM',
                      formatBytes(server.lastRamTotal),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _buildMetricRow(
                      'Used RAM',
                      formatBytes(server.lastRamUsed),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Divider(
                  height: 1,
                  color: AppTheme.border.withValues(alpha: 0.4),
                ),
              ),
              _buildMetricRow(
                'Free RAM',
                formatBytes(server.lastRamTotal - server.lastRamUsed),
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, _) => const SizedBox.shrink(),
      ),
      child: serverAsync.when(
        data: (server) {
          final liveRamPct = server?.lastRam ?? 0.0;
          final displayedRamPct = _scrubbedStat != null
              ? _scrubbedStat!.ramPct
              : liveRamPct;

          // Compute summary telemetry metrics across history window
          double? avgRam;
          double? peakRam;
          double? minRam;
          if (history.isNotEmpty) {
            double sum = 0;
            double maxV = history.first.ramPct;
            double minV = history.first.ramPct;
            for (final s in history) {
              sum += s.ramPct;
              if (s.ramPct > maxV) maxV = s.ramPct;
              if (s.ramPct < minV) minV = s.ramPct;
            }
            avgRam = sum / history.length;
            peakRam = maxV;
            minRam = minV;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top control bar: RAM Usage / Scrub state + Scale Mode Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _scrubbedStat != null && _scrubbedStat!.timestamp != null
                        ? 'Scrubbing (${_scrubTimeFormat.format(_scrubbedStat!.timestamp!)})'
                        : ref.tr('ram_usage'),
                    style: AppTheme.cardTitleStyle,
                  ),

                  // Right: Dynamic Scale toggle pill button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _isDynamicScale = !_isDynamicScale);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.zinc900.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isDynamicScale
                                  ? LucideIcons.maximize2
                                  : LucideIcons.minimize2,
                              size: 11,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isDynamicScale ? 'Auto Scale' : '100% Scale',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Metric Value & Summary Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Primary Reading
                  Text(
                    formatPercent(displayedRamPct),
                    style: GoogleFonts.firaCode(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),

                  // Telemetry mini-chips (AVG, PEAK, MIN)
                  if (avgRam != null && peakRam != null && minRam != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildStatChip('AVG', '${avgRam.toStringAsFixed(1)}%'),
                        const SizedBox(width: 6),
                        _buildStatChip(
                          'PEAK',
                          '${peakRam.toStringAsFixed(1)}%',
                        ),
                        const SizedBox(width: 6),
                        _buildStatChip('MIN', '${minRam.toStringAsFixed(1)}%'),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Interactive Line Chart with fl_chart
              Expanded(
                child: CpuLineChart(
                  history: history,
                  primaryColor: AppTheme.terminalMint,
                  isDynamicScale: _isDynamicScale,
                  getValue: (s) => s.ramPct,
                  emptyMessage: 'Collecting RAM telemetry...',
                  valueFormatter: (val) => '${val.toStringAsFixed(1)}%',
                  onSpotSelected: (stat) =>
                      setState(() => _scrubbedStat = stat),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Icon(LucideIcons.alertCircle, color: AppTheme.critical),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.zinc900.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
                letterSpacing: 0.3,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.firaCode(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class DiskMetricsCard extends ConsumerWidget {
  final String serverId;
  const DiskMetricsCard({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final diskAsync = ref.watch(
      serverStreamProvider(serverId).select(
        (v) => v.whenData(
          (s) => (
            diskPct: s?.lastDisk ?? 0.0,
            diskUsed: s?.lastDiskUsed ?? 0.0,
            diskTotal: s?.lastDiskTotal ?? 0.0,
          ),
        ),
      ),
    );

    return BaseMetricCard(
      title: ref.tr('disk_usage'),
      height: 300,
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: diskAsync.when(
        data: (data) {
          return DiskUsageGauge(
            usedValue: data.diskUsed.toDouble(),
            totalValue: data.diskTotal.toDouble(),
            percentage: data.diskPct.toDouble(),
            usedColor: AppTheme.terminalMint,
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Icon(LucideIcons.alertCircle, color: AppTheme.critical),
          ),
        ),
      ),
    );
  }
}
