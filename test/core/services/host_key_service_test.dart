import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/services/host_key_service.dart';
import 'package:orbit/core/services/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HostKeyService TOFU Tests', () {
    late SecureStorageService secureStorage;
    late HostKeyService hostKeyService;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = SecureStorageService();
      hostKeyService = HostKeyService(secureStorage);
    });

    test(
      'Trust On First Use records fingerprint and returns true with user confirmation',
      () async {
        final fp = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
        final result = await hostKeyService.verifyHostKey(
          'server-1',
          'ssh-ed25519',
          fp,
          onConfirm: (_, _) async => true,
        );

        expect(result, isTrue);

        final stored = await secureStorage.readHostKeyFingerprint('server-1');
        expect(stored, 'ssh-ed25519:01:02:03:04:05:06:07:08');
      },
    );

    test('Matching host key on subsequent connection succeeds', () async {
      final fp = Uint8List.fromList([10, 20, 30, 40]);
      // First connection with confirmation
      await hostKeyService.verifyHostKey(
        'server-2',
        'ssh-rsa',
        fp,
        onConfirm: (_, _) async => true,
      );

      // Subsequent connection with same key does not require confirmation
      final result = await hostKeyService.verifyHostKey(
        'server-2',
        'ssh-rsa',
        fp,
      );
      expect(result, isTrue);
    });

    test('Mismatched host key throws HostKeyMismatchException', () async {
      final initialFp = Uint8List.fromList([1, 1, 1, 1]);
      final untrustedFp = Uint8List.fromList([2, 2, 2, 2]);

      // Pin first key with confirmation
      await hostKeyService.verifyHostKey(
        'server-3',
        'ssh-ed25519',
        initialFp,
        onConfirm: (_, _) async => true,
      );

      // Attempt with changed key
      expect(
        () => hostKeyService.verifyHostKey(
          'server-3',
          'ssh-ed25519',
          untrustedFp,
        ),
        throwsA(isA<HostKeyMismatchException>()),
      );
    });

    test(
      'verifyHostKey fails closed (returns false) when neither onConfirm nor default callback is provided [SEC-001]',
      () async {
        final fp = Uint8List.fromList([99, 98, 97, 96]);
        final result = await hostKeyService.verifyHostKey(
          'server-no-callback',
          'ssh-ed25519',
          fp,
        );
        expect(result, isFalse);

        final stored = await secureStorage.readHostKeyFingerprint(
          'server-no-callback',
        );
        expect(stored, isNull);
      },
    );

    test(
      'verifyHostKey deduplicates concurrent confirmation requests for the same serverId [SEC-001]',
      () async {
        final fp = Uint8List.fromList([42, 43, 44, 45]);
        int confirmationPromptCount = 0;

        // Start two concurrent verifyHostKey calls
        final future1 = hostKeyService.verifyHostKey(
          'server-concurrent',
          'ssh-ed25519',
          fp,
          onConfirm: (serverId, formattedFp) async {
            confirmationPromptCount++;
            await Future.delayed(const Duration(milliseconds: 50));
            return true;
          },
        );

        final future2 = hostKeyService.verifyHostKey(
          'server-concurrent',
          'ssh-ed25519',
          fp,
        );

        final results = await Future.wait([future1, future2]);
        expect(results[0], isTrue);
        expect(results[1], isTrue);
        expect(confirmationPromptCount, 1); // Only prompted once!

        final stored = await secureStorage.readHostKeyFingerprint(
          'server-concurrent',
        );
        expect(stored, isNotNull);
      },
    );

    test(
      'formatFingerprint formats ASCII SHA256 string correctly [SEC-013]',
      () {
        final asciiBytes = Uint8List.fromList(
          ascii.encode('SHA256:4y+0wZ1V5K2s/m8+Z0rB8z7lDq0QJ5l0'),
        );
        final formatted = HostKeyService.formatFingerprint(
          'ssh-ed25519',
          asciiBytes,
        );
        expect(
          formatted,
          'ssh-ed25519 SHA256:4y+0wZ1V5K2s/m8+Z0rB8z7lDq0QJ5l0',
        );
      },
    );

    test(
      'formatFingerprint formats 32-byte raw digest as Base64 SHA256 [SEC-013]',
      () {
        final rawDigest = Uint8List.fromList(List<int>.generate(32, (i) => i));
        final formatted = HostKeyService.formatFingerprint(
          'ssh-rsa',
          rawDigest,
        );
        final expectedB64 = base64.encode(rawDigest).replaceAll('=', '');
        expect(formatted, 'ssh-rsa SHA256:$expectedB64');
      },
    );

    test('verifyHostKey throws ArgumentError on empty serverId', () async {
      final fp = Uint8List.fromList([1, 2, 3, 4]);
      expect(
        () => hostKeyService.verifyHostKey('   ', 'ssh-ed25519', fp),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('verifyHostKey honors user confirmation callback [SEC-004]', () async {
      final fp = Uint8List.fromList([5, 6, 7, 8]);
      bool callbackInvoked = false;

      final result = await hostKeyService.verifyHostKey(
        'server-confirm',
        'ssh-ed25519',
        fp,
        onConfirm: (serverId, formattedFp) async {
          callbackInvoked = true;
          expect(serverId, 'server-confirm');
          expect(formattedFp, 'ssh-ed25519:05:06:07:08');
          return true;
        },
      );

      expect(result, isTrue);
      expect(callbackInvoked, isTrue);

      final stored = await secureStorage.readHostKeyFingerprint(
        'server-confirm',
      );
      expect(stored, 'ssh-ed25519:05:06:07:08');
    });

    test(
      'verifyHostKey aborts and does not pin if user rejects TOFU [SEC-004]',
      () async {
        final fp = Uint8List.fromList([9, 10, 11, 12]);

        expect(
          () => hostKeyService.verifyHostKey(
            'server-reject',
            'ssh-ed25519',
            fp,
            onConfirm: (serverId, formattedFp) async => false,
          ),
          throwsA(isA<HostKeyMismatchException>()),
        );

        final stored = await secureStorage.readHostKeyFingerprint(
          'server-reject',
        );
        expect(stored, isNull);
      },
    );

    test(
      'Stored legacy digest format migrates and matches new format with type prefix',
      () async {
        // Pre-save fingerprint in legacy format (hash only)
        await secureStorage.saveHostKeyFingerprint(
          'server-migrate',
          'SHA256:4y+0wZ1V5K2s/m8+Z0rB8z7lDq0QJ5l0',
        );

        final asciiBytes = Uint8List.fromList(
          ascii.encode('SHA256:4y+0wZ1V5K2s/m8+Z0rB8z7lDq0QJ5l0'),
        );

        // Verify should succeed and migrate the stored key to include type prefix
        final result = await hostKeyService.verifyHostKey(
          'server-migrate',
          'ssh-ed25519',
          asciiBytes,
        );

        expect(result, isTrue);

        final storedAfter = await secureStorage.readHostKeyFingerprint(
          'server-migrate',
        );
        expect(
          storedAfter,
          'ssh-ed25519 SHA256:4y+0wZ1V5K2s/m8+Z0rB8z7lDq0QJ5l0',
        );
      },
    );

    test(
      'Stored legacy colon-hex encoded ASCII string migrates and matches new format',
      () async {
        // Pre-save fingerprint in legacy colon-hex encoded ASCII format
        // Exactly matching the user's issue: "ssh-ed25519:53:48:41:32:35:36:3a:53:5a:72..."
        await secureStorage.saveHostKeyFingerprint(
          'server-colon-hex',
          'ssh-ed25519:53:48:41:32:35:36:3a:53:5a:72:50:4a:2f:43:42:4f:73:4a:56:57:4d:69:49:61:34:6a:2b:4f:72:66:2b:72:34:73:68:76:67:33:71:64:55:63:76:7a:79:54:33:65:31:77',
        );

        final asciiBytes = Uint8List.fromList(
          ascii.encode('SHA256:SZrPJ/CBOsJVWMiIa4j+Orf+r4shvg3qdUcvzyT3e1w'),
        );

        // Verify should succeed without error and migrate the stored key
        final result = await hostKeyService.verifyHostKey(
          'server-colon-hex',
          'ssh-ed25519',
          asciiBytes,
        );

        expect(result, isTrue);

        final storedAfter = await secureStorage.readHostKeyFingerprint(
          'server-colon-hex',
        );
        expect(
          storedAfter,
          'ssh-ed25519 SHA256:SZrPJ/CBOsJVWMiIa4j+Orf+r4shvg3qdUcvzyT3e1w',
        );
      },
    );

    test('resetHostKey deletes pinned host key fingerprint', () async {
      await secureStorage.saveHostKeyFingerprint(
        'server-del',
        'ssh-rsa:11:22:33',
      );
      expect(
        await secureStorage.readHostKeyFingerprint('server-del'),
        isNotNull,
      );

      await hostKeyService.resetHostKey('server-del');
      expect(await secureStorage.readHostKeyFingerprint('server-del'), isNull);
    });
  });
}
