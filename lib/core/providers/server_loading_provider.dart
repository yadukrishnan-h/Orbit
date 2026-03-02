import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the loading state for individual servers
/// Used to block user interactions until initial data is loaded
class ServerLoadingState {
  final bool isLoading;
  final bool hasLoadedOnce;
  final String? errorMessage;

  const ServerLoadingState({
    this.isLoading = true,
    this.hasLoadedOnce = false,
    this.errorMessage,
  });

  ServerLoadingState copyWith({
    bool? isLoading,
    bool? hasLoadedOnce,
    String? errorMessage,
  }) {
    return ServerLoadingState(
      isLoading: isLoading ?? this.isLoading,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier for managing server loading states
class ServerLoadingNotifier
    extends StateNotifier<Map<String, ServerLoadingState>> {
  ServerLoadingNotifier() : super({});

  /// Mark a server as starting to load
  void startLoading(String serverId) {
    state = {
      ...state,
      serverId: ServerLoadingState(isLoading: true, hasLoadedOnce: false),
    };
  }

  /// Mark a server as successfully loaded
  void markLoaded(String serverId) {
    final currentState = state[serverId] ?? const ServerLoadingState();
    state = {
      ...state,
      serverId: currentState.copyWith(
        isLoading: false,
        hasLoadedOnce: true,
        errorMessage: null,
      ),
    };
  }

  /// Mark a server as failed to load
  void markError(String serverId, String error) {
    final currentState = state[serverId] ?? const ServerLoadingState();
    state = {
      ...state,
      serverId: currentState.copyWith(
        isLoading: false,
        hasLoadedOnce: currentState.hasLoadedOnce,
        errorMessage: error,
      ),
    };
  }

  /// Clear error state for retry
  void clearError(String serverId) {
    final currentState = state[serverId] ?? const ServerLoadingState();
    state = {
      ...state,
      serverId: currentState.copyWith(errorMessage: null),
    };
  }

  /// Get loading state for a specific server
  ServerLoadingState getServerState(String serverId) {
    return state[serverId] ?? const ServerLoadingState(isLoading: true);
  }

  /// Check if a server is ready for interaction
  bool isServerReady(String serverId) {
    final serverState =
        state[serverId] ?? const ServerLoadingState(isLoading: true);
    return !serverState.isLoading && serverState.hasLoadedOnce;
  }
}

/// Provider for server loading states
final serverLoadingProvider = StateNotifierProvider<ServerLoadingNotifier,
    Map<String, ServerLoadingState>>(
  (ref) => ServerLoadingNotifier(),
);

/// Extension to easily get loading state
extension ServerLoadingExtension on WidgetRef {
  bool isServerLoading(String serverId) {
    final loadingState = watch(serverLoadingProvider);
    final serverState = loadingState[serverId];
    return serverState?.isLoading ?? true;
  }

  bool isServerReady(String serverId) {
    final loadingState = watch(serverLoadingProvider);
    final serverState = loadingState[serverId];
    return serverState?.hasLoadedOnce ?? false;
  }
}
