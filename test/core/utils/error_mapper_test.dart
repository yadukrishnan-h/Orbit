import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/utils/error_mapper.dart';

void main() {
  group('ErrorMapper [UI-006]', () {
    test('maps TimeoutException to user friendly message', () {
      final msg = ErrorMapper.userFriendlyMessage(
        TimeoutException('Operation timed out'),
      );
      expect(msg, 'Connection timed out. The server did not respond in time.');
    });

    test('maps SocketException connection refused to user friendly message', () {
      final msg = ErrorMapper.userFriendlyMessage(
        const SocketException(
          'OS Error: Connection refused, errno = 111, address = 192.168.1.1, port = 22',
        ),
      );
      expect(
        msg,
        'Connection refused: Target server is unreachable or port is closed.',
      );
    });

    test(
      'maps SocketException network unreachable to user friendly message',
      () {
        final msg = ErrorMapper.userFriendlyMessage(
          const SocketException(
            'OS Error: Network is unreachable, errno = 101',
          ),
        );
        expect(
          msg,
          'Network is unreachable. Please check your internet connection.',
        );
      },
    );

    test('maps SocketException no route to host to user friendly message', () {
      final msg = ErrorMapper.userFriendlyMessage(
        const SocketException('OS Error: No route to host, errno = 113'),
      );
      expect(msg, 'Cannot reach host: No route to the specified address.');
    });

    test('maps host key mismatch errors safely', () {
      final msg = ErrorMapper.userFriendlyMessage(
        'Host key mismatch detected for server',
      );
      expect(
        msg,
        'Host key verification failed: The server fingerprint did not match.',
      );
    });

    test('maps authentication errors safely', () {
      final msg = ErrorMapper.userFriendlyMessage(
        'SSH auth failed: Invalid credentials',
      );
      expect(
        msg,
        'Authentication failed: Please verify your username, password, or SSH key.',
      );
    });

    test(
      'strips common Exception prefixes and truncates multi-line stack traces',
      () {
        final msg = ErrorMapper.userFriendlyMessage(
          'Exception: Custom business error occurred\nat file.dart:100\nat main.dart:20',
        );
        expect(msg, 'Custom business error occurred');
      },
    );

    test('maps SSHAuthAbortError connection closed before authentication', () {
      final msg = ErrorMapper.userFriendlyMessage(
        'SSHAuthAbortError(Connection closed before authentication)',
      );
      expect(
        msg,
        'Connection closed by server before authentication. Retrying...',
      );
    });

    test('handles null gracefully', () {
      final msg = ErrorMapper.userFriendlyMessage(null);
      expect(msg, 'An unexpected error occurred. Please try again.');
    });
  });
}
