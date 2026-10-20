import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

/// A modern, high-performance telemetry line chart utilizing fl_chart.
///
/// Features:
/// - Dynamic Y-axis scale bounds that adjust smoothly to current telemetry range.
/// - Clear X-axis time intervals formatted cleanly to avoid label collisions.
/// - Smooth cubic bezier splines with curve overshooting prevention.
/// - Subtle linear gradient fill under the line for visual depth.
/// - Interactive touch-indicator & scrub feedback with precise timestamp and value tooltip.
/// - Haptic feedback on data scrubbing.
/// - Data gap handling across connection dropouts.
class CpuLineChart extends StatefulWidget {
  final List<ServerStats> history;
  final Color primaryColor;
  final bool isDynamicScale;
  final Duration maxDataGap;
  final String Function(double)? valueFormatter;
  final void Function(ServerStats? selectedStat)? onSpotSelected;
  final double Function(ServerStats stat)? getValue;
  final String? emptyMessage;

  const CpuLineChart({
    super.key,
    required this.history,
    this.primaryColor = AppTheme.terminalMint,
    this.isDynamicScale = true,
    this.maxDataGap = const Duration(seconds: 15),
    this.valueFormatter,
    this.onSpotSelected,
    this.getValue,
    this.emptyMessage,
  });

  @override
  State<CpuLineChart> createState() => _CpuLineChartState();
}

/// Generic alias for metric line charts (RAM, CPU, etc.)
typedef MetricLineChart = CpuLineChart;

class _CpuLineChartState extends State<CpuLineChart> {
  int? _touchedIndex;
  List<ServerStats>? _frozenHistory;

  static final _shortTimeFormat = DateFormat('HH:mm');
  static final _fullTimeFormat = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return _buildEmptyState();
    }

    // Freeze visible snapshot during active scrub so incoming polls don't shift under the finger
    final List<ServerStats> displayHistory = _touchedIndex != null
        ? (_frozenHistory ?? widget.history)
        : widget.history;

    final int totalPoints = displayHistory.length;

    // Calculate Y-scale bounds
    final _YScaleRange scale = _computeYScale(displayHistory);

    // Group spots into segments if time gaps exist
    final List<List<FlSpot>> spotGroups = _createSpotGroups(displayHistory);

    // Ensure maxX has a minimum span
    final double minX = 0;
    final double maxX = totalPoints <= 1 ? 1.0 : (totalPoints - 1).toDouble();

    return RepaintBoundary(
      child: LineChart(
        LineChartData(
          minX: minX,
          maxX: maxX,
          minY: scale.minY,
          maxY: scale.maxY,
          clipData: const FlClipData.all(),

          // ── Horizontal Grid Lines ───────────────────────────────────────
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            drawHorizontalLine: true,
            horizontalInterval: scale.interval,
            getDrawingHorizontalLine: (value) => FlLine(
              color: const Color(0xFF52525B).withValues(alpha: 0.35),
              strokeWidth: 1,
              dashArray: const [4, 6],
            ),
          ),

          // ── Axis Titles ────────────────────────────────────────────────
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            // Left Y-Axis: dynamic scale ticks
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: scale.interval,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  // Hide tick labels outside or touching the very top if clipped
                  if (value < meta.min || value > meta.max) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      '${value.toInt()}%',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF52525B),
                        fontWeight: FontWeight.w500,
                        fontSize: 9,
                        letterSpacing: 0.2,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom X-Axis: distributed time intervals
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= totalPoints) {
                    return const SizedBox.shrink();
                  }

                  if (_shouldDisplayTimeTick(index, totalPoints)) {
                    final stat = displayHistory[index];
                    if (stat.timestamp == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _shortTimeFormat.format(stat.timestamp!),
                        style: GoogleFonts.inter(
                          color: const Color(0xFF52525B),
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // ── Border ──────────────────────────────────────────────────────
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF52525B).withValues(alpha: 0.4),
                width: 1,
              ),
              left: BorderSide.none,
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),

          // ── Interactive Touch / Scrub ──────────────────────────────────
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchCallback:
                (FlTouchEvent event, LineTouchResponse? touchResponse) {
                  final isEnd =
                      event is FlPanEndEvent ||
                      event is FlLongPressEnd ||
                      event is FlTapUpEvent ||
                      event is FlPointerExitEvent;

                  final isStart =
                      event is FlPanStartEvent ||
                      event is FlPanUpdateEvent ||
                      event is FlLongPressStart ||
                      event is FlLongPressMoveUpdate ||
                      event is FlTapDownEvent;

                  if (isEnd) {
                    setState(() {
                      _touchedIndex = null;
                      _frozenHistory = null;
                    });
                    widget.onSpotSelected?.call(null);
                  } else if (isStart &&
                      touchResponse != null &&
                      touchResponse.lineBarSpots != null &&
                      touchResponse.lineBarSpots!.isNotEmpty) {
                    final touchedSpot = touchResponse.lineBarSpots!.first;
                    final index = touchedSpot.x.toInt();
                    if (index >= 0 && index < displayHistory.length) {
                      if (_touchedIndex != index) {
                        HapticFeedback.selectionClick();
                      }
                      setState(() {
                        _frozenHistory ??= List.of(widget.history);
                        _touchedIndex = index;
                      });
                      widget.onSpotSelected?.call(displayHistory[index]);
                    }
                  }
                },

            // Vertical indicator & highlighted spot dot
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: widget.primaryColor.withValues(alpha: 0.5),
                        strokeWidth: 1.5,
                        dashArray: const [4, 4],
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 5,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: widget.primaryColor,
                            ),
                      ),
                    );
                  }).toList();
                },

            // Frosted floating tooltip
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) =>
                  const Color(0xFF18181B).withValues(alpha: 0.95),
              tooltipBorder: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.8),
                width: 1,
              ),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              tooltipMargin: 10,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= displayHistory.length) return null;
                  final stat = displayHistory[index];
                  final timeStr = stat.timestamp != null
                      ? _fullTimeFormat.format(stat.timestamp!)
                      : '--:--:--';

                  final formattedVal = widget.valueFormatter != null
                      ? widget.valueFormatter!(spot.y)
                      : '${spot.y.toStringAsFixed(1)}%';

                  return LineTooltipItem(
                    '$formattedVal\n',
                    GoogleFonts.firaCode(
                      color: widget.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    children: [
                      TextSpan(
                        text: timeStr,
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),

          // ── Line Bars Data ─────────────────────────────────────────────
          lineBarsData: _buildLineBars(spotGroups),
        ),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  /// Builds line bars with smooth cubic bezier splines and subtle linear gradient fill.
  List<LineChartBarData> _buildLineBars(List<List<FlSpot>> spotGroups) {
    return spotGroups.map((spots) {
      // If single spot, duplicate to x+0.1 to avoid render crash in fl_chart
      final effectiveSpots = spots.length == 1
          ? [spots.first, FlSpot(spots.first.x + 1.0, spots.first.y)]
          : spots;

      return LineChartBarData(
        spots: effectiveSpots,
        isCurved: true,
        curveSmoothness: 0.35,
        preventCurveOverShooting: true,
        barWidth: 2.5,
        isStrokeCapRound: true,
        color: widget.primaryColor,
        shadow: Shadow(
          color: widget.primaryColor.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.primaryColor.withValues(alpha: 0.15),
              widget.primaryColor.withValues(alpha: 0.0),
            ],
          ),
        ),
      );
    }).toList();
  }

  double _getStatValue(ServerStats stat) {
    if (widget.getValue != null) {
      return widget.getValue!(stat);
    }
    return stat.cpuPct;
  }

  /// Creates spots while splitting at gaps exceeding [maxDataGap].
  List<List<FlSpot>> _createSpotGroups(List<ServerStats> history) {
    if (history.isEmpty) return [];

    final List<List<FlSpot>> groups = [];
    List<FlSpot> currentGroup = [];

    for (int i = 0; i < history.length; i++) {
      final stat = history[i];
      final spot = FlSpot(i.toDouble(), _getStatValue(stat));

      if (currentGroup.isEmpty) {
        currentGroup.add(spot);
      } else {
        final prevStat = history[i - 1];
        if (_hasTimeGap(prevStat, stat)) {
          groups.add(List.from(currentGroup));
          currentGroup = [spot];
        } else {
          currentGroup.add(spot);
        }
      }
    }

    if (currentGroup.isNotEmpty) {
      groups.add(currentGroup);
    }

    return groups;
  }

  bool _hasTimeGap(ServerStats prev, ServerStats current) {
    if (prev.timestamp == null || current.timestamp == null) return false;
    return current.timestamp!.difference(prev.timestamp!) > widget.maxDataGap;
  }

  /// Determines which indices on the X-axis should display a timestamp label.
  /// Evenly spaces 3-4 timestamps to prevent overlapping on mobile screens.
  bool _shouldDisplayTimeTick(int index, int total) {
    if (total <= 3) return true;
    if (index == 0 || index == total - 1) return true;

    if (total >= 20) {
      final step = (total - 1) / 3;
      final int step1 = step.round();
      final int step2 = (step * 2).round();
      return index == step1 || index == step2;
    } else {
      return index == (total ~/ 2);
    }
  }

  /// Computes dynamic or fixed Y-axis scale bounds with clean tick intervals.
  _YScaleRange _computeYScale(List<ServerStats> history) {
    if (!widget.isDynamicScale) {
      return const _YScaleRange(minY: 0.0, maxY: 100.0, interval: 25.0);
    }

    double maxVal = 0.0;
    for (final s in history) {
      final val = _getStatValue(s);
      if (val > maxVal) maxVal = val;
    }

    if (maxVal <= 15.0) {
      return const _YScaleRange(minY: 0.0, maxY: 20.0, interval: 10.0);
    } else if (maxVal <= 25.0) {
      return const _YScaleRange(minY: 0.0, maxY: 30.0, interval: 10.0);
    } else if (maxVal <= 45.0) {
      return const _YScaleRange(minY: 0.0, maxY: 50.0, interval: 25.0);
    } else if (maxVal <= 70.0) {
      return const _YScaleRange(minY: 0.0, maxY: 75.0, interval: 25.0);
    } else {
      return const _YScaleRange(minY: 0.0, maxY: 100.0, interval: 25.0);
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.activity,
            size: 24,
            color: widget.primaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            widget.emptyMessage ?? 'Collecting CPU telemetry...',
            style: GoogleFonts.inter(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _YScaleRange {
  final double minY;
  final double maxY;
  final double interval;

  const _YScaleRange({
    required this.minY,
    required this.maxY,
    required this.interval,
  });
}
