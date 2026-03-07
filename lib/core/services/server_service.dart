import 'package:isar/isar.dart';
import 'package:orbit/core/data/entities/isar_server.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

class ServerService {
  final Isar _isar;

  ServerService(this._isar);

  Future<List<Server>> getServers() async {
    final isarServers = await _isar.isarServers.where().findAll();
    return isarServers.map((e) => _mapToDomain(e)).toList();
  }

  Future<void> addServer(Server server) async {
    final isarServer = _mapToEntity(server);
    await _isar.writeTxn(() async {
      await _isar.isarServers.put(isarServer);
    });
  }

  Future<void> updateServer(Server server) async {
    // Isar put overwrites if id matches, but here we match by UUID index logic if we wanted,
    // but put uses internal ID.
    // We first find the existing entity to preserve its internal ID.
    final existing =
        await _isar.isarServers.filter().uuidEqualTo(server.id).findFirst();

    if (existing != null) {
      final updated = _mapToEntity(server);
      updated.id = existing.id; // Preserve internal ID for update
      await _isar.writeTxn(() async {
        await _isar.isarServers.put(updated);
      });
    }
  }

  Future<void> deleteServer(String serverId) async {
    await _isar.writeTxn(() async {
      await _isar.isarServers.filter().uuidEqualTo(serverId).deleteAll();
    });
  }

  Future<void> updateSnapshot(String serverId, ServerStats stats) async {
    final existing =
        await _isar.isarServers.filter().uuidEqualTo(serverId).findFirst();

    if (existing != null) {
      await _isar.writeTxn(() async {
        existing
          ..lastCpu = stats.cpuPct
          ..lastRam = stats.ramPct
          ..lastDisk = stats.diskPct
          ..lastDiskUsed = stats.diskUsed
          ..lastDiskTotal = stats.diskTotal
          ..serverLocation = stats.serverLocation
          ..lastSeen = DateTime.now();
        await _isar.isarServers.put(existing);
      });
    }
  }

  // --- Mappers ---

  Server _mapToDomain(IsarServer entity) {
    return Server(
      id: entity.uuid,
      name: entity.name,
      hostname: entity.hostname,
      port: entity.port,
      username: entity.username,
      password: entity.password,
      authType: entity.authType,
      status: entity.status,

      // Snapshot
      lastCpu: entity.lastCpu,
      lastRam: entity.lastRam,
      lastDisk: entity.lastDisk,
      lastDiskUsed: entity.lastDiskUsed ?? 0,
      lastDiskTotal: entity.lastDiskTotal ?? 0,
      lastSeen: entity.lastSeen,

      // Metadata
      osDistro: entity.osDistro ?? '',
      kernelVersion: entity.kernelVersion ?? '',
      uptime: entity.uptime ?? '',
      hostnameInfo: entity.hostnameInfo ?? '',
      ipAddress: entity.ipAddress ?? '', // Added IP mapping
      serverLocation: entity.serverLocation ?? '',
      lastLatency: entity.lastLatency ?? 0,
    );
  }

  IsarServer _mapToEntity(Server domain) {
    return IsarServer()
      ..uuid = domain.id
      ..name = domain.name
      ..hostname = domain.hostname
      ..port = domain.port
      ..username = domain.username
      ..password = domain.password
      ..authType = domain.authType
      ..status = domain.status

      // Snapshot
      ..lastCpu = domain.lastCpu
      ..lastRam = domain.lastRam
      ..lastDisk = domain.lastDisk
      ..lastDiskUsed = domain.lastDiskUsed
      ..lastDiskTotal = domain.lastDiskTotal
      ..lastSeen = domain.lastSeen

      // Metadata
      ..osDistro = domain.osDistro
      ..kernelVersion = domain.kernelVersion
      ..uptime = domain.uptime
      ..hostnameInfo = domain.hostnameInfo
      ..ipAddress = domain.ipAddress // Added IP mapping
      ..serverLocation = domain.serverLocation
      ..lastLatency = domain.lastLatency;
  }
}
