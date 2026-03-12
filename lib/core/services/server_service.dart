import 'package:orbit/core/models/server.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/features/dashboard/repositories/server_repository.dart';

class ServerService {
  final ServerRepository _repository;

  ServerService(this._repository);

  Future<List<Server>> getServers() async {
    final stream = _repository.watchAllServers();
    return stream.first;
  }

  Future<void> addServer(Server server) async {
    await _repository.addServer(server);
  }

  Future<void> updateServer(Server server) async {
    await _repository.updateServer(server);
  }

  Future<void> deleteServer(String serverId) async {
    await _repository.deleteServer(serverId);
  }

  Future<void> updateSnapshot(String serverId, ServerStats stats) async {
    final server = await _repository.getServerById(serverId);
    if (server != null) {
      final updated = server.copyWith(
        lastCpu: stats.cpuPct,
        lastRam: stats.ramPct,
        lastDisk: stats.diskPct,
        lastDiskUsed: stats.diskUsed,
        lastDiskTotal: stats.diskTotal,
        serverLocation: stats.serverLocation,
        lastSeen: DateTime.now(),
      );
      await _repository.updateServer(updated);
    }
  }
}
