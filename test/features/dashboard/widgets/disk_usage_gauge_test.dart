import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/features/dashboard/widgets/disk_usage_gauge.dart';

void main() {
  group('DiskUsageGauge Widget Tests', () {
    testWidgets('renders PieChart and center summary text with real data', (
      tester,
    ) async {
      // 50 GB used out of 200 GB (25.0%)
      const usedBytes = 53687091200.0; // 50 GB
      const totalBytes = 214748364800.0; // 200 GB
      const pct = 25.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 280,
              width: 320,
              child: DiskUsageGauge(
                usedValue: usedBytes,
                totalValue: totalBytes,
                percentage: pct,
              ),
            ),
          ),
        ),
      );

      // Verify fl_chart PieChart is rendered
      expect(find.byType(PieChart), findsOneWidget);

      // Verify percentage
      expect(find.text('25.0%'), findsOneWidget);

      // Verify center summary text: "[Used Space] of [Total Space] used"
      expect(find.text('50.00 GB of 200.00 GB'), findsOneWidget);
      expect(find.text('used'), findsOneWidget);

      // Verify legend items
      expect(find.text('USED'), findsOneWidget);
      expect(find.text('FREE'), findsOneWidget);
      expect(find.text('TOTAL'), findsOneWidget);
    });

    testWidgets('handles totalValue 0 gracefully without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 280,
              width: 320,
              child: DiskUsageGauge(
                usedValue: 0.0,
                totalValue: 0.0,
                percentage: 0.0,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('0.0%'), findsOneWidget);
      expect(find.text('0 B of 0 B'), findsOneWidget);
      expect(find.text('used'), findsOneWidget);
    });

    testWidgets('taps on legend item to select section', (tester) async {
      const usedBytes = 20000000000.0;
      const totalBytes = 100000000000.0;
      const pct = 20.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 280,
              width: 320,
              child: DiskUsageGauge(
                usedValue: usedBytes,
                totalValue: totalBytes,
                percentage: pct,
              ),
            ),
          ),
        ),
      );

      // Tap on FREE legend item
      await tester.tap(find.text('FREE'));
      await tester.pumpAndSettle();

      // Center summary should update to reflect free portion
      expect(find.text('free'), findsOneWidget);
      expect(find.text('80.0%'), findsOneWidget);
    });
  });
}
