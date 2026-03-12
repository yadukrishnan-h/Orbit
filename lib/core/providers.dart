import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/services/server_service.dart';
import 'package:orbit/core/services/ssh_service.dart';
import 'package:orbit/core/services/hive_service.dart';
import 'package:orbit/features/dashboard/repositories/server_repository.dart';
import 'package:orbit/core/services/secure_storage_service.dart';

final serverServiceProvider = FutureProvider<ServerService>((ref) async {
  final repository = await ref.watch(serverRepositoryProvider.future);
  return ServerService(repository);
});

final sshServiceProvider = Provider((ref) {
  final secureStorage = ref.read(secureStorageServiceProvider);
  return SshService(secureStorage);
});

// Legacy serverListProvider removed in favor of MVVM stream provider.

// --- New MVVM Providers ---

/// Repository provider - single source of truth for server data
final serverRepositoryProvider = FutureProvider<ServerRepository>((ref) async {
  final hiveBox = await ref.watch(hiveProvider.future);
  final secureStorage = ref.read(secureStorageServiceProvider);
  return ServerRepository(hiveBox, secureStorage);
});

/// Stream provider for reactive UI updates
/// UI should watch this instead of serverListProvider
final serverListStreamProvider = StreamProvider<List<Server>>((ref) async* {
  final repository = await ref.watch(serverRepositoryProvider.future);
  yield* repository.watchAllServers();
});
