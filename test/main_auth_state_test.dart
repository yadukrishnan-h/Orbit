import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/main.dart';

import 'dart:io';
import 'package:hive/hive.dart';
import 'package:orbit/features/auth/presentation/screens/pin_unlock_screen.dart';
import 'package:orbit/core/data/entities/hive_server.dart';

import 'package:orbit/features/settings/models/app_settings.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';
import 'package:orbit/features/settings/viewmodels/settings_viewmodel.dart';

class MockSettingsViewModel extends SettingsViewModel {
  @override
  Future<AppSettings> build() async {
    return const AppSettings(
      languageCode: 'en',
      pollIntervalSeconds: 3,
      isBiometricsEnabled: false,
      isGeolocationEnabled: false,
    );
  }
}

class FailingSecureStorageService extends SecureStorageService {
  @override
  Future<List<int>?> readHiveKey() async => List<int>.filled(32, 1);

  @override
  Future<bool> hasMasterPin() async {
    throw Exception('Keystore hardware master key unavailable');
  }
}

class CleanEmptySecureStorageService extends SecureStorageService {
  @override
  Future<List<int>?> readHiveKey() async => List<int>.filled(32, 1);

  @override
  Future<bool> hasMasterPin() async => false;
}

class ConfiguredSecureStorageService extends SecureStorageService {
  @override
  Future<List<int>?> readHiveKey() async => List<int>.filled(32, 1);

  @override
  Future<bool> hasMasterPin() async => true;

  @override
  Future<int> readRemainingLockoutSeconds() async => 0;

  @override
  Future<int> readFailedAttempts() async => 0;

  @override
  Future<DateTime?> readLockoutTime() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('MyApp AuthState & Recovery Screen Tests [SEC-002, SEC-003]', () {
    late Directory tempDir;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('hive_main_test_');
      Hive.init(tempDir.path);
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(HiveServerAdapter());
      }
      await Hive.openBox<HiveServer>(
        'servers',
        encryptionCipher: HiveAesCipher(List<int>.filled(32, 1)),
      );
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets(
      'fails closed to storageError screen when hasMasterPin throws exception',
      (tester) async {
        final failingStorage = FailingSecureStorageService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(failingStorage),
              settingsProvider.overrideWith(() => MockSettingsViewModel()),
            ],
            child: const MyApp(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // SEC-003: Must NOT render PinSetupScreen
        expect(find.text('Set Master PIN'), findsNothing);
        expect(
          find.text('Create a 4-digit PIN to secure your app'),
          findsNothing,
        );

        // SEC-002: Must render Storage Error Recovery Screen
        expect(find.text('Secure Storage Error'), findsOneWidget);
        expect(find.text('Retry Unlock'), findsOneWidget);
        expect(
          find.text('Reset Database (Deletes Saved Servers)'),
          findsOneWidget,
        );
        expect(
          find.textContaining('Keystore hardware master key unavailable'),
          findsOneWidget,
        );

        // Tap Reset Database -> Dialog must appear
        await tester.tap(find.text('Reset Database (Deletes Saved Servers)'));
        await tester.pumpAndSettle();

        expect(find.text('Reset Database?'), findsOneWidget);
        expect(
          find.textContaining(
            'This will permanently delete all saved server profiles',
          ),
          findsOneWidget,
        );
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Delete & Reset'), findsOneWidget);

        // Dismiss dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(find.text('Reset Database?'), findsNothing);
      },
    );

    testWidgets(
      'renders PinSetupScreen only when hasMasterPin completes cleanly and returns false [SEC-003]',
      (tester) async {
        final cleanStorage = CleanEmptySecureStorageService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(cleanStorage),
              settingsProvider.overrideWith(() => MockSettingsViewModel()),
            ],
            child: const MyApp(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Create Master PIN'), findsOneWidget);
        expect(find.text('Used to unlock Orbit securely'), findsOneWidget);
        expect(find.text('Secure Storage Error'), findsNothing);
      },
    );

    testWidgets('renders PinUnlockScreen when hasMasterPin returns true', (
      tester,
    ) async {
      final configuredStorage = ConfiguredSecureStorageService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            secureStorageServiceProvider.overrideWithValue(configuredStorage),
            settingsProvider.overrideWith(() => MockSettingsViewModel()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Enter Master PIN'), findsOneWidget);
      expect(find.text('Create Master PIN'), findsNothing);
      expect(find.text('Secure Storage Error'), findsNothing);
    });

    testWidgets(
      'auto-locks to pinUnlock when in background for >= 15 seconds [SEC-012]',
      (tester) async {
        var fakeTime = DateTime(2026, 1, 1, 12, 0, 0);
        MyApp.lifecycleClock = () => fakeTime;
        addTearDown(() => MyApp.lifecycleClock = DateTime.now);

        final configuredStorage = ConfiguredSecureStorageService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(configuredStorage),
              settingsProvider.overrideWith(() => MockSettingsViewModel()),
            ],
            child: const MyApp(),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(PinUnlockScreen), findsOneWidget);

        // Successfully unlock PIN -> AuthState transitions to passed
        final unlockWidget = tester.widget<PinUnlockScreen>(
          find.byType(PinUnlockScreen),
        );
        unlockWidget.onSuccess();
        await tester.pump();

        // PinUnlockScreen is no longer rendered
        expect(find.byType(PinUnlockScreen), findsNothing);

        // Scenario A: Background for 5 seconds (< 15 seconds) -> Should NOT lock
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        fakeTime = fakeTime.add(const Duration(seconds: 5));
        await tester.pump(const Duration(seconds: 5));
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();

        expect(find.byType(PinUnlockScreen), findsNothing);

        // Scenario B: Background for 16 seconds (>= 15 seconds) -> MUST re-lock
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        fakeTime = fakeTime.add(const Duration(seconds: 16));
        await tester.pump(const Duration(seconds: 16));
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(PinUnlockScreen), findsOneWidget);
      },
    );
  });
}
