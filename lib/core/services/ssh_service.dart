import 'dart:developer' as developer;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:orbit/core/services/secure_storage_service.dart';

// A factory function for creating SSHClient instances, allowing for mocking in tests.
typedef SSHClientFactory = Future<SSHClient> Function(
  String host,
  int port,
  String username,
  String? password,
  String? privateKey,
);

Future<SSHClient> _defaultClientFactory(
  String host,
  int port,
  String username,
  String? password,
  String? privateKey,
) async {
  final socket = await SSHSocket.connect(host, port);

  // Normalize the PEM key to fix trailing-space and missing-newline issues
  // that cause `FormatException: PEM header must end with -----`.
  final normalizedKey =
      privateKey != null ? SshService.normalizePem(privateKey) : null;

  debugPrint(
      "SSH: Secure Vault Private Key length: ${normalizedKey?.length ?? 0}");

  return SSHClient(
    socket,
    username: username,
    onPasswordRequest: () => password ?? '',
    identities: normalizedKey != null && normalizedKey.trim().isNotEmpty
        ? SSHKeyPair.fromPem(normalizedKey, password)
        : null,
  );
}

class SshService {
  final SecureStorageService _secureStorage;

  SshService(this._secureStorage);

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
    final securePassword =
        await _secureStorage.readCredential(serverId, 'password');
    final securePrivateKey =
        await _secureStorage.readCredential(serverId, 'privateKey');

    // Coerce an empty string to null — dartssh2 throws
    // "Passphrase is not required for unencrypted keys" if an empty
    // string (not null) is passed to SSHKeyPair.fromPem for a plain key.
    final String? validPassphrase =
        (securePassword != null && securePassword.trim().isNotEmpty)
            ? securePassword
            : null;

    debugPrint(
        'SSH: JIT fetch — password: ${validPassphrase != null ? "present" : "empty/null"}, '
        'privateKey length: ${securePrivateKey?.length ?? 0}');

    try {
      // Robustness: Sometime users enter "IP:Port" in the hostname field.
      // We strip the port if detected (IPv4 only logic for simplicity).
      var cleanHost = host;
      if (host.contains(':') && !host.contains(']')) {
        final parts = host.split(':');
        if (parts.length == 2 && int.tryParse(parts[1]) != null) {
          cleanHost = parts[0];
          debugPrint('SSH: Sanitized host from "$host" to "$cleanHost"');
        }
      }

      debugPrint(
          'SSH: Attempting connection to ${cleanHost.replaceAll(RegExp(r'\d'), '*')}:$port...');
      final client = await (clientFactory ?? _defaultClientFactory)(
              cleanHost, port, username, validPassphrase, securePrivateKey)
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timed out'),
      );

      try {
        await client.authenticated;
      } on SSHKeyDecryptError {
        client.close();
        throw Exception('Invalid Passphrase for Private Key');
      } on SSHAuthFailError catch (e, s) {
        client.close();
        if (kDebugMode) {
          print('SSH authentication failed: $e');
        }
        developer.log(
          'SSH authentication failed',
          name: 'SshService',
          error: e,
          stackTrace: s,
        );
        throw Exception('Invalid Private Key Format or Auth Failed');
      }

      debugPrint('SSH: Authenticated!');
      return client;
    } catch (e, s) {
      if (e is! Exception) {
        if (kDebugMode) {
          print('SSH connection failed: $e');
        }
        developer.log(
          'SSH connection failed',
          name: 'SshService',
          error: e,
          stackTrace: s,
        );
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
      final result = await client.run(command).timeout(
            Duration(seconds: commandTimeoutSeconds),
            onTimeout: () => throw Exception('Command execution timed out'),
          );
      return String.fromCharCodes(result);
    } catch (e) {
      rethrow;
    } finally {
      client?.close();
    }
  }
}
