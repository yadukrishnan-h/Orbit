import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/services/biometric_service.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/features/settings/models/app_settings.dart';
import 'package:orbit/features/settings/presentation/widgets/biometrics_tile.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';
import 'package:orbit/features/settings/viewmodels/settings_viewmodel.dart';

class FakeBiometricService extends Fake implements BiometricService {
  bool available = true;
  bool authenticateResult = true;
  String? lastReason;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
  }) async {
    lastReason = reason;
    return authenticateResult;
  }
}

class FakeSecureStorageService extends Fake implements SecureStorageService {
  String masterPin = '1234';

  @override
  Future<bool> verifyMasterPin(String pin) async => pin == masterPin;
}

class TestSettingsViewModel extends SettingsViewModel {
  final bool initialBiometrics;
  TestSettingsViewModel(this.initialBiometrics);

  @override
  Future<AppSettings> build() async {
    return AppSettings(
      languageCode: 'en',
      pollIntervalSeconds: 3,
      isBiometricsEnabled: initialBiometrics,
      isGeolocationEnabled: false,
    );
  }

  @override
  Future<void> setBiometricsEnabled(bool enabled) async {
    final current = state.value ?? await future;
    state = AsyncData(current.copyWith(isBiometricsEnabled: enabled));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('BiometricsTile Security Gate Tests [SEC-005]', () {
    late FakeBiometricService biometricService;
    late FakeSecureStorageService storageService;

    setUp(() {
      biometricService = FakeBiometricService();
      storageService = FakeSecureStorageService();
    });

    testWidgets(
      'Toggling off biometrics requires biometric authentication [SEC-005]',
      (tester) async {
        final settingsVm = TestSettingsViewModel(true);
        biometricService.authenticateResult =
            false; // User cancels / fails biometric

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              biometricServiceProvider.overrideWithValue(biometricService),
              secureStorageServiceProvider.overrideWithValue(storageService),
              settingsProvider.overrideWith(() => settingsVm),
            ],
            child: const MaterialApp(home: Scaffold(body: BiometricsTile())),
          ),
        );
        await tester.pumpAndSettle();

        // Switch is currently ON
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);
        expect(tester.widget<Switch>(switchFinder).value, isTrue);

        // Tap to toggle off
        await tester.tap(switchFinder);
        await tester.pumpAndSettle();

        // Biometric was prompted with disable reason
        expect(biometricService.lastReason, contains('disable'));

        // Because biometric failed/cancelled, Master PIN fallback dialog is shown
        expect(find.text('Disable Biometric Lock'), findsOneWidget);

        // Cancel dialog
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Biometrics remain enabled!
        expect(settingsVm.state.value!.isBiometricsEnabled, isTrue);
      },
    );

    testWidgets(
      'Master PIN fallback successfully disables biometrics when biometric fails [SEC-005]',
      (tester) async {
        final settingsVm = TestSettingsViewModel(true);
        biometricService.authenticateResult = false; // Biometric fails

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              biometricServiceProvider.overrideWithValue(biometricService),
              secureStorageServiceProvider.overrideWithValue(storageService),
              settingsProvider.overrideWith(() => settingsVm),
            ],
            child: const MaterialApp(home: Scaffold(body: BiometricsTile())),
          ),
        );
        await tester.pumpAndSettle();

        // Tap to toggle off
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        // Fallback dialog is shown
        expect(find.text('Disable Biometric Lock'), findsOneWidget);

        // Enter Master PIN '1234'
        await tester.enterText(find.byType(TextField), '1234');
        await tester.pump();

        // Tap Verify PIN
        await tester.tap(find.text('Verify PIN'));
        await tester.pumpAndSettle();

        // Biometrics are now disabled!
        expect(settingsVm.state.value!.isBiometricsEnabled, isFalse);
      },
    );

    testWidgets(
      'Toggling on biometrics succeeds when biometric authentication passes',
      (tester) async {
        final settingsVm = TestSettingsViewModel(false);
        biometricService.authenticateResult = true; // Biometric succeeds

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              biometricServiceProvider.overrideWithValue(biometricService),
              secureStorageServiceProvider.overrideWithValue(storageService),
              settingsProvider.overrideWith(() => settingsVm),
            ],
            child: const MaterialApp(home: Scaffold(body: BiometricsTile())),
          ),
        );
        await tester.pumpAndSettle();

        // Switch is currently OFF
        expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

        // Tap to toggle on
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(biometricService.lastReason, contains('enable'));
        expect(settingsVm.state.value!.isBiometricsEnabled, isTrue);
      },
    );
  });
}
