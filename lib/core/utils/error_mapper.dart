import 'dart:async';
import 'dart:io';

/// Utility to map low-level exceptions, socket errors, and network failures
/// into clean, user-friendly error messages, preventing raw stack traces or
/// technical connection details from leaking into the UI [UI-006].
class ErrorMapper {
  const ErrorMapper._();

  /// Converts any exception or error object into a clean, human-readable string.
  static String userFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred. Please try again.';
    }

    final raw = error.toString().trim();

    // Check for TimeoutException
    if (error is TimeoutException ||
        raw.contains('TimeoutException') ||
        raw.toLowerCase().contains('timed out')) {
      return 'Connection timed out. The server did not respond in time.';
    }

    // Check for SocketException
    if (error is SocketException || raw.contains('SocketException')) {
      final lower = raw.toLowerCase();
      if (lower.contains('connection refused') ||
          lower.contains('errno = 111')) {
        return 'Connection refused: Target server is unreachable or port is closed.';
      }
      if (lower.contains('network is unreachable') ||
          lower.contains('errno = 101')) {
        return 'Network is unreachable. Please check your internet connection.';
      }
      if (lower.contains('no route to host') || lower.contains('errno = 113')) {
        return 'Cannot reach host: No route to the specified address.';
      }
      if (lower.contains('failed host lookup') ||
          lower.contains('nodename nor servname provided')) {
        return 'Could not resolve server hostname. Please verify the host address.';
      }
      return 'Network connection error: Unable to reach the server.';
    }

    // Check for SSHAuthAbortError or transport closures before auth
    if (raw.contains('SSHAuthAbortError') ||
        raw.contains('Connection closed before authentication') ||
        raw.contains('closed before authentication')) {
      return 'Connection closed by server before authentication. Retrying...';
    }

    // Check for Host Key verification failures
    final lower = raw.toLowerCase();
    if (lower.contains('host key') &&
        (lower.contains('mismatch') ||
            lower.contains('changed') ||
            lower.contains('rejected') ||
            lower.contains('failed'))) {
      return 'Host key verification failed: The server fingerprint did not match.';
    }

    // Check for Genuine Authentication failures
    if (lower.contains('all authentication methods failed') ||
        lower.contains('invalid passphrase') ||
        lower.contains('invalid private key') ||
        lower.contains('invalid username or password') ||
        (lower.contains('auth') &&
            (lower.contains('fail') ||
                lower.contains('denied') ||
                lower.contains('invalid')))) {
      return 'Authentication failed: Please verify your username, password, or SSH key.';
    }
    if (lower.contains('permission denied')) {
      return 'Permission denied: You do not have access to this resource.';
    }

    // Check for Disk / Quota errors
    if (lower.contains('no space left on device') ||
        lower.contains('disk quota exceeded')) {
      return 'Storage error: Remote disk is full.';
    }

    // Handshake or TLS / SSH protocol error
    if (lower.contains('handshake') ||
        lower.contains('protocol error') ||
        lower.contains('kex')) {
      return 'Connection protocol error during secure handshake.';
    }

    // Clean up common Dart/Flutter prefixes like "Exception: ", "StateError: ", etc.
    String cleanMessage = raw;
    final prefixes = [
      'Exception: ',
      'FormatException: ',
      'StateError: ',
      'ArgumentError: ',
      'FileSystemException: ',
    ];
    for (final prefix in prefixes) {
      if (cleanMessage.startsWith(prefix)) {
        cleanMessage = cleanMessage.substring(prefix.length).trim();
      }
    }

    // If message is still excessively long or looks like a stack trace, truncate gracefully
    if (cleanMessage.contains('\n')) {
      cleanMessage = cleanMessage.split('\n').first.trim();
    }

    if (cleanMessage.isEmpty) {
      return 'An unexpected error occurred. Please try again.';
    }

    return cleanMessage;
  }
}
