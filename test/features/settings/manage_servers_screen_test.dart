import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/features/settings/presentation/screens/manage_servers_screen.dart';

void main() {
  group('ManageServersScreen Server Reordering & Drag Handle Tests [LOGIC-001]', () {
    final List<Server> testServers = [
      Server(
        id: 'server-1',
        name: 'Alpha Server',
        hostname: '10.0.0.1',
        port: 22,
        username: 'root',
        password: '',
        authType: AuthType.password,
        status: ServerStatus.online,
      ),
      Server(
        id: 'server-2',
        name: 'Beta Server',
        hostname: '10.0.0.2',
        port: 22,
        username: 'admin',
        password: '',
        authType: AuthType.password,
        status: ServerStatus.offline,
      ),
      Server(
        id: 'server-3',
        name: 'Gamma Server',
        hostname: '10.0.0.3',
        port: 22,
        username: 'user',
        password: '',
        authType: AuthType.key,
        status: ServerStatus.online,
      ),
    ];

    testWidgets(
      'binds distinct item indices to ReorderableDragStartListener for each row [LOGIC-001]',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              serverListStreamProvider.overrideWith(
                (ref) => Stream.value(testServers),
              ),
            ],
            child: const MaterialApp(home: ManageServersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Verify all servers are rendered
        expect(find.text('Alpha Server'), findsOneWidget);
        expect(find.text('Beta Server'), findsOneWidget);
        expect(find.text('Gamma Server'), findsOneWidget);

        // Verify ReorderableListView exists and has buildDefaultDragHandles disabled
        final listViewFinder = find.byType(ReorderableListView);
        expect(listViewFinder, findsOneWidget);
        final listViewWidget = tester.widget<ReorderableListView>(
          listViewFinder,
        );
        expect(listViewWidget.buildDefaultDragHandles, isFalse);

        // Verify ReorderableDragStartListener widgets have their corresponding row indices
        final dragListeners = tester
            .widgetList<ReorderableDragStartListener>(
              find.byType(ReorderableDragStartListener),
            )
            .toList();

        expect(dragListeners.length, 3);
        expect(dragListeners[0].index, 0);
        expect(dragListeners[1].index, 1);
        expect(dragListeners[2].index, 2);
      },
    );

    testWidgets(
      'hides drag handles and shows checkboxes when entering select mode',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              serverListStreamProvider.overrideWith(
                (ref) => Stream.value(testServers),
              ),
            ],
            child: const MaterialApp(home: ManageServersScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Enter select mode
        final selectButton = find.text('Select');
        expect(selectButton, findsOneWidget);
        await tester.tap(selectButton);
        await tester.pumpAndSettle();

        // Drag handles should now be hidden
        expect(find.byType(ReorderableDragStartListener), findsNothing);

        // Checkboxes should be displayed for selection
        expect(find.byType(Checkbox), findsNWidgets(3));

        // Cancel select mode restores drag handles
        final cancelButton = find.text('Cancel');
        expect(cancelButton, findsOneWidget);
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        expect(find.byType(ReorderableDragStartListener), findsNWidgets(3));
      },
    );
  });
}
