import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/services/isar_service.dart';

/// Connection status enum
enum ConnectionStatus {
  /// Initial state - connecting to database/server
  connecting,

  /// Connection established successfully
  connected,

  /// Connection failed
  error,
}

/// Provider state for connection status
class ConnectionState {
  final ConnectionStatus status;
  final String? errorMessage;
  final double? progress; // For showing loading progress (0.0 to 1.0)

  const ConnectionState({
    this.status = ConnectionStatus.connecting,
    this.errorMessage,
    this.progress,
  });

  ConnectionState copyWith({
    ConnectionStatus? status,
    String? errorMessage,
    double? progress,
  }) {
    return ConnectionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      progress: progress ?? this.progress,
    );
  }

  bool get isConnecting => status == ConnectionStatus.connecting;
  bool get isConnected => status == ConnectionStatus.connected;
  bool get hasError => status == ConnectionStatus.error;
}

/// Provider that manages the initial connection status
final connectionStatusProvider =
    StateNotifierProvider<ConnectionStatusNotifier, ConnectionState>((ref) {
  return ConnectionStatusNotifier(ref);
});

class ConnectionStatusNotifier extends StateNotifier<ConnectionState> {
  final Ref _ref;

  ConnectionStatusNotifier(this._ref) : super(const ConnectionState()) {
    _initializeConnection();
  }

  Future<void> _initializeConnection() async {
    try {
      // Update progress to indicate starting
      state = state.copyWith(progress: 0.1);

      // Initialize Isar database via providers
      await _ref.watch(isarProvider.future);
      state = state.copyWith(progress: 0.3);

      // Initialize server service
      await _ref.watch(serverServiceProvider.future);
      state = state.copyWith(progress: 0.5);

      // Initialize repository
      await _ref.watch(serverRepositoryProvider.future);
      state = state.copyWith(progress: 0.7);

      // Verify we can access servers (even if empty list)
      final repository = await _ref.watch(serverRepositoryProvider.future);
      await repository.watchAllServers().first;
      state = state.copyWith(progress: 0.9);

      // Connection successful
      state = const ConnectionState(
        status: ConnectionStatus.connected,
        progress: 1.0,
      );
    } catch (e, stackTrace) {
      // Connection failed
      state = ConnectionState(
        status: ConnectionStatus.error,
        errorMessage: e.toString(),
      );
      // Log error for debugging
      debugPrint('Connection error: $e\n$stackTrace');
    }
  }

  /// Retry connection after an error
  Future<void> retryConnection() async {
    state = const ConnectionState(status: ConnectionStatus.connecting);
    await _initializeConnection();
  }
}
