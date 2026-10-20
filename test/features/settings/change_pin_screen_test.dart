import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/features/settings/presentation/screens/change_pin_screen.dart';

class MockSecureStorageService extends SecureStorageService {
  String? masterPin;
  int failedAttempts = 0;
  int remainingSeconds = 0;

  @override
  Future<bool> hasMasterPin() async => masterPin != null;

  @override
  Future<bool> verifyMasterPin(String pin) async => pin == masterPin;

  @override
  Future<void> saveMasterPin(String pin) async {
    masterPin = pin;
    await recordSuccessfulAuth();
  }

  @override
  Future<int> readFailedAttempts() async => failedAttempts;

  @override
  Future<int> readRemainingLockoutSeconds() async => remainingSeconds;

  @override
  Future<void> saveFailedAttempts(int count) async {
    failedAttempts = count;
  }

  @override
  Future<void> saveRemainingLockoutSeconds(int seconds) async {
    remainingSeconds = seconds;
  }

  @override
  Future<int> recordFailedAttempt() async {
    failedAttempts++;
    final duration = SecureStorageService.getLockoutDurationSeconds(
      failedAttempts,
    );
    if (duration > 0) {
      remainingSeconds = duration;
    }
    return duration;
  }

  @override
  Future<void> clearLockoutTimer() async {
    remainingSeconds = 0;
  }

  @override
  Future<void> recordSuccessfulAuth() async {
    failedAttempts = 0;
    remainingSeconds = 0;
  }

  DateTime? lockoutTime;

  @override
  Future<DateTime?> readLockoutTime() async => lockoutTime;

  @override
  Future<void> saveLockoutTime(DateTime? time) async {
    lockoutTime = time;
  }

  @override
  Future<DateTime?> readLastFailedAttempt() async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ChangePinScreen Lockout Tests [SEC-011]', () {
    late MockSecureStorageService storage;

    setUp(() {
      storage = MockSecureStorageService();
      storage.masterPin = '1234';
    });

    testWidgets('enforces lockout on Phase 1 when failed attempts reach 5', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      storage.failedAttempts = 4; // next failure triggers lockout

      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageServiceProvider.overrideWithValue(storage)],
          child: const MaterialApp(home: ChangePinScreen()),
        ),
      );
      await tester.pump();

      expect(find.text('Verify Current PIN'), findsOneWidget);

      // Enter wrong PIN '9999'
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text('9'));
        await tester.pump();
      }

      // Check that lockout state is active
      expect(find.text('Temporarily Locked'), findsOneWidget);
      expect(find.textContaining('Please wait'), findsOneWidget);
      expect(storage.failedAttempts, 5);
      expect(storage.remainingSeconds, 30);

      // Verify that input is blocked while locked out
      await tester.tap(find.text('1'), warnIfMissed: false);
      await tester.pump();
      expect(find.text('Temporarily Locked'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'loads existing lockout from SecureStorage and blocks input on Phase 1',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        storage.failedAttempts = 5;
        storage.remainingSeconds = 45;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(storage),
            ],
            child: const MaterialApp(home: ChangePinScreen()),
          ),
        );
        await tester.pump();

        expect(find.text('Temporarily Locked'), findsOneWidget);
        expect(find.text('Please wait 45 seconds'), findsOneWidget);

        // Tap is absorbed
        await tester.tap(find.text('1'), warnIfMissed: false);
        await tester.pump();
        expect(find.text('Temporarily Locked'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'correct PIN in Phase 1 advances to Phase 2 and resets failed attempts',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        storage.failedAttempts = 3;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(storage),
            ],
            child: const MaterialApp(home: ChangePinScreen()),
          ),
        );
        await tester.pump();

        // Enter correct PIN '1234'
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();
        await tester.tap(find.text('4'));
        await tester.pump();

        // Advanced to Phase 2
        expect(find.text('Create New PIN'), findsOneWidget);
        expect(find.text('Enter your new 4-digit Master PIN'), findsOneWidget);
        expect(storage.failedAttempts, 0);

        await tester.pumpWidget(const SizedBox());
      },
    );
  });
}
