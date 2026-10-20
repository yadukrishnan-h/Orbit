import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

class FocalMetricHeader extends ConsumerWidget {
  final ServerStats stats;

  const FocalMetricHeader({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The massive focal metric (Total Load)
        Text(
          'Total Load',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF8E8E93),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${stats.cpuPct.toStringAsFixed(1)}%',
          style: GoogleFonts.inter(
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 24),

        // Secondary Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSecondaryStat(
              context,
              icon: LucideIcons.activity,
              label: 'UPTIME',
              value: stats.uptime.isEmpty ? 'N/A' : stats.uptime,
            ),
            _buildSecondaryStat(
              context,
              icon: LucideIcons.monitor,
              label: 'DISTRO',
              value: stats.osDistro.isEmpty ? 'Unknown' : stats.osDistro,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSecondaryStat(
              context,
              icon: LucideIcons.globe,
              label: 'IP ADDRESS',
              value: stats.ipAddress.isEmpty ? 'Unknown' : stats.ipAddress,
            ),
            _buildSecondaryStat(
              context,
              icon: LucideIcons.server,
              label: 'HOSTNAME',
              value: stats.hostname.isEmpty ? 'Unknown' : stats.hostname,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSecondaryStat(
              context,
              icon: LucideIcons.cpu,
              label: 'KERNEL',
              value: stats.kernelVersion.isEmpty
                  ? 'Unknown'
                  : stats.kernelVersion,
              isMonospace: true,
            ),
            _buildSecondaryStat(
              context,
              icon: LucideIcons.mapPin,
              label: 'LOCATION',
              value: stats.serverLocation.isEmpty
                  ? 'Unknown'
                  : stats.serverLocation,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryStat(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMonospace = false,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6C7280),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: isMonospace
                      ? GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        )
                      : GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
