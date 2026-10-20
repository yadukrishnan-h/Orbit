import 'dart:async';
import 'dart:convert';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:orbit/core/services/host_key_service.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/utils/app_logger.dart';

// A factory function for creating SSHClient instances, allowing for mocking in tests.
typedef SSHClientFactory =
    Future<SSHClient> Function(
      String host,
      int port,
      String username,
      String? password,
      String? privateKey, {
      SSHHostkeyVerifyHandler? onVerifyHostKey,
    });

Future<SSHClient> _defaultClientFactory(
  String host,
  int port,
  String username,
  String? password,
  String? privateKey, {
  SSHHostkeyVerifyHandler? onVerifyHostKey,
}) async {
  // [LOGIC-002]: Pass socket-level timeout directly to prevent hanging background attempts
  final socket = await SSHSocket.connect(
    host,
    port,
    timeout: const Duration(seconds: 10),
  );

  try {
    // Normalize the PEM key to fix trailing-space and missing-newline issues
    // that cause `FormatException: PEM header must end with -----`.
    final normalizedKey = privateKey != null
        ? SshService.normalizePem(privateKey)
        : null;

    return SSHClient(
      socket,
      username: username,
      onPasswordRequest: () => password ?? '',
      identities: normalizedKey != null && normalizedKey.trim().isNotEmpty
          ? SSHKeyPair.fromPem(normalizedKey, password)
          : null,
      onVerifyHostKey: onVerifyHostKey,
    );
  } catch (e) {
    socket.close();
    rethrow;
  }
}

class SshService {
  final SecureStorageService _secureStorage;
  final HostKeyService _hostKeyService;

  SshService(this._secureStorage, [HostKeyService? hostKeyService])
    : _hostKeyService = hostKeyService ?? HostKeyService(_secureStorage);

  /// Normalizes a PEM private key string to make it parseable by dartssh2.
  ///
  /// Mobile clipboard paste frequently introduces:
  /// - Invisible trailing spaces on header/footer lines (breaks the strict
  ///   `-----BEGIN ... -----` check in dartssh2).
  /// - Windows-style `\r\n` line endings.
  /// - Missing final newline (some PEM parsers require it).
  ///
  /// This method trims every line individually, rejoins with `\n`, and
  /// guarantees the string ends with exactly one `\n`.
  static String normalizePem(String rawPem) {
    final lines = rawPem.split(RegExp(r'\r?\n'));
    final trimmed = lines.map((l) => l.trim()).join('\n');
    // Ensure the PEM block ends with exactly one newline.
    return trimmed.endsWith('\n') ? trimmed : '$trimmed\n';
  }

  /// Establishes a persistent SSH connection and returns the client.
  /// Credentials are fetched Just-In-Time from SecureStorage using [serverId],
  /// bypassing any "shallow" Server objects that may have null credentials.
  /// The caller is responsible for closing the client.
  Future<SSHClient> connect(
    String host,
    int port,
    String username,
    String serverId, {
    @visibleForTesting SSHClientFactory? clientFactory,
  }) async {
    // ── JIT Credential Fetch ─────────────────────────────────────────────
    // Always read credentials directly from the secure vault just before
    // connecting. This guarantees we never use stale/null values from a
    // shallow Server object emitted by the Hive stream.
    final securePassword = await _secureStorage.readCredential(
      serverId,
      'password',
    );
    final securePrivateKey = await _secureStorage.readCredential(
      serverId,
      'privateKey',
    );

    // Coerce an empty string to null — dartssh2 throws
    // "Passphrase is not required for unencrypted keys" if an empty
    // string (not null) is passed to SSHKeyPair.fromPem for a plain key.
    final String? validPassphrase =
        (securePassword != null && securePassword.trim().isNotEmpty)
        ? securePassword
        : null;

    SSHClient? client;
    try {
      // Robustness: Sometimes users enter "IP:Port" in the hostname field.
      // We strip the port if detected (IPv4 only logic for simplicity).
      var cleanHost = host;
      if (host.contains(':') && !host.contains(']')) {
        final parts = host.split(':');
        if (parts.length == 2 && int.tryParse(parts[1]) != null) {
          cleanHost = parts[0];
          AppLogger.debug('SSH: Sanitized host from "$host" to "$cleanHost"');
        }
      }

      AppLogger.info(
        'SSH: Attempting connection to ${cleanHost.replaceAll(RegExp(r'\d'), '*')}:$port...',
      );

      // [LOGIC-002]: Enforce timeout on connection creation
      client =
          await (clientFactory ?? _defaultClientFactory)(
            cleanHost,
            port,
            username,
            validPassphrase,
            securePrivateKey,
            onVerifyHostKey: (type, fingerprint) =>
                _hostKeyService.verifyHostKey(serverId, type, fingerprint),
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () =>
                throw TimeoutException('Connection timed out after 10s'),
          );

      // [LOGIC-002]: Enforce timeout on authentication
      try {
        await client.authenticated.timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('Authentication timed out after 10s'),
        );
      } on SSHKeyDecryptError {
        throw Exception('Invalid Passphrase for Private Key');
      } on SSHAuthFailError catch (e, s) {
        AppLogger.error('SSH authentication failed', e, s);
        throw Exception('Invalid Private Key Format or Auth Failed');
      }

      AppLogger.info('SSH: Authenticated successfully');
      return client;
    } catch (e, s) {
      // [LOGIC-002]: Close socket & client immediately on timeout or error to prevent leaks
      client?.close();

      // Unwrap low-level cause from dartssh2's generic SSHAuthAbortError
      if (e is SSHAuthAbortError && e.reason != null) {
        final inner = (e.reason is SSHInternalError)
            ? (e.reason as SSHInternalError).error
            : e.reason;
        AppLogger.error(
          'SSH authentication aborted: ${e.message}, inner: $inner',
        );
        if (inner is Exception) {
          throw inner;
        }
      }

      if (e is! Exception) {
        AppLogger.error('SSH connection failed', e, s);
      }
      rethrow;
    }
  }

  Future<String> connectAndExecute(
    String host,
    int port,
    String username,
    String serverId,
    String command, {
    int commandTimeoutSeconds = 15,
    @visibleForTesting SSHClientFactory? clientFactory,
  }) async {
    SSHClient? client;
    try {
      client = await connect(
        host,
        port,
        username,
        serverId,
        clientFactory: clientFactory,
      );
      final result = await client
          .run(command)
          .timeout(
            Duration(seconds: commandTimeoutSeconds),
            onTimeout: () =>
                throw TimeoutException('Command execution timed out'),
          );
      // [LOGIC-005]: Decode UTF-8 correctly instead of String.fromCharCodes
      return utf8.decode(result, allowMalformed: true);
    } catch (e) {
      rethrow;
    } finally {
      client?.close();
    }
  }
}
