import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/router/app_router.dart';

void main() {
  group('AppRouter Route Guard Tests [LOGIC-008]', () {
    testWidgets(
      'Accessing /server-details with null extra redirects safely to home',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();

        // Attempt navigation to /server-details without extra
        router.go('/server-details');
        await tester.pumpAndSettle();

        // Should not throw TypeError and should redirect to home route '/'
        expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
      },
    );

    testWidgets(
      'Accessing /legal with invalid extra redirects safely to home',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();

        // Attempt navigation to /legal with null extra
        router.go('/legal');
        await tester.pumpAndSettle();

        expect(router.routerDelegate.currentConfiguration.uri.toString(), '/');
      },
    );
  });
}
