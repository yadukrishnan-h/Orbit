import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

class SystemInfoCard extends ConsumerWidget {
  final ServerStats stats;

  const SystemInfoCard({
    super.key,
    required this.stats,
  });

  // Cache text styles as static finals
  static final TextStyle _labelStyle = AppTheme.infoLabelStyle;
  static final TextStyle _valueStyle = AppTheme.infoValueStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
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
            children: [
              _buildInfoItem(
                context,
                icon: LucideIcons.server,
                label: ref.tr('hostname'),
                value:
                    stats.hostname.isEmpty ? ref.tr('unknown') : stats.hostname,
              ),
              const Divider(color: AppTheme.border, height: 24),
              _buildInfoItem(
                context,
                icon: LucideIcons.globe,
                label: ref.tr('ip_address'),
                value: stats.ipAddress.isEmpty
                    ? ref.tr('unknown')
                    : stats.ipAddress,
              ),
              const Divider(color: AppTheme.border, height: 24),
              _buildInfoItem(
                context,
                icon: LucideIcons.monitor,
                label: ref.tr('distro'),
                value:
                    stats.osDistro.isEmpty ? ref.tr('unknown') : stats.osDistro,
              ),
              const Divider(color: AppTheme.border, height: 24),
              _buildInfoItem(
                context,
                icon: LucideIcons.cpu,
                label: ref.tr('kernel'),
                value: stats.kernelVersion.isEmpty
                    ? ref.tr('unknown')
                    : stats.kernelVersion,
              ),
              const Divider(color: AppTheme.border, height: 24),
              _buildInfoItem(
                context,
                icon: LucideIcons.mapPin,
                label: ref.tr('location'),
                value: stats.serverLocation.isEmpty
                    ? ref.tr('unknown')
                    : stats.serverLocation,
              ),
              const Divider(color: AppTheme.border, height: 24),
              _buildInfoItem(
                context,
                icon: LucideIcons.clock,
                label: ref.tr('uptime'),
                value: stats.uptime.isEmpty ? 'N/A' : stats.uptime,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: _labelStyle),
        const Spacer(),
        Text(
          value,
          style: _valueStyle,
        ),
      ],
    );
  }
}
