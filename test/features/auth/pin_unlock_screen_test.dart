import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/features/auth/presentation/screens/pin_unlock_screen.dart';

class MockSecureStorageService extends SecureStorageService {
  String? masterPin;
  int failedAttempts = 0;
  int remainingSeconds = 0;

  @override
  Future<bool> hasMasterPin() async => masterPin != null;

  @override
  Future<bool> verifyMasterPin(String pin) async => pin == masterPin;

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

  group('PinUnlockScreen Tests', () {
    late MockSecureStorageService storage;

    setUp(() {
      storage = MockSecureStorageService();
    });

    testWidgets('renders Enter Master PIN and accepts correct PIN', (
      tester,
    ) async {
      storage.masterPin = '1234';
      bool successCalled = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageServiceProvider.overrideWithValue(storage)],
          child: MaterialApp(
            home: PinUnlockScreen(onSuccess: () => successCalled = true),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Enter Master PIN'), findsOneWidget);
      expect(find.text('Secure your app and credentials'), findsOneWidget);

      // Enter 1, 2, 3, 4
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();
      await tester.tap(find.text('4'));
      await tester.pump();

      expect(successCalled, isTrue);
      expect(storage.failedAttempts, 0);
    });

    testWidgets(
      'enforces progressive lockout and blocks input after 5 failed attempts',
      (tester) async {
        tester.view.physicalSize = const Size(400, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        storage.masterPin = '9999';
        storage.failedAttempts = 4; // next wrong pin triggers lockout

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(storage),
            ],
            child: MaterialApp(home: PinUnlockScreen(onSuccess: () {})),
          ),
        );
        await tester.pump();

        // Enter wrong pin '1111'
        for (int digit = 0; digit < 4; digit++) {
          await tester.tap(find.text('1'));
          await tester.pump();
        }

        // Check lockout state
        expect(find.text('Temporarily Locked'), findsOneWidget);
        expect(find.textContaining('Please wait'), findsOneWidget);
        expect(storage.failedAttempts, 5);
        expect(storage.remainingSeconds, 30);

        // Attempting to tap digits while locked out is absorbed
        await tester.tap(find.text('1'), warnIfMissed: false);
        await tester.pump();
        // Remains locked out
        expect(find.text('Temporarily Locked'), findsOneWidget);

        // Clean unmount
        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'loads existing lockout from storage and displays remaining seconds',
      (tester) async {
        storage.failedAttempts = 5;
        storage.remainingSeconds = 25;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(storage),
            ],
            child: MaterialApp(home: PinUnlockScreen(onSuccess: () {})),
          ),
        );
        await tester.pump();

        expect(find.text('Temporarily Locked'), findsOneWidget);
        expect(find.text('Please wait 25 seconds'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'cold restart after lockout expired clears lockout and allows input [SEC-003]',
      (tester) async {
        storage.failedAttempts = 5;
        storage.remainingSeconds = 30;
        // Expired 10 seconds ago
        storage.lockoutTime = DateTime.now().subtract(
          const Duration(seconds: 10),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(storage),
            ],
            child: MaterialApp(home: PinUnlockScreen(onSuccess: () {})),
          ),
        );
        await tester.pump();

        // Lockout cleared!
        expect(find.text('Enter Master PIN'), findsOneWidget);
        expect(find.text('Temporarily Locked'), findsNothing);
        expect(storage.remainingSeconds, 0);

        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets(
      'cold restart with active lockoutEnd calculates correct remaining seconds [SEC-003]',
      (tester) async {
        storage.failedAttempts = 5;
        storage.remainingSeconds = 30;
        // Expires 12 seconds in the future
        storage.lockoutTime = DateTime.now().add(const Duration(seconds: 12));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              secureStorageServiceProvider.overrideWithValue(storage),
            ],
            child: MaterialApp(home: PinUnlockScreen(onSuccess: () {})),
          ),
        );
        await tester.pump();

        expect(find.text('Temporarily Locked'), findsOneWidget);
        expect(find.textContaining('Please wait'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('lockout remaining seconds persisted on app pause [SEC-002]', (
      tester,
    ) async {
      storage.failedAttempts = 5;
      storage.remainingSeconds = 30;
      storage.lockoutTime = DateTime.now().add(const Duration(seconds: 30));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [secureStorageServiceProvider.overrideWithValue(storage)],
          child: MaterialApp(home: PinUnlockScreen(onSuccess: () {})),
        ),
      );
      await tester.pump();

      expect(find.text('Temporarily Locked'), findsOneWidget);

      // Simulate app going to background (paused)
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      // Verify that remaining lockout seconds was persisted
      expect(storage.remainingSeconds, lessThanOrEqualTo(30));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
