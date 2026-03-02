import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

class SystemInfoCard extends StatelessWidget {
  final ServerStats stats;

  const SystemInfoCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Information',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildInfoItem(
                context,
                icon: LucideIcons.server,
                label: 'Hostname',
                value: stats.hostname.isEmpty ? 'Unknown' : stats.hostname,
              ),
              _buildInfoItem(
                context,
                icon: LucideIcons.globe,
                label: 'IP Address',
                value: stats.ipAddress.isEmpty ? 'Unknown' : stats.ipAddress,
              ),
              _buildInfoItem(
                context,
                icon: LucideIcons.monitor,
                label: 'Distro',
                value: stats.osDistro.isEmpty ? 'Unknown' : stats.osDistro,
              ),
              _buildInfoItem(
                context,
                icon: LucideIcons.cpu,
                label: 'Kernel',
                value: stats.kernelVersion.isEmpty
                    ? 'Unknown'
                    : stats.kernelVersion,
              ),
              _buildInfoItem(
                context,
                icon: LucideIcons.mapPin,
                label: 'Location',
                value: stats.serverLocation.isEmpty
                    ? 'Unknown'
                    : stats.serverLocation,
              ),
              _buildInfoItem(
                context,
                icon: LucideIcons.clock,
                label: 'Uptime',
                value: stats.uptime.isEmpty ? 'N/A' : stats.uptime,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
