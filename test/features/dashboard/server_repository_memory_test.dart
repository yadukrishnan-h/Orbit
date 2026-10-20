import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:orbit/core/data/entities/hive_server.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/features/dashboard/repositories/server_repository.dart';

class MockHiveBox extends Mock implements Box<HiveServer> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group(
    'ServerRepository Memory Hygiene & IPC Storm Prevention [SEC-005, SEC-006, LOGIC-009]',
    () {
      late MockHiveBox mockBox;
      late SecureStorageService secureStorage;
      late ServerRepository repository;

      setUp(() {
        FlutterSecureStorage.setMockInitialValues({});
        mockBox = MockHiveBox();
        secureStorage = SecureStorageService();
        repository = ServerRepository(mockBox, secureStorage);
      });

      test(
        'getAllServers strips password and privateKey from in-memory domain models',
        () async {
          final hiveServer = HiveServer(
            uuid: 'srv-1',
            name: 'Production DB',
            hostname: '192.168.1.50',
            port: 22,
            username: 'postgres',
            authType: AuthType.key,
          );

          // Stored in secure storage
          await secureStorage.saveCredential(
            'srv-1',
            'password',
            'super-secret-passphrase',
          );
          await secureStorage.saveCredential(
            'srv-1',
            'privateKey',
            '-----BEGIN RSA PRIVATE KEY-----...',
          );

          when(() => mockBox.values).thenReturn([hiveServer]);

          final servers = await repository.getAllServers();
          expect(servers.length, 1);
          final server = servers.first;

          // Sensitive credentials must be stripped in memory
          expect(server.password, isEmpty);
          expect(server.privateKey, isNull);
        },
      );

      test(
        'watchAllServers emits synchronously without Keystore IPC calls',
        () async {
          final hiveServer = HiveServer(
            uuid: 'srv-stream',
            name: 'Stream Server',
            hostname: '10.0.0.5',
            port: 22,
            username: 'admin',
            authType: AuthType.password,
          );

          when(() => mockBox.values).thenReturn([hiveServer]);
          when(() => mockBox.watch()).thenAnswer((_) => const Stream.empty());

          final stream = repository.watchAllServers();
          final emitted = await stream.first;

          expect(emitted.length, 1);
          expect(emitted.first.id, 'srv-stream');
          expect(emitted.first.password, isEmpty);
          expect(emitted.first.privateKey, isNull);
        },
      );

      test(
        'getServerWithCredentials fetches password and privateKey JIT for editing',
        () async {
          final hiveServer = HiveServer(
            uuid: 'srv-edit',
            name: 'Edit Server',
            hostname: '10.0.0.99',
            port: 2200,
            username: 'root',
            authType: AuthType.key,
          );

          await secureStorage.saveCredential(
            'srv-edit',
            'password',
            'my-key-passphrase',
          );
          await secureStorage.saveCredential(
            'srv-edit',
            'privateKey',
            '-----BEGIN OPENSSH PRIVATE KEY-----',
          );

          when(() => mockBox.get('srv-edit')).thenReturn(hiveServer);

          final serverWithCreds = await repository.getServerWithCredentials(
            'srv-edit',
          );

          expect(serverWithCreds.id, 'srv-edit');
          expect(serverWithCreds.password, 'my-key-passphrase');
          expect(
            serverWithCreds.privateKey,
            '-----BEGIN OPENSSH PRIVATE KEY-----',
          );
        },
      );
    },
  );
}
