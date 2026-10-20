import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/features/terminal/presentation/screens/terminal_screen.dart';
import 'package:orbit/features/terminal/providers/terminal_provider.dart';

class FakeTerminalNotifier extends StateNotifier<TerminalState>
    implements TerminalNotifier {
  FakeTerminalNotifier() : super(TerminalState());

  final List<String> sentRaw = [];

  void setConnected(Server server) {
    state = state.copyWith(
      selectedServer: server,
      status: TerminalStatus.connected,
    );
  }

  @override
  void sendRaw(String raw) {
    sentRaw.add(raw);
  }

  @override
  void clearOutput() {}

  @override
  Future<void> connectToServer(Server server) async {}

  @override
  Future<void> disconnect() async {}

  @override
  void sendCommand(String text) {}
}

void main() {
  group('Terminal Modifier & Sticky Key Tests [UI-001]', () {
    late FakeTerminalNotifier fakeNotifier;

    setUp(() {
      fakeNotifier = FakeTerminalNotifier();
    });

    testWidgets(
      'Tapping CTRL toggles sticky active state and transforms next key to control byte',
      (tester) async {
        final server = Server(
          id: 'srv-term',
          name: 'Terminal Server',
          hostname: '10.0.0.1',
          port: 22,
          username: 'root',
          password: '',
          authType: AuthType.password,
        );
        fakeNotifier.setConnected(server);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [terminalProvider.overrideWith((ref) => fakeNotifier)],
            child: const MaterialApp(home: TerminalScreen()),
          ),
        );
        await tester.pumpAndSettle();

        // Find CTRL button
        final ctrlFinder = find.widgetWithText(TextButton, 'CTRL');
        expect(ctrlFinder, findsOneWidget);

        // Tap CTRL to activate sticky mode
        await tester.tap(ctrlFinder);
        await tester.pumpAndSettle();

        // 'c' with CTRL active must convert to \x03 (ASCII 3)
        fakeNotifier.state.terminal.onOutput?.call('c');
        await tester.pumpAndSettle();

        expect(fakeNotifier.sentRaw, contains('\x03'));

        // Next key without CTRL should send plain char
        fakeNotifier.state.terminal.onOutput?.call('c');
        await tester.pumpAndSettle();
        expect(fakeNotifier.sentRaw.last, 'c');
      },
    );

    testWidgets(
      'Tapping ALT prefixes next character with ESC (\\x1b) and untoggles',
      (tester) async {
        final server = Server(
          id: 'srv-term',
          name: 'Terminal Server',
          hostname: '10.0.0.1',
          port: 22,
          username: 'root',
          password: '',
          authType: AuthType.password,
        );
        fakeNotifier.setConnected(server);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [terminalProvider.overrideWith((ref) => fakeNotifier)],
            child: const MaterialApp(home: TerminalScreen()),
          ),
        );
        await tester.pumpAndSettle();

        final altFinder = find.widgetWithText(TextButton, 'ALT');
        expect(altFinder, findsOneWidget);

        // Tap ALT to activate sticky mode
        await tester.tap(altFinder);
        await tester.pumpAndSettle();

        fakeNotifier.state.terminal.onOutput?.call('f');
        await tester.pumpAndSettle();

        expect(fakeNotifier.sentRaw, contains('\x1bf'));

        // Next key should be plain
        fakeNotifier.state.terminal.onOutput?.call('f');
        await tester.pumpAndSettle();
        expect(fakeNotifier.sentRaw.last, 'f');
      },
    );
  });
}
