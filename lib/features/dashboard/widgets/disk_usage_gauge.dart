import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/formatters.dart';

/// A modern, interactive donut chart for visualizing disk usage using fl_chart.
///
/// Features:
/// - Styled as a donut chart with `centerSpaceRadius` and a custom centered stack layer.
/// - Dynamic center summary text displaying "[Used Space] of [Total Space] used".
/// - Dynamic slices driven by live telemetry data source.
/// - Interactive `pieTouchData` with animated +6px radius expansion on section touch/tap.
/// - Interactive legend below the chart synced with slice selection.
class DiskUsageGauge extends StatefulWidget {
  final double usedValue;
  final double totalValue;
  final double percentage;
  final Color usedColor;
  final Color freeColor;

  const DiskUsageGauge({
    super.key,
    required this.usedValue,
    required this.totalValue,
    required this.percentage,
    this.usedColor = AppTheme.diskColor,
    this.freeColor = AppTheme.zinc800,
  });

  @override
  State<DiskUsageGauge> createState() => _DiskUsageGaugeState();
}

/// Aliases for semantic clarity
typedef DiskDonutChart = DiskUsageGauge;
typedef DiskPieChart = DiskUsageGauge;

class _DiskUsageGaugeState extends State<DiskUsageGauge> {
  int _touchedIndex = -1;

  static const double _baseRadius = 20.0;
  static const double _expandedRadius = 26.0; // +6px expansion on touch
  static const double _centerSpaceRadius = 52.0;

  @override
  Widget build(BuildContext context) {
    final double totalBytes = widget.totalValue;
    final double usedBytes = widget.usedValue.clamp(
      0.0,
      totalBytes > 0 ? totalBytes : double.infinity,
    );
    final double freeBytes = totalBytes > 0
        ? (totalBytes - usedBytes).clamp(0.0, totalBytes)
        : 0.0;
    final double pct = widget.percentage.clamp(0.0, 100.0);

    return Column(
      children: [
        // Donut Chart with centered stack layer
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    enabled: true,
                    touchCallback:
                        (FlTouchEvent event, PieTouchResponse? touchResponse) {
                          if (!event.isInterestedForInteractions ||
                              touchResponse == null ||
                              touchResponse.touchedSection == null) {
                            if (event is FlPointerExitEvent ||
                                event is FlPanEndEvent) {
                              setState(() => _touchedIndex = -1);
                            }
                            return;
                          }

                          final int index =
                              touchResponse.touchedSection!.touchedSectionIndex;
                          if (event is FlTapUpEvent ||
                              event is FlTapDownEvent) {
                            if (_touchedIndex != index) {
                              HapticFeedback.selectionClick();
                            }
                            setState(() {
                              if (event is FlTapUpEvent &&
                                  _touchedIndex == index) {
                                _touchedIndex = -1;
                              } else {
                                _touchedIndex = index;
                              }
                            });
                          } else if (event is FlPanUpdateEvent) {
                            if (_touchedIndex != index) {
                              HapticFeedback.selectionClick();
                            }
                            setState(() => _touchedIndex = index);
                          }
                        },
                  ),
                  startDegreeOffset: -90,
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 3,
                  centerSpaceRadius: _centerSpaceRadius,
                  centerSpaceColor: Colors.transparent,
                  sections: _buildSections(
                    totalBytes: totalBytes,
                    usedBytes: usedBytes,
                    freeBytes: freeBytes,
                  ),
                ),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              ),

              // Centered summary overlay
              IgnorePointer(
                child: _buildCenterSummary(
                  usedBytes: usedBytes,
                  freeBytes: freeBytes,
                  totalBytes: totalBytes,
                  pct: pct,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Interactive Legend Items
        Row(
          children: [
            Expanded(
              child: _LegendItem(
                color: widget.usedColor,
                label: 'USED',
                value: formatBytes(usedBytes),
                isSelected: _touchedIndex == 0,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _touchedIndex = _touchedIndex == 0 ? -1 : 0);
                },
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: AppTheme.border.withValues(alpha: 0.4),
            ),
            Expanded(
              child: _LegendItem(
                color: widget.freeColor.withValues(alpha: 0.8),
                label: 'FREE',
                value: formatBytes(freeBytes),
                isSelected: _touchedIndex == 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _touchedIndex = _touchedIndex == 1 ? -1 : 1);
                },
              ),
            ),
            Container(
              width: 1,
              height: 24,
              color: AppTheme.border.withValues(alpha: 0.4),
            ),
            Expanded(
              child: _LegendItem(
                color: AppTheme.textSecondary.withValues(alpha: 0.6),
                label: 'TOTAL',
                value: formatBytes(totalBytes),
                isSelected: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the donut slices dynamically from live telemetry data.
  List<PieChartSectionData> _buildSections({
    required double totalBytes,
    required double usedBytes,
    required double freeBytes,
  }) {
    if (totalBytes <= 0) {
      // Empty placeholder slice when total disk is uninitialized or 0
      return [
        PieChartSectionData(
          value: 100,
          color: widget.freeColor.withValues(alpha: 0.4),
          radius: _baseRadius,
          showTitle: false,
        ),
      ];
    }

    final bool isUsedTouched = _touchedIndex == 0;
    final bool isFreeTouched = _touchedIndex == 1;

    final double usedRadius = isUsedTouched ? _expandedRadius : _baseRadius;
    final double freeRadius = isFreeTouched ? _expandedRadius : _baseRadius;

    // Ensure non-zero values so fl_chart computes valid angles
    final double safeUsed = usedBytes > 0 ? usedBytes : 0.0001;
    final double safeFree = freeBytes > 0 ? freeBytes : 0.0001;

    return [
      // Slice 0: Used Space
      PieChartSectionData(
        value: safeUsed,
        color: widget.usedColor,
        radius: usedRadius,
        showTitle: false,
        borderSide: isUsedTouched
            ? const BorderSide(color: Colors.white, width: 1.5)
            : BorderSide.none,
      ),

      // Slice 1: Free Space
      PieChartSectionData(
        value: safeFree,
        color: isFreeTouched
            ? widget.freeColor.withValues(alpha: 0.9)
            : widget.freeColor.withValues(alpha: 0.6),
        radius: freeRadius,
        showTitle: false,
        borderSide: isFreeTouched
            ? BorderSide(color: AppTheme.border, width: 1.5)
            : BorderSide.none,
      ),
    ];
  }

  /// Builds the summary text inside the center of the donut hole.
  Widget _buildCenterSummary({
    required double usedBytes,
    required double freeBytes,
    required double totalBytes,
    required double pct,
  }) {
    final bool isFreeSelected = _touchedIndex == 1;
    final double displayedPct = isFreeSelected
        ? (100.0 - pct).clamp(0.0, 100.0)
        : pct;
    final String displayedMain = isFreeSelected
        ? '${formatBytes(freeBytes)} of ${formatBytes(totalBytes)}'
        : '${formatBytes(usedBytes)} of ${formatBytes(totalBytes)}';
    final String displayedLabel = isFreeSelected ? 'free' : 'used';

    return SizedBox(
      width: _centerSpaceRadius * 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Percentage reading
          Text(
            '${displayedPct.toStringAsFixed(1)}%',
            textAlign: TextAlign.center,
            style: GoogleFonts.firaCode(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),

          // Summary text: "[Used Space] of [Total Space]"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              displayedMain,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          // "used" / "free" label
          Text(
            displayedLabel,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback? onTap;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.zinc900.withValues(alpha: 0.9)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: color.withValues(alpha: 0.6), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.firaCode(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
