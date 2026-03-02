import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/providers/server_loading_provider.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/features/dashboard/models/ssh_connection_state.dart';
import 'package:orbit/features/dashboard/providers/dashboard_providers.dart';
import 'package:orbit/features/dashboard/widgets/beszel_chart.dart';
import 'package:orbit/features/dashboard/widgets/system_info_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  final String serverId;

  const DashboardScreen({
    super.key,
    required this.serverId,
  });

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  // Cache text styles to avoid recreating on every build
  late final TextStyle _sectionTitleStyle;
  late final TextStyle _cardTitleStyle;
  late final TextStyle _cardValueStyle;
  late final TextStyle _infoLabelStyle;
  late final TextStyle _infoValueStyle;

  @override
  void initState() {
    super.initState();
    _sectionTitleStyle = AppTheme.sectionHeaderStyle;
    _cardTitleStyle = AppTheme.cardTitleStyle;
    _cardValueStyle = AppTheme.cardValueStyle;
    _infoLabelStyle = AppTheme.infoLabelStyle;
    _infoValueStyle = AppTheme.infoValueStyle;
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch Data Streams
    final serverAsync = ref.watch(serverStreamProvider(widget.serverId));
    final history = ref.watch(serverHistoryProvider(widget.serverId));

    // 2. Watch loading state for this server
    final loadingState = ref.watch(serverLoadingProvider)[widget.serverId] ??
        const ServerLoadingState(isLoading: true);
    final isLoading = loadingState.isLoading && !loadingState.hasLoadedOnce;

    // 3. Watch SSH connection state for status banner
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
          Consumer(builder: (context, ref, _) {
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
          }),
          IconButton(
            icon:
                const Icon(LucideIcons.settings, color: AppTheme.textSecondary),
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
                    ref.invalidate(serverHistoryProvider(widget.serverId));
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  color: AppTheme.primary,
                  backgroundColor: AppTheme.surface,
                  child: serverAsync.when(
                    data: (server) {
                      if (server == null) {
                        return Center(child: Text(ref.tr('server_not_found')));
                      }

                      final currentStats = ServerStats(
                        cpuPct: server.lastCpu ?? 0,
                        ramPct: server.lastRam ?? 0,
                        diskPct: server.lastDisk ?? 0,
                        timestamp: server.lastSeen,
                        latencyMs: server.lastLatency,
                        uptime: server.uptime.isNotEmpty
                            ? server.uptime
                            : 'Unknown',
                        hostname: server.hostnameInfo.isNotEmpty
                            ? server.hostnameInfo
                            : server.hostname,
                        ipAddress:
                            server.ipAddress.isNotEmpty ? server.ipAddress : '',
                        osDistro: server.osDistro.isNotEmpty
                            ? server.osDistro
                            : 'Unknown',
                        kernelVersion: server.kernelVersion.isNotEmpty
                            ? server.kernelVersion
                            : 'Unknown',
                        serverLocation: server.serverLocation.isNotEmpty
                            ? server.serverLocation
                            : 'Unknown',
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Header Info
                            SystemInfoCard(stats: currentStats),
                            const SizedBox(height: 24),
                            // 2. CPU Chart
                            _buildSectionTitle(ref.tr('cpu_usage')),
                            const SizedBox(height: 8),
                            _buildChartCard(
                              title: ref.tr('total_load'),
                              value: formatPercent(server.lastCpu ?? 0),
                              child: BeszelChart(
                                history: history,
                                primaryColor: const Color(0xFF6366F1),
                                getValue: (s) => s.cpuPct,
                                valueFormatter: (val) =>
                                    '${val.toStringAsFixed(2)}%',
                              ),
                            ),
                            const SizedBox(height: 24),
                            // 3. Memory Usage
                            _buildMemorySection(server, history),
                            const SizedBox(height: 24),
                            // 4. Disk Usage
                            _buildDiskSection(server),
                          ],
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.alertCircle,
                              size: 48, color: AppTheme.critical),
                          const SizedBox(height: 16),
                          Text(
                            ref.tr('error_loading_server'),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$err',
                            style: const TextStyle(
                              color: AppTheme.critical,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              ref.invalidate(
                                  serverStreamProvider(widget.serverId));
                              ref.invalidate(
                                  serverHistoryProvider(widget.serverId));
                            },
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: Text(ref.tr('retry')),
                          ),
                        ],
                      ),
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
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppTheme.critical.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.critical
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      LucideIcons.alertCircle,
                                      size: 20,
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

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(), style: _sectionTitleStyle);
  }

  Widget _buildChartCard({
    required String title,
    required String value,
    required Widget child,
  }) {
    return SizedBox(
      height: 200,
      child: Card(
        color: AppTheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: _cardTitleStyle),
                  Text(value, style: _cardValueStyle),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemorySection(Server server, List<ServerStats> history) {
    final ramPct = server.lastRam ?? 0;
    final isHighMemory = ramPct > 80;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(ref.tr('memory_usage')),
        const SizedBox(height: 8),
        _buildChartCard(
          title: ref.tr('ram_usage'),
          value: formatPercent(ramPct),
          child: BeszelChart(
            history: history,
            primaryColor: const Color(0xFF10B981),
            getValue: (s) => s.ramPct,
            valueFormatter: (val) => '${val.toStringAsFixed(2)}%',
          ),
        ),
        const SizedBox(height: 16),
        _buildMemoryInfoCard(ramPct, isHighMemory),
      ],
    );
  }

  Widget _buildMemoryInfoCard(double ramPct, bool isHighMemory) {
    return Card(
      color: AppTheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                _buildMemoryStat(
                  icon: LucideIcons.memoryStick,
                  label: ref.tr('used'),
                  value: '${ramPct.toStringAsFixed(1)}%',
                  color: isHighMemory ? AppTheme.critical : AppTheme.primary,
                ),
                _buildDivider(),
                _buildMemoryStat(
                  icon: LucideIcons.checkCircle,
                  label: ref.tr('available'),
                  value: '${(100 - ramPct).toStringAsFixed(1)}%',
                  color: AppTheme.success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(label, style: _infoLabelStyle),
        const SizedBox(height: 4),
        Text(value, style: _infoValueStyle.copyWith(color: color)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: AppTheme.border);
  }

  Widget _buildDiskSection(Server server) {
    final diskPct = server.lastDisk ?? 0;
    final diskUsed = server.lastDiskUsed;
    final diskTotal = server.lastDiskTotal;
    final isCritical = diskPct > 85;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(ref.tr('disk_usage')),
        const SizedBox(height: 8),
        _buildDiskInfoCard(diskPct, diskUsed, diskTotal, isCritical),
      ],
    );
  }

  Widget _buildDiskInfoCard(
      double diskPct, int diskUsed, int diskTotal, bool isCritical) {
    return Card(
      color: AppTheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      color: isCritical ? AppTheme.critical : AppTheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      ref.tr('root_partition'),
                      style: _infoValueStyle.copyWith(
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
                  style: _cardValueStyle.copyWith(
                    color:
                        isCritical ? AppTheme.critical : AppTheme.textPrimary,
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
                _buildDiskStat(
                  icon: LucideIcons.folder,
                  label: ref.tr('used'),
                  value: formatBytes(diskUsed),
                  color: isCritical ? AppTheme.critical : AppTheme.warning,
                ),
                _buildDivider(),
                _buildDiskStat(
                  icon: LucideIcons.checkCircle,
                  label: ref.tr('free'),
                  value: formatBytes(diskTotal - diskUsed),
                  color: isCritical ? AppTheme.warning : AppTheme.success,
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
                      color: AppTheme.critical.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.alertTriangle,
                      color: AppTheme.critical,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
      ),
    );
  }

  Widget _buildDiskStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 8),
        Text(label, style: _infoLabelStyle),
        const SizedBox(height: 4),
        Text(value, style: _infoValueStyle.copyWith(color: color)),
      ],
    );
  }

  void _showServerOptionsMenu(BuildContext context) {
    final serverAsync = ref.read(serverStreamProvider(widget.serverId));
    final server = serverAsync.valueOrNull;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppTheme.border),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                leading: const Icon(LucideIcons.edit,
                    color: AppTheme.textPrimary, size: 20),
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
                leading: const Icon(LucideIcons.trash,
                    color: AppTheme.critical, size: 20),
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
          borderRadius: BorderRadius.circular(12),
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
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
            onPressed: () => Navigator.pop(dialogCtx),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                  color: AppTheme.critical, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final repository =
                  await ref.read(serverRepositoryProvider.future);
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
          const Color(0xFFEF4444),
          LucideIcons.wifiOff,
          'Offline — waiting for network',
        ),
      SshConnectionState.reconnecting => (
          const Color(0xFFF59E0B),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color.withValues(alpha: 0.12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
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
