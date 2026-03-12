import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/providers/server_loading_provider.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/features/dashboard/models/ssh_connection_state.dart';
import 'package:orbit/features/dashboard/providers/dashboard_providers.dart';
import 'package:orbit/features/dashboard/widgets/beszel_chart.dart';
import 'package:orbit/features/dashboard/widgets/system_info_card.dart';

import 'package:orbit/features/dashboard/presentation/widgets/base_metric_card.dart';

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
              LucideIcons.settings,
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
                    await Future.delayed(const Duration(milliseconds: 500));
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
                        const SizedBox(height: AppSizes.p24),
                        // 2. CPU Chart
                        CpuMetricsCard(serverId: widget.serverId),
                        const SizedBox(height: AppSizes.p24),
                        // 3. Memory Usage
                        MemoryMetricsCard(serverId: widget.serverId),
                        const SizedBox(height: AppSizes.p24),
                        // 4. Disk Usage
                        DiskMetricsCard(serverId: widget.serverId),
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
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusExtraLarge),
        ),
        side: BorderSide(color: AppTheme.border),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Drag handle ─────────────────────────────────────────
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // ── Edit Server ─────────────────────────────────────────
              ListTile(
                leading: const Icon(
                  LucideIcons.edit,
                  color: AppTheme.textPrimary,
                  size: 20,
                ),
                title: Text(
                  'Edit Server',
                  style: GoogleFonts.inter(
                    color: AppTheme.textPrimary,
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
              // ── Delete Server ────────────────────────────────────────
              ListTile(
                leading: const Icon(
                  LucideIcons.trash,
                  color: AppTheme.critical,
                  size: 20,
                ),
                title: Text(
                  'Delete Server',
                  style: GoogleFonts.inter(
                    color: AppTheme.critical,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmDialog(context);
                },
              ),
            ],
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p8,
      ),
      color: color.withValues(alpha: 0.12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color), // Keeping small icon
          const SizedBox(width: AppSizes.p8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
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
        return SystemInfoCard(stats: currentStats);
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

class CpuMetricsCard extends ConsumerWidget {
  final String serverId;
  const CpuMetricsCard({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cpuAsync = ref.watch(
      serverStreamProvider(
        serverId,
      ).select((v) => v.whenData((s) => s?.lastCpu ?? 0.0)),
    );
    final history = ref.watch(serverHistoryProvider(serverId));

    return BaseMetricCard(
      title: ref.tr('cpu_usage'),
      child: cpuAsync.when(
        data: (cpuPct) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(ref.tr('total_load'), style: AppTheme.cardTitleStyle),
                Text(formatPercent(cpuPct), style: AppTheme.cardValueStyle),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BeszelChart(
                history: history,
                primaryColor: AppTheme.cpuColor,
                getValue: (s) => s.cpuPct,
                valueFormatter: (val) => '${val.toStringAsFixed(2)}%',
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Icon(LucideIcons.alertCircle, color: AppTheme.critical),
        ),
      ),
    );
  }
}

class MemoryMetricsCard extends ConsumerWidget {
  final String serverId;
  const MemoryMetricsCard({super.key, required this.serverId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ramAsync = ref.watch(
      serverStreamProvider(
        serverId,
      ).select((v) => v.whenData((s) => s?.lastRam ?? 0.0)),
    );
    final history = ref.watch(serverHistoryProvider(serverId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BaseMetricCard(
          title: ref.tr('memory_usage'),
          child: ramAsync.when(
            data: (ramPct) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ref.tr('ram_usage'), style: AppTheme.cardTitleStyle),
                    Text(formatPercent(ramPct), style: AppTheme.cardValueStyle),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BeszelChart(
                    history: history,
                    primaryColor: AppTheme.ramColor,
                    getValue: (s) => s.ramPct,
                    valueFormatter: (val) => '${val.toStringAsFixed(2)}%',
                  ),
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => const Center(
              child: Icon(LucideIcons.alertCircle, color: AppTheme.critical),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ramAsync.when(
          data: (ramPct) {
            final isHighMemory = ramPct > 80;
            return Card(
              color: AppTheme.surface,
              elevation: AppSizes.cardElevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                side: const BorderSide(color: AppTheme.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.p16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (ramPct / 100).clamp(0.0, 1.0),
                        backgroundColor: AppTheme.background,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isHighMemory ? AppTheme.critical : AppTheme.primary,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Icon(
                              LucideIcons.memoryStick,
                              size: 20,
                              color: isHighMemory
                                  ? AppTheme.critical
                                  : AppTheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ref.tr('used'),
                              style: AppTheme.infoLabelStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ramPct.toStringAsFixed(1)}%',
                              style: AppTheme.infoValueStyle.copyWith(
                                color: isHighMemory
                                    ? AppTheme.critical
                                    : AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 40, color: AppTheme.border),
                        Column(
                          children: [
                            Icon(
                              LucideIcons.checkCircle,
                              size: 20,
                              color: AppTheme.success,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ref.tr('available'),
                              style: AppTheme.infoLabelStyle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${(100 - ramPct).toStringAsFixed(1)}%',
                              style: AppTheme.infoValueStyle.copyWith(
                                color: AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
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
            diskUsed: s?.lastDiskUsed ?? 0,
            diskTotal: s?.lastDiskTotal ?? 0,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        diskAsync.when(
          data: (data) {
            final diskPct = data.diskPct;
            final diskUsed = data.diskUsed;
            final diskTotal = data.diskTotal;
            final isCritical = diskPct > 85;

            return BaseMetricCard(
              title: ref.tr('disk_usage'),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.hardDrive,
                            size: 20,
                            color: isCritical
                                ? AppTheme.critical
                                : AppTheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            ref.tr('root_partition'),
                            style: AppTheme.infoValueStyle.copyWith(
                              fontSize: 15,
                              color: isCritical
                                  ? AppTheme.critical
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        formatPercent(diskPct),
                        style: AppTheme.cardValueStyle.copyWith(
                          color: isCritical
                              ? AppTheme.critical
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (diskPct / 100).clamp(0.0, 1.0),
                      backgroundColor: AppTheme.background,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCritical ? AppTheme.critical : AppTheme.primary,
                      ),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(
                            LucideIcons.folder,
                            size: 20,
                            color: isCritical
                                ? AppTheme.critical
                                : AppTheme.warning,
                          ),
                          const SizedBox(height: 8),
                          Text(ref.tr('used'), style: AppTheme.infoLabelStyle),
                          const SizedBox(height: 4),
                          Text(
                            formatBytes(diskUsed),
                            style: AppTheme.infoValueStyle.copyWith(
                              color: isCritical
                                  ? AppTheme.critical
                                  : AppTheme.warning,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: AppTheme.border),
                      Column(
                        children: [
                          Icon(
                            LucideIcons.checkCircle,
                            size: 20,
                            color: isCritical
                                ? AppTheme.warning
                                : AppTheme.success,
                          ),
                          const SizedBox(height: 8),
                          Text(ref.tr('free'), style: AppTheme.infoLabelStyle),
                          const SizedBox(height: 4),
                          Text(
                            formatBytes(diskTotal - diskUsed),
                            style: AppTheme.infoValueStyle.copyWith(
                              color: isCritical
                                  ? AppTheme.warning
                                  : AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Critical warning
                  if (isCritical) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.critical.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.critical.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.alertTriangle,
                            color: AppTheme.critical,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Disk Space Critical',
                                  style: TextStyle(
                                    color: AppTheme.critical,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Less than 15% free space remaining',
                                  style: TextStyle(
                                    color: AppTheme.critical,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const BaseMetricCard(
            title: '',
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => const BaseMetricCard(
            title: '',
            child: Center(
              child: Icon(LucideIcons.alertCircle, color: AppTheme.critical),
            ),
          ),
        ),
      ],
    );
  }
}
