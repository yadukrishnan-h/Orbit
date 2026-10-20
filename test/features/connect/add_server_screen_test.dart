import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/features/connect/presentation/screens/add_server_screen.dart';

void main() {
  group('AddServerScreen Security & Auth UI Tests [SEC-014, SEC-015, SEC-017]', () {
    testWidgets(
      'Password auth fields have secure IME settings and obscureText [SEC-017]',
      (tester) async {
        final server = Server(
          id: 'srv-pwd',
          name: 'Password Server',
          hostname: '10.0.0.1',
          port: 22,
          username: 'ubuntu',
          authType: AuthType.password,
          password: 'super-secret-password',
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: AddServerScreen(existingServer: server)),
          ),
        );
        await tester.pumpAndSettle();

        // Locate Password field
        final passwordFinder = find.widgetWithText(TextFormField, 'Password');
        expect(passwordFinder, findsOneWidget);

        final editableTextFinder = find.descendant(
          of: passwordFinder,
          matching: find.byType(EditableText),
        );
        final editableText = tester.widget<EditableText>(editableTextFinder);

        expect(editableText.obscureText, isTrue);
        expect(editableText.enableSuggestions, isFalse);
        expect(editableText.autocorrect, isFalse);
        expect(editableText.enableIMEPersonalizedLearning, isFalse);
      },
    );

    testWidgets(
      'Key auth displays Private Key and Passphrase fields with secure IME flags [SEC-014, SEC-017]',
      (tester) async {
        final server = Server(
          id: 'srv-key',
          name: 'Key Server',
          hostname: '10.0.0.2',
          port: 2222,
          username: 'debian',
          authType: AuthType.key,
          password: 'passphrase-for-key',
          privateKey:
              '-----BEGIN OPENSSH PRIVATE KEY-----\ntest\n-----END OPENSSH PRIVATE KEY-----',
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: AddServerScreen(existingServer: server)),
          ),
        );
        await tester.pumpAndSettle();

        // Private Key field verification
        final privateKeyFinder = find.widgetWithText(
          TextFormField,
          'Private Key',
        );
        expect(privateKeyFinder, findsOneWidget);
        final privateKeyEditable = tester.widget<EditableText>(
          find.descendant(
            of: privateKeyFinder,
            matching: find.byType(EditableText),
          ),
        );

        expect(privateKeyEditable.enableSuggestions, isFalse);
        expect(privateKeyEditable.autocorrect, isFalse);
        expect(privateKeyEditable.enableIMEPersonalizedLearning, isFalse);

        // Passphrase field verification [SEC-014, SEC-015]
        final passphraseFinder = find.widgetWithText(
          TextFormField,
          'Private Key Passphrase (Optional)',
        );
        expect(passphraseFinder, findsOneWidget);
        final passphraseEditable = tester.widget<EditableText>(
          find.descendant(
            of: passphraseFinder,
            matching: find.byType(EditableText),
          ),
        );

        expect(passphraseEditable.obscureText, isTrue);
        expect(passphraseEditable.enableSuggestions, isFalse);
        expect(passphraseEditable.autocorrect, isFalse);
        expect(passphraseEditable.enableIMEPersonalizedLearning, isFalse);

        // Ensure password field is not shown for key auth
        expect(find.widgetWithText(TextFormField, 'Password'), findsNothing);
      },
    );

    testWidgets(
      'Toggling obscure passphrase button reveals/obscures passphrase text',
      (tester) async {
        final server = Server(
          id: 'srv-key',
          name: 'Key Server',
          hostname: '10.0.0.2',
          port: 22,
          username: 'debian',
          authType: AuthType.key,
          password: 'secret-passphrase',
          privateKey: 'dummy-key',
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(home: AddServerScreen(existingServer: server)),
          ),
        );
        await tester.pumpAndSettle();

        final passphraseFinder = find.widgetWithText(
          TextFormField,
          'Private Key Passphrase (Optional)',
        );
        var passphraseEditable = tester.widget<EditableText>(
          find.descendant(
            of: passphraseFinder,
            matching: find.byType(EditableText),
          ),
        );
        expect(passphraseEditable.obscureText, isTrue);

        // Find eye icon button inside the passphrase field
        final eyeButton = find.descendant(
          of: passphraseFinder,
          matching: find.byType(IconButton),
        );
        expect(eyeButton, findsOneWidget);

        await tester.tap(eyeButton);
        await tester.pumpAndSettle();

        passphraseEditable = tester.widget<EditableText>(
          find.descendant(
            of: passphraseFinder,
            matching: find.byType(EditableText),
          ),
        );
        expect(passphraseEditable.obscureText, isFalse);
      },
    );
  });
}
