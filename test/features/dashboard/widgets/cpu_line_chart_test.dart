import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/features/dashboard/widgets/cpu_line_chart.dart';

void main() {
  group('CpuLineChart Widget Tests', () {
    testWidgets('renders collecting telemetry message when history is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: CpuLineChart(history: [])),
        ),
      );

      expect(find.text('Collecting CPU telemetry...'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets(
      'renders LineChart when single data point exists without crashing',
      (tester) async {
        final history = [
          ServerStats(
            cpuPct: 25.5,
            timestamp: DateTime(2026, 10, 13, 14, 30, 0),
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 200,
                width: 350,
                child: CpuLineChart(history: history),
              ),
            ),
          ),
        );

        expect(find.byType(LineChart), findsOneWidget);
      },
    );

    testWidgets('renders LineChart with multiple points and dynamic scale', (
      tester,
    ) async {
      final now = DateTime(2026, 10, 13, 14, 30, 0);
      final history = List.generate(
        10,
        (i) => ServerStats(
          cpuPct: 10.0 + (i * 2.5),
          timestamp: now.add(Duration(seconds: i * 2)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 350,
              child: CpuLineChart(history: history, isDynamicScale: true),
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders LineChart with fixed scale mode', (tester) async {
      final now = DateTime(2026, 10, 13, 14, 30, 0);
      final history = List.generate(
        5,
        (i) => ServerStats(
          cpuPct: 50.0,
          timestamp: now.add(Duration(seconds: i * 2)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 350,
              child: CpuLineChart(history: history, isDynamicScale: false),
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('renders custom empty message when history is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CpuLineChart(
              history: [],
              emptyMessage: 'Collecting RAM telemetry...',
            ),
          ),
        ),
      );

      expect(find.text('Collecting RAM telemetry...'), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('renders RAM metric with custom getValue and primaryColor', (
      tester,
    ) async {
      final now = DateTime(2026, 10, 13, 14, 30, 0);
      final history = List.generate(
        8,
        (i) => ServerStats(
          ramPct: 42.0 + (i * 1.5),
          timestamp: now.add(Duration(seconds: i * 2)),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 350,
              child: CpuLineChart(
                history: history,
                primaryColor: const Color(0xFFF59E0B),
                getValue: (s) => s.ramPct,
                isDynamicScale: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(LineChart), findsOneWidget);
    });
  });
}
