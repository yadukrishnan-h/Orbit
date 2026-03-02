import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

class ServerCard extends StatelessWidget {
  final String name;
  final ServerStats currentStats;
  final List<ServerStats> history;

  const ServerCard({
    super.key,
    required this.name,
    required this.currentStats,
    required this.history,
  });

  Color get _statusColor {
    // Basic status derivation: If uptime is empty, assume connecting/offline
    return currentStats.uptime.isEmpty ? AppTheme.critical : AppTheme.success;
  }

  @override
  Widget build(BuildContext context) {
    // Custom Container instead of Card for pixel-perfect control
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        border:
            Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
              ),
              const Spacer(),
              const Icon(LucideIcons.server,
                  size: 16, color: AppTheme.textSecondary),
            ],
          ),

          // Divider (Distinct separation)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
                color: Theme.of(context).colorScheme.outline,
                height: 1,
                thickness: 1),
          ),

          // Metrics Row
          Row(
            children: [
              _buildMetricColumn(context, 'CPU', currentStats.cpuPct,
                  AppTheme.cpuColor, (s) => s.cpuPct),
              const SizedBox(width: 12),
              _buildMetricColumn(context, 'RAM', currentStats.ramPct,
                  AppTheme.ramColor, (s) => s.ramPct),
              const SizedBox(width: 12),
              _buildMetricColumn(context, 'Disk', currentStats.diskPct,
                  Theme.of(context).colorScheme.primary, (s) => s.diskPct),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(BuildContext context, String label, double value,
      Color color, double Function(ServerStats) selector) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toInt()}%',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // Area Chart Sparkline
          SizedBox(
            height: 40,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getHistorySpots(selector),
                    isCurved: true,
                    curveSmoothness: 0.25,
                    color: color,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.3),
                          color.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                minY: 0,
                maxY: 100,
                minX: 0,
                maxX: 19, // Fixed window size 20 items (0-19)
                lineTouchData: const LineTouchData(enabled: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getHistorySpots(double Function(ServerStats) selector) {
    if (history.isEmpty) return [const FlSpot(0, 0)];

    // Map history to spots. We want the chart to fill from right to left or just standard.
    // Standard: Index 0 is oldest, Index N is newest.
    // If we have fewer than 20 items, we can pad or just show what we have.
    // Let's just map current history to indices.

    return history.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), selector(entry.value));
    }).toList();
  }
}
