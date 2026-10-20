import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorageService PBKDF2 PIN Security Tests', () {
    late SecureStorageService secureStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = SecureStorageService();
    });

    test(
      'Master PIN is hashed with salt and not stored as plaintext',
      () async {
        await secureStorage.saveMasterPin('1234');

        const storage = FlutterSecureStorage();
        final storedRaw = await storage.read(key: 'global_master_pin');
        expect(storedRaw, isNotNull);
        expect(storedRaw, isNot(contains('1234')));
        // format should be hexSalt:hexDk
        expect(storedRaw!.split(':').length, 2);
      },
    );

    test('verifyMasterPin correctly validates correct PIN', () async {
      await secureStorage.saveMasterPin('9876');

      final isCorrect = await secureStorage.verifyMasterPin('9876');
      expect(isCorrect, isTrue);
    });

    test('verifyMasterPin rejects incorrect PIN', () async {
      await secureStorage.saveMasterPin('9876');

      final isCorrect = await secureStorage.verifyMasterPin('0000');
      expect(isCorrect, isFalse);
    });

    test(
      'getLockoutDurationSeconds calculates progressive lockout intervals',
      () {
        // 0-4 attempts: no lockout
        expect(SecureStorageService.getLockoutDurationSeconds(0), 0);
        expect(SecureStorageService.getLockoutDurationSeconds(1), 0);
        expect(SecureStorageService.getLockoutDurationSeconds(4), 0);

        // 5 attempts = 30s
        expect(SecureStorageService.getLockoutDurationSeconds(5), 30);

        // 6-7 attempts = 2m (120s)
        expect(SecureStorageService.getLockoutDurationSeconds(6), 120);
        expect(SecureStorageService.getLockoutDurationSeconds(7), 120);

        // 8-9 attempts = 10m (600s)
        expect(SecureStorageService.getLockoutDurationSeconds(8), 600);
        expect(SecureStorageService.getLockoutDurationSeconds(9), 600);

        // 10+ attempts = 30m (1800s)
        expect(SecureStorageService.getLockoutDurationSeconds(10), 1800);
        expect(SecureStorageService.getLockoutDurationSeconds(15), 1800);
      },
    );

    test(
      'recordFailedAttempt increments attempts and triggers progressive lockout',
      () async {
        // Attempts 1 to 4 should not trigger lockout
        for (int i = 1; i <= 4; i++) {
          final duration = await secureStorage.recordFailedAttempt();
          expect(duration, 0);
          expect(await secureStorage.readFailedAttempts(), i);
          expect(await secureStorage.readRemainingLockoutSeconds(), 0);
        }

        // 5th attempt triggers 30s lockout
        final duration5 = await secureStorage.recordFailedAttempt();
        expect(duration5, 30);
        expect(await secureStorage.readFailedAttempts(), 5);
        expect(await secureStorage.readRemainingLockoutSeconds(), 30);

        // 6th attempt triggers 120s lockout
        final duration6 = await secureStorage.recordFailedAttempt();
        expect(duration6, 120);
        expect(await secureStorage.readFailedAttempts(), 6);
        expect(await secureStorage.readRemainingLockoutSeconds(), 120);
      },
    );

    test(
      'clearLockoutTimer clears remaining lockout seconds but preserves failedAttempts',
      () async {
        // Induce 5 failed attempts
        for (int i = 0; i < 5; i++) {
          await secureStorage.recordFailedAttempt();
        }
        expect(await secureStorage.readFailedAttempts(), 5);
        expect(await secureStorage.readRemainingLockoutSeconds(), 30);

        // Expiry of timer: clearLockoutTimer
        await secureStorage.clearLockoutTimer();

        // Lockout seconds are cleared to 0, but failedAttempts must remain 5!
        expect(await secureStorage.readRemainingLockoutSeconds(), 0);
        expect(await secureStorage.readFailedAttempts(), 5);

        // Next failed attempt becomes attempt 6 (2m lockout), not reset to attempt 1!
        final duration = await secureStorage.recordFailedAttempt();
        expect(duration, 120);
        expect(await secureStorage.readFailedAttempts(), 6);
      },
    );

    test(
      'recordSuccessfulAuth completely resets failedAttempts and remainingLockoutSeconds',
      () async {
        for (int i = 0; i < 5; i++) {
          await secureStorage.recordFailedAttempt();
        }
        expect(await secureStorage.readFailedAttempts(), 5);
        expect(await secureStorage.readRemainingLockoutSeconds(), 30);

        await secureStorage.recordSuccessfulAuth();

        expect(await secureStorage.readFailedAttempts(), 0);
        expect(await secureStorage.readRemainingLockoutSeconds(), 0);
        expect(await secureStorage.readLockoutTime(), isNull);
      },
    );

    test(
      'saveRemainingLockoutSeconds and readRemainingLockoutSeconds persist monotonically',
      () async {
        await secureStorage.saveRemainingLockoutSeconds(45);
        expect(await secureStorage.readRemainingLockoutSeconds(), 45);

        await secureStorage.saveRemainingLockoutSeconds(44);
        expect(await secureStorage.readRemainingLockoutSeconds(), 44);
      },
    );
  });
}
