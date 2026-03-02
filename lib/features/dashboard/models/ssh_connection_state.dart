/// Per-server SSH connection state, exposed by [ServerMonitorViewModel]
/// and consumed by [DashboardScreen] for UI feedback.
enum SshConnectionState {
  /// Initial SSH handshake in progress (first connect or after reconnect decision)
  connecting,

  /// SSH session active and polling successfully
  connected,

  /// SSH session lost; actively retrying (network present but SSH dropped)
  reconnecting,

  /// Device has no network; polling paused entirely
  offline,
}
