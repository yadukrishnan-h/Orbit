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
    AsyncNotifierProvider<ServerMonitorViewModel, ServerMonitorState>(() {
      return ServerMonitorViewModel();
    });

/// Stream provider for watching a single server by ID
/// Returns reactive updates from the database
final serverStreamProvider = StreamProvider.family<Server?, String>((
  ref,
  serverId,
) async* {
  final repository = await ref.watch(serverRepositoryProvider.future);
  yield* repository.watchServer(serverId);
});

/// History provider for charts
/// Uses .select() so a poll on Server A does NOT force widgets watching Server B to rebuild [LOGIC-004].
final serverHistoryProvider = Provider.family<List<ServerStats>, String>((
  ref,
  serverId,
) {
  ref.watch(
    serverMonitorViewModelProvider.select(
      (asyncState) => asyncState.value?.historyTicks[serverId],
    ),
  );
  final vm = ref.read(serverMonitorViewModelProvider.notifier);
  return vm.getHistory(serverId);
});

/// Per-server SSH connection state provider.
/// Uses .select() so connection transitions on Server A do not rebuild widgets watching Server B [LOGIC-004].
final serverConnectionStateProvider =
    Provider.family<SshConnectionState, String>((ref, serverId) {
      final conn = ref.watch(
        serverMonitorViewModelProvider.select(
          (asyncState) =>
              asyncState.value?.connectionStates[serverId] ??
              SshConnectionState.connecting,
        ),
      );
      return conn;
    });
