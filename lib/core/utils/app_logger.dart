import 'package:flutter/foundation.dart';

/// Secure centralized application logger that gates all log output behind [kDebugMode]
/// and ensures sensitive payloads (passwords, private keys, raw telemetry, credentials)
/// are never emitted into system console / logcat in production release binaries [SEC-019].
class AppLogger {
  AppLogger._();

  /// Logs a debug message in debug and profile modes.
  static void debug(String message) {
    if (!kReleaseMode) {
      debugPrint(message);
    }
  }

  /// Logs an informational message in debug and profile modes.
  static void info(String message) {
    if (!kReleaseMode) {
      debugPrint('[INFO] $message');
    }
  }

  /// Logs a warning message in debug and profile modes.
  static void warning(String message) {
    if (!kReleaseMode) {
      debugPrint('[WARN] $message');
    }
  }

  /// Logs an error message in debug and profile modes.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!kReleaseMode) {
      debugPrint('[ERROR] $message${error != null ? ': $error' : ''}');
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }
}
