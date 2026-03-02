import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/services/server_service.dart';
import 'package:orbit/core/services/ssh_service.dart';
import 'package:orbit/core/services/isar_service.dart';
import 'package:orbit/features/dashboard/repositories/server_repository.dart';

final serverServiceProvider = FutureProvider<ServerService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ServerService(isar);
});

final sshServiceProvider = Provider((ref) => SshService());

// Legacy provider - kept for backward compatibility
final serverListProvider = FutureProvider<List<Server>>((ref) async {
  final service = await ref.watch(serverServiceProvider.future);
  return service.getServers();
});

// --- New MVVM Providers ---

/// Repository provider - single source of truth for server data
final serverRepositoryProvider = FutureProvider<ServerRepository>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return ServerRepository(isar);
});

/// Stream provider for reactive UI updates
/// UI should watch this instead of serverListProvider
final serverListStreamProvider = StreamProvider<List<Server>>((ref) async* {
  final repository = await ref.watch(serverRepositoryProvider.future);
  yield* repository.watchAllServers();
});
