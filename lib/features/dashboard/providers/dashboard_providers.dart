// export 'package:orbit/features/dashboard/services/polling_service.dart'; // Removed deprecated service

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/features/dashboard/models/ssh_connection_state.dart';
import 'package:orbit/features/dashboard/viewmodels/server_monitor_viewmodel.dart';

/// ViewModel provider for background server monitoring
/// Manages persistent SSH connections and background polling
final serverMonitorViewModelProvider =
    AsyncNotifierProvider<ServerMonitorViewModel, void>(() {
  return ServerMonitorViewModel();
});

/// Stream provider for watching a single server by ID
/// Returns reactive updates from the database
final serverStreamProvider =
    StreamProvider.family<Server?, String>((ref, serverId) async* {
  final repository = await ref.watch(serverRepositoryProvider.future);
  yield* repository.watchServer(serverId);
});

/// History provider for charts
/// Accessed by UI to get historical data for a specific server
final serverHistoryProvider =
    Provider.family<List<ServerStats>, String>((ref, serverId) {
  ref.watch(serverMonitorViewModelProvider);
  final vm = ref.read(serverMonitorViewModelProvider.notifier);
  return vm.getHistory(serverId);
});

/// Per-server SSH connection state provider.
/// Rebuilds whenever the ViewModel emits a state change — which happens on
/// every successful poll AND on every connection state transition.
final serverConnectionStateProvider =
    Provider.family<SshConnectionState, String>((ref, serverId) {
  // Watch the VM so this provider rebuilds on every VM state emission
  ref.watch(serverMonitorViewModelProvider);
  return ref
      .read(serverMonitorViewModelProvider.notifier)
      .getConnectionState(serverId);
});
