import 'package:isar/isar.dart';
import 'package:orbit/core/data/entities/isar_server.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

/// Repository layer for server data management
/// Single source of truth for all server-related data operations
class ServerRepository {
  final Isar _isar;

  ServerRepository(this._isar);

  /// Watch all servers as a reactive stream, ordered by sortOrder.
  /// UI should watch this stream for instant updates
  Stream<List<Server>> watchAllServers() {
    return _isar.isarServers
        .where()
        .watch(fireImmediately: true)
        .map((entities) {
      final sorted = entities.toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return sorted.map(_mapToDomain).toList();
    });
  }

  /// Watch a single server by ID as a reactive stream
  /// Returns null if server doesn't exist
  Stream<Server?> watchServer(String id) {
    return _isar.isarServers
        .filter()
        .uuidEqualTo(id)
        .watch(fireImmediately: true)
        .map((entities) =>
            entities.isNotEmpty ? _mapToDomain(entities.first) : null);
  }

  /// Get a single server by ID
  Future<Server?> getServerById(String id) async {
    final entity = await _isar.isarServers.filter().uuidEqualTo(id).findFirst();
    return entity != null ? _mapToDomain(entity) : null;
  }

  /// Get all servers
  Future<List<Server>> getAllServers() async {
    final entities = await _isar.isarServers.where().findAll();
    return entities.map(_mapToDomain).toList();
  }

  /// Add a new server
  Future<void> addServer(Server server) async {
    final entity = _mapToEntity(server);
    await _isar.writeTxn(() async {
      await _isar.isarServers.put(entity);
    });
  }

  /// Update an existing server
  Future<void> updateServer(Server server) async {
    final existing =
        await _isar.isarServers.filter().uuidEqualTo(server.id).findFirst();

    if (existing != null) {
      final updated = _mapToEntity(server);
      updated.id = existing.id; // Preserve internal ID
      await _isar.writeTxn(() async {
        await _isar.isarServers.put(updated);
      });
    }
  }

  /// Delete a server
  Future<void> deleteServer(String serverId) async {
    await _isar.writeTxn(() async {
      await _isar.isarServers.filter().uuidEqualTo(serverId).deleteAll();
    });
  }

  /// Delete multiple servers at once (bulk delete for ManageServersScreen)
  Future<void> bulkDelete(List<String> uuids) async {
    await _isar.writeTxn(() async {
      for (final uuid in uuids) {
        await _isar.isarServers.filter().uuidEqualTo(uuid).deleteAll();
      }
    });
  }

  /// Reorder servers by persisting the new sortOrder values.
  /// [orderedUuids] is a list of UUIDs in the desired display order.
  Future<void> reorderServers(List<String> orderedUuids) async {
    await _isar.writeTxn(() async {
      for (int i = 0; i < orderedUuids.length; i++) {
        final entity = await _isar.isarServers
            .filter()
            .uuidEqualTo(orderedUuids[i])
            .findFirst();
        if (entity != null) {
          entity.sortOrder = i;
          await _isar.isarServers.put(entity);
        }
      }
    });
  }

  /// Update server snapshot data (called by ViewModel after polling)
  /// This is the key method that enables instant UI updates
  Future<void> updateSnapshot(String serverId, ServerStats stats) async {
    final existing =
        await _isar.isarServers.filter().uuidEqualTo(serverId).findFirst();

    if (existing != null) {
      await _isar.writeTxn(() async {
        existing.lastCpu = stats.cpuPct;
        existing.lastRam = stats.ramPct;
        existing.lastDisk = stats.diskPct;
        existing.lastDiskUsed = stats.diskUsed;
        existing.lastDiskTotal = stats.diskTotal;
        existing.lastSeen = stats.timestamp ?? DateTime.now();

        // Update metadata
        existing.osDistro = stats.osDistro;
        existing.kernelVersion = stats.kernelVersion;
        existing.uptime = stats.uptime;
        // Note: server.hostname is the connection host, hostnameInfo is from the OS
        existing.hostnameInfo = stats.hostname;
        existing.ipAddress = stats.ipAddress; // Persist IP Address
        existing.serverLocation =
            stats.serverLocation; // Persist Server Location
        existing.lastLatency = stats.latencyMs;

        existing.status =
            ServerStatus.online; // Mark as online on successful update

        await _isar.isarServers.put(existing);
      });
    }
  }

  /// Set server status (called by ViewModel on connection errors)
  Future<void> setStatus(String serverId, ServerStatus status) async {
    final existing =
        await _isar.isarServers.filter().uuidEqualTo(serverId).findFirst();

    if (existing != null) {
      await _isar.writeTxn(() async {
        existing.status = status;
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
      lastCpu: entity.lastCpu,
      lastRam: entity.lastRam,
      lastDisk: entity.lastDisk,
      lastDiskUsed: entity.lastDiskUsed ?? 0,
      lastDiskTotal: entity.lastDiskTotal ?? 0,
      lastSeen: entity.lastSeen,
      status: entity.status,
      // Metadata fields
      osDistro: entity.osDistro ?? '',
      kernelVersion: entity.kernelVersion ?? '',
      uptime: entity.uptime ?? '',
      hostnameInfo: entity.hostnameInfo ?? '',
      ipAddress: entity.ipAddress ?? '',
      serverLocation: entity.serverLocation ?? '',
      lastLatency: entity.lastLatency ?? 0,
    );
  }

  IsarServer _mapToEntity(Server domain) {
    final entity = IsarServer()
      ..uuid = domain.id
      ..name = domain.name
      ..hostname = domain.hostname
      ..port = domain.port
      ..username = domain.username
      ..password = domain.password
      ..authType = domain.authType
      ..lastCpu = domain.lastCpu
      ..lastRam = domain.lastRam
      ..lastDisk = domain.lastDisk
      ..lastDiskUsed = domain.lastDiskUsed
      ..lastDiskTotal = domain.lastDiskTotal
      ..lastSeen = domain.lastSeen
      ..status = domain.status
      // Metadata fields
      ..osDistro = domain.osDistro
      ..kernelVersion = domain.kernelVersion
      ..uptime = domain.uptime
      ..hostnameInfo = domain.hostnameInfo
      ..ipAddress = domain.ipAddress
      ..serverLocation = domain.serverLocation
      ..lastLatency = domain.lastLatency;
    return entity;
  }
}
