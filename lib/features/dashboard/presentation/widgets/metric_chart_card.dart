import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:orbit/core/theme/app_theme.dart';

class MetricChartCard extends StatelessWidget {
  final String title;
  final String value;
  final List<FlSpot> spots;
  final Color lineColor;

  const MetricChartCard({
    super.key,
    required this.title,
    required this.value,
    required this.spots,
    required this.lineColor,
  });

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.1,
                ),
              ),
              num.tryParse(value.replaceAll('%', '')) != null
                  ? Text(
                      value,
                      style: TextStyle(
                        color: lineColor,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: AppTheme.border,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: const FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 19,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots.isEmpty ? _emptySpots() : spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          lineColor.withValues(alpha: 0.25),
                          lineColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _emptySpots() {
    return List.generate(20, (i) => FlSpot(i.toDouble(), 0));
  }
}
