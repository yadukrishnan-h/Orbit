import 'dart:developer' as developer;
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';

// A factory function for creating SSHClient instances, allowing for mocking in tests.
typedef SSHClientFactory = Future<SSHClient> Function(
  String host,
  int port,
  String username,
  String password,
);

Future<SSHClient> _defaultClientFactory(
  String host,
  int port,
  String username,
  String password,
) async {
  final socket = await SSHSocket.connect(host, port);
  return SSHClient(
    socket,
    username: username,
    onPasswordRequest: () => password,
  );
}

class SshService {
  /// Establishes a persistent SSH connection and returns the client.
  /// The caller is responsible for closing the client.
  Future<SSHClient> connect(
    String host,
    int port,
    String username,
    String password, {
    @visibleForTesting SSHClientFactory? clientFactory,
  }) async {
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
          'SSH: Attempting connection to $cleanHost:$port ($username)...');
      final client = await (clientFactory ?? _defaultClientFactory)(
              cleanHost, port, username, password)
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timed out'),
      );
      debugPrint('SSH: Authenticated!');
      return client;
    } catch (e, s) {
      if (kDebugMode) {
        print('SSH connection failed: $e');
      }
      developer.log(
        'SSH connection failed',
        name: 'SshService',
        error: e,
        stackTrace: s,
      );
      throw Exception('Failed to connect: $e');
    }
  }

  Future<String> connectAndExecute(
    String host,
    int port,
    String username,
    String password,
    String command, {
    @visibleForTesting SSHClientFactory? clientFactory,
  }) async {
    SSHClient? client;
    try {
      client = await connect(
        host,
        port,
        username,
        password,
        clientFactory: clientFactory,
      );
      final result = await client.run(command);
      return String.fromCharCodes(result);
    } catch (e) {
      rethrow;
    } finally {
      client?.close();
    }
  }
}
