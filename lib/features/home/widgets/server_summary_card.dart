import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/providers/server_loading_provider.dart';
import 'package:orbit/core/widgets/system_card.dart';

class ServerSummaryCard extends ConsumerStatefulWidget {
  final Server server;

  const ServerSummaryCard({super.key, required this.server});

  @override
  ConsumerState<ServerSummaryCard> createState() => _ServerSummaryCardState();
}

class _ServerSummaryCardState extends ConsumerState<ServerSummaryCard> {
  // Cache expensive calculations
  late bool _isStale;
  late Color _statusColor;
  late String _statusText;
  late String _timeAgoText;

  @override
  void initState() {
    super.initState();
    _updateCalculatedValues();
  }

  @override
  void didUpdateWidget(ServerSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.server != widget.server) {
      _updateCalculatedValues();
    }
  }

  void _updateCalculatedValues() {
    _statusColor = _getStatusColor(widget.server.status);
    _statusText = _getStatusText(widget.server.status);
    _isStale = widget.server.lastSeen != null &&
        DateTime.now().difference(widget.server.lastSeen!).inMinutes > 5;
    _timeAgoText = widget.server.lastSeen != null
        ? _formatTimeAgo(widget.server.lastSeen!)
        : 'Never';
  }

  @override
  Widget build(BuildContext context) {
    final loadingState = ref.watch(serverLoadingProvider)[widget.server.id] ??
        const ServerLoadingState(isLoading: true);
    final isLoading = loadingState.isLoading && !loadingState.hasLoadedOnce;

    return Opacity(
      opacity: isLoading ? 0.5 : (_isStale ? 0.7 : 1.0),
      child: SystemCard(
        onTap: isLoading
            ? null
            : () => context.push('/dashboard/${widget.server.id}',
                extra: widget.server),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Status Dot + Name + Menu
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _statusColor.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.server.name,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildPopupMenu(),
              ],
            ),
            const SizedBox(height: 16),

            // Metrics Grid-like display
            _buildMetricRow(
              LucideIcons.cpu,
              'CPU',
              widget.server.lastCpu ?? 0,
              AppTheme.cpuColor,
            ),
            const SizedBox(height: 10),
            _buildMetricRow(
              LucideIcons.memoryStick,
              'RAM',
              widget.server.lastRam ?? 0,
              AppTheme.success,
            ),
            const SizedBox(height: 10),
            _buildMetricRow(
              LucideIcons.hardDrive,
              'Disk',
              widget.server.lastDisk ?? 0,
              AppTheme.warning,
            ),
            const SizedBox(height: 16),

            // Footer: Status and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFooterStat(LucideIcons.activity, _statusText,
                    color: _statusColor),
                _buildFooterStat(LucideIcons.clock, _timeAgoText),
              ],
            ),

            // Error Message (if any)
            if (loadingState.errorMessage != null &&
                !loadingState.hasLoadedOnce)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.critical.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 14, color: AppTheme.critical),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Connection Failed',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.critical,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(
        LucideIcons.moreHorizontal,
        size: 18,
        color: AppTheme.textSecondary,
      ),
      onSelected: _handleMenuAction,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              const Icon(LucideIcons.info, size: 16),
              const SizedBox(width: 12),
              Text('Details', style: GoogleFonts.inter(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(LucideIcons.edit, size: 16),
              const SizedBox(width: 12),
              Text('Edit Server', style: GoogleFonts.inter(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(LucideIcons.trash2,
                  size: 16, color: AppTheme.critical),
              const SizedBox(width: 12),
              Text('Delete',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.critical)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(
      IconData icon, String label, double percentage, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            label,
            style:
                GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppTheme.border,
              color: color,
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 45,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: AppTheme.infoValueStyle.copyWith(fontSize: 11),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterStat(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color ?? AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: color ?? AppTheme.textSecondary,
            fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Future<void> _handleMenuAction(String value) async {
    if (value == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: Text(
            'Delete Server',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete ${widget.server.name}?',
            style: GoogleFonts.inter(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              child: Text('Cancel',
                  style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: Text('Delete',
                  style: GoogleFonts.inter(
                      color: AppTheme.critical, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (confirm == true && mounted) {
        final repository = await ref.read(serverRepositoryProvider.future);
        await repository.deleteServer(widget.server.id);
      }
    } else if (value == 'details') {
      // Navigate to details screen
      context.push('/server-details', extra: widget.server);
    } else if (value == 'edit') {
      // Navigate to add-server screen in edit mode
      context.push('/add-server', extra: widget.server);
    }
  }

  Color _getStatusColor(ServerStatus status) {
    return switch (status) {
      ServerStatus.online => AppTheme.success,
      ServerStatus.offline => AppTheme.disabled,
      ServerStatus.error => AppTheme.critical,
      ServerStatus.unknown => AppTheme.textSecondary,
    };
  }

  String _getStatusText(ServerStatus status) {
    return switch (status) {
      ServerStatus.online => 'Online',
      ServerStatus.offline => 'Offline',
      ServerStatus.error => 'Error',
      ServerStatus.unknown => 'Unknown',
    };
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
