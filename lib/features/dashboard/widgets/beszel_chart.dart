import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

class BeszelChart extends StatelessWidget {
  final List<ServerStats> history;
  final Color primaryColor;
  final String Function(double)? valueFormatter;
  final double Function(ServerStats) getValue;
  final double maxY;
  final bool autoZoom;

  /// Maximum allowed gap between data points in seconds.
  /// If the time gap exceeds this, the graph line will be broken.
  final Duration maxDataGap;

  const BeszelChart({
    super.key,
    required this.history,
    required this.primaryColor,
    required this.getValue,
    this.valueFormatter,
    this.maxY = 100,
    this.autoZoom = true,
    this.maxDataGap = const Duration(seconds: 10), // Default: break if >10s gap
  });

  // Cache common styles and formatters
  static const _axisStyle = TextStyle(
    color: AppTheme.textSecondary,
    fontWeight: FontWeight.bold,
    fontSize: 10,
  );

  static const _tooltipTimeStyle = TextStyle(
    color: AppTheme.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static final _timeFormat = DateFormat('HH:mm:ss');
  static final _timeFormatShort = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Data Spots with gap detection
    final List<List<FlSpot>> spotGroups = _createSpotGroupsWithGaps();

    // Flatten all spots for zoom calculation
    final allSpots = spotGroups.expand((group) => group).toList();

    // 2. Calculate auto-zoom Y-axis range based on data
    final ZoomRange zoomRange = _calculateZoomRange(allSpots);
    final double effectiveMaxY = autoZoom ? zoomRange.maxY : maxY;
    final double effectiveMinY = autoZoom ? zoomRange.minY : 0;
    final double horizontalInterval = autoZoom ? zoomRange.interval : 25;

    // 3. Define Gradient
    final gradientColors = [
      primaryColor.withValues(alpha: 0.3),
      primaryColor.withValues(alpha: 0.0),
    ];

    return RepaintBoundary(
      child: LineChart(
        duration: const Duration(milliseconds: 300),
        LineChartData(
          // Grid Configuration
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: horizontalInterval,
            verticalInterval: (history.length / 4).clamp(1, double.infinity),
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Colors.white10,
                strokeWidth: 1,
              );
            },
          ),

          // Tooltip Configuration
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppTheme.surface,
              tooltipBorder: const BorderSide(color: AppTheme.border),
              tooltipPadding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  // Find the actual stat from the flattened history
                  final index = touchedSpot.x.toInt();
                  if (index < 0 || index >= history.length) return null;

                  final stat = history[index];
                  final timeStr = stat.timestamp != null
                      ? _timeFormat.format(stat.timestamp!)
                      : 'Unknown';

                  return LineTooltipItem(
                    '${valueFormatter?.call(touchedSpot.y) ?? touchedSpot.y.toStringAsFixed(1)}\n',
                    TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: timeStr,
                        style: _tooltipTimeStyle,
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),

          // Titles (Axis Labels)
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Y-Axis Labels
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: horizontalInterval,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == maxY && history.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    valueFormatter != null
                        ? valueFormatter!(value)
                        : '${value.toStringAsFixed(1)}%',
                    style: _axisStyle,
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),

            // X-Axis Labels (Time)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: (history.length / 4).clamp(1, double.infinity),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < history.length) {
                    final stat = history[index];
                    if (stat.timestamp == null) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _timeFormatShort.format(stat.timestamp!),
                        style: _axisStyle,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // Border
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white10),
          ),

          // Range
          minX: 0,
          maxX: (history.length - 1).toDouble(),
          minY: effectiveMinY,
          maxY: effectiveMaxY,

          // The Line Data - multiple bars for broken lines
          lineBarsData: spotGroups.map((spots) {
            return LineChartBarData(
              spots: spots,
              isCurved: true,
              color: primaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Create spot groups with gaps detected based on time intervals
  /// Returns a list of spot groups, where each group is a continuous line segment
  List<List<FlSpot>> _createSpotGroupsWithGaps() {
    if (history.isEmpty) return [];

    final List<List<FlSpot>> spotGroups = [];
    List<FlSpot> currentGroup = [];

    for (int i = 0; i < history.length; i++) {
      final stat = history[i];
      final spot = FlSpot(i.toDouble(), getValue(stat));

      if (currentGroup.isEmpty) {
        // Start new group
        currentGroup.add(spot);
      } else {
        // Check if there's a time gap
        final previousStat = history[i - 1];
        final hasGap = _hasTimeGap(previousStat, stat);

        if (hasGap) {
          // Save current group and start a new one
          if (currentGroup.isNotEmpty) {
            spotGroups.add(List.from(currentGroup));
          }
          currentGroup.clear();
          currentGroup.add(spot);
        } else {
          // Continue the current line
          currentGroup.add(spot);
        }
      }
    }

    // Don't forget the last group
    if (currentGroup.isNotEmpty) {
      spotGroups.add(currentGroup);
    }

    return spotGroups;
  }

  /// Check if there's a significant time gap between two stats
  bool _hasTimeGap(ServerStats previous, ServerStats current) {
    if (previous.timestamp == null || current.timestamp == null) {
      return false; // Can't determine gap without timestamps
    }

    final gap = current.timestamp!.difference(previous.timestamp!);
    return gap > maxDataGap;
  }

  /// Calculate optimal Y-axis range based on data values for auto-zoom
  ZoomRange _calculateZoomRange(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return const ZoomRange(minY: 0, maxY: 100, interval: 25);
    }

    // Find min and max values in the data
    double minValue = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxValue = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    // Add padding around the data (10% of range)
    double range = maxValue - minValue;
    if (range < 1) range = 1; // Minimum range of 1 for better visibility

    double padding = range * 0.1;
    double minY = (minValue - padding).clamp(0, 100);
    double maxY = (maxValue + padding).clamp(0, 100);

    // Ensure we don't exceed 100% for percentage charts
    if (maxY > 100) {
      maxY = 100;
      minY = (maxY - range * 1.2).clamp(0, 100);
    }

    // Calculate nice interval based on range
    double interval;
    double normalizedRange = maxY - minY;

    if (normalizedRange <= 10) {
      interval = 2;
    } else if (normalizedRange <= 20) {
      interval = 5;
    } else if (normalizedRange <= 50) {
      interval = 10;
    } else {
      interval = 25;
    }

    // Round minY and maxY to nearest interval for clean axis labels
    minY = (minY / interval).floor() * interval;
    maxY = ((maxY / interval).ceil() + 1) * interval;

    // Final clamp to valid percentage range
    minY = minY.clamp(0, 100);
    maxY = maxY.clamp(0, 100);

    return ZoomRange(minY: minY, maxY: maxY, interval: interval);
  }
}

/// Helper class to hold zoom range configuration
class ZoomRange {
  final double minY;
  final double maxY;
  final double interval;

  const ZoomRange({
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}
