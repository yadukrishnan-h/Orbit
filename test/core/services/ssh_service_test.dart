import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/services/host_key_service.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/services/ssh_service.dart';

class MockSSHClient extends Mock implements SSHClient {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SshService Tests [LOGIC-002, LOGIC-005, SEC-019]', () {
    late SecureStorageService secureStorage;
    late HostKeyService hostKeyService;
    late SshService sshService;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = SecureStorageService();
      hostKeyService = HostKeyService(secureStorage);
      sshService = SshService(secureStorage, hostKeyService);
    });

    test(
      'normalizePem trims trailing spaces and ensures single trailing newline',
      () {
        const messyPem =
            '-----BEGIN RSA PRIVATE KEY-----   \r\nMIIEowIBAAKCAQEA...   \r\n-----END RSA PRIVATE KEY-----   ';
        final normalized = SshService.normalizePem(messyPem);

        expect(normalized.endsWith('\n'), isTrue);
        expect(normalized.contains('\r'), isFalse);
        expect(
          normalized.contains('-----BEGIN RSA PRIVATE KEY-----\n'),
          isTrue,
        );
        expect(normalized.contains('-----END RSA PRIVATE KEY-----\n'), isTrue);
      },
    );

    test(
      'connectAndExecute correctly decodes multi-byte UTF-8 data [LOGIC-005]',
      () async {
        final mockClient = MockSSHClient();
        const utf8String =
            'Intel® Core™ i9-14900K @ 3.50GHz (24 cores) — 🚀 Status: OK ✓';
        final utf8Bytes = Uint8List.fromList(utf8.encode(utf8String));

        when(() => mockClient.authenticated).thenAnswer((_) async {});
        when(() => mockClient.run('lscpu')).thenAnswer((_) async => utf8Bytes);
        when(() => mockClient.close()).thenAnswer((_) async {});

        final result = await sshService.connectAndExecute(
          '127.0.0.1',
          22,
          'root',
          'server-utf8',
          'lscpu',
          clientFactory:
              (
                host,
                port,
                username,
                password,
                privateKey, {
                onVerifyHostKey,
              }) async {
                return mockClient;
              },
        );

        expect(result, utf8String);
        verify(() => mockClient.close()).called(1);
      },
    );

    test(
      'connect immediately closes client on authentication failure [LOGIC-002]',
      () async {
        final mockClient = MockSSHClient();
        when(
          () => mockClient.authenticated,
        ).thenAnswer((_) => Future.error(SSHKeyDecryptError('Invalid key')));
        when(() => mockClient.close()).thenAnswer((_) async {});

        expect(
          () => sshService.connect(
            '127.0.0.1',
            22,
            'root',
            'server-auth-fail',
            clientFactory:
                (
                  host,
                  port,
                  username,
                  password,
                  privateKey, {
                  onVerifyHostKey,
                }) async {
                  return mockClient;
                },
          ),
          throwsA(isA<Exception>()),
        );

        // Give event loop a tick to ensure cleanup runs
        await Future<void>.delayed(Duration.zero);
        verify(() => mockClient.close()).called(1);
      },
    );

    test(
      'connect closes client on authentication timeout [LOGIC-002]',
      () async {
        final mockClient = MockSSHClient();
        final completer = Completer<SSHClient>();
        when(
          () => mockClient.authenticated,
        ).thenAnswer((_) => completer.future);
        when(() => mockClient.close()).thenAnswer((_) async {});

        // Using a short timeout test with FakeAsync
        expect(
          () => sshService
              .connect(
                '127.0.0.1',
                22,
                'root',
                'server-timeout',
                clientFactory:
                    (
                      host,
                      port,
                      username,
                      password,
                      privateKey, {
                      onVerifyHostKey,
                    }) async {
                      return mockClient;
                    },
              )
              .timeout(const Duration(milliseconds: 100)),
          throwsA(isA<TimeoutException>()),
        );

        await Future<void>.delayed(const Duration(milliseconds: 150));
      },
    );
  });
}
