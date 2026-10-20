import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orbit/core/data/entities/hive_server.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';

/// Repository layer for server data management
/// Single source of truth for all server-related data operations
class ServerRepository {
  final Box<HiveServer> _box;
  final SecureStorageService _secureStorage;

  ServerRepository(this._box, this._secureStorage);

  /// Watch all servers as a reactive stream, ordered by sortOrder.
  /// UI should watch this stream for instant updates without Keystore IPC storms [LOGIC-009, SEC-005, SEC-006].
  Stream<List<Server>> watchAllServers() async* {
    yield getAllServersSync();
    yield* _box.watch().map((_) => getAllServersSync());
  }

  /// Watch a single server by ID as a reactive stream
  /// Returns null if server doesn't exist
  Stream<Server?> watchServer(String id) async* {
    yield getServerByIdSync(id);
    yield* _box.watch(key: id).map((_) => getServerByIdSync(id));
  }

  /// Get a single server by ID synchronously (without in-memory credentials [SEC-005, SEC-006])
  Server? getServerByIdSync(String id) {
    final entity = _box.get(id);
    return entity != null ? _mapToDomain(entity) : null;
  }

  /// Get a single server by ID (without in-memory credentials [SEC-005, SEC-006])
  Future<Server?> getServerById(String id) async {
    return getServerByIdSync(id);
  }

  /// Get all servers synchronously (without in-memory credentials [SEC-005, SEC-006])
  List<Server> getAllServersSync() {
    final entities = _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return entities.map(_mapToDomain).toList();
  }

  /// Get all servers (without in-memory credentials [SEC-005, SEC-006])
  Future<List<Server>> getAllServers() async {
    return getAllServersSync();
  }

  /// Dedicated method strictly for EditServerScreen or credential editing flows [SEC-005, SEC-006].
  /// Fetches password/passphrase and private key JIT from secure storage.
  Future<Server> getServerWithCredentials(String serverId) async {
    final entity = _box.get(serverId);
    if (entity == null) {
      throw StateError('Server with ID $serverId not found');
    }
    final password =
        await _secureStorage.readCredential(serverId, 'password') ?? '';
    final privateKey = await _secureStorage.readCredential(
      serverId,
      'privateKey',
    );
    return _mapToDomain(
      entity,
    ).copyWith(password: password, privateKey: privateKey);
  }

  /// Add a new server
  Future<void> addServer(Server server) async {
    final entity = _mapToEntity(server);
    await _box.put(server.id, entity);

    await _secureStorage.saveCredential(server.id, 'password', server.password);
    if (server.privateKey != null) {
      await _secureStorage.saveCredential(
        server.id,
        'privateKey',
        server.privateKey!,
      );
    }
  }

  /// Update an existing server
  Future<void> updateServer(Server server) async {
    final updated = _mapToEntity(server);
    await _box.put(server.id, updated);

    await _secureStorage.saveCredential(server.id, 'password', server.password);
    if (server.privateKey != null) {
      await _secureStorage.saveCredential(
        server.id,
        'privateKey',
        server.privateKey!,
      );
    }
  }

  /// Delete a server
  Future<void> deleteServer(String serverId) async {
    await _box.delete(serverId);
    await _secureStorage.deleteCredentials(serverId);
  }

  /// Delete multiple servers at once (bulk delete for ManageServersScreen)
  Future<void> bulkDelete(List<String> uuids) async {
    await _box.deleteAll(uuids);
    for (final uuid in uuids) {
      await _secureStorage.deleteCredentials(uuid);
    }
  }

  /// Reorder servers by persisting the new sortOrder values.
  /// [orderedUuids] is a list of UUIDs in the desired display order.
  Future<void> reorderServers(List<String> orderedUuids) async {
    for (int i = 0; i < orderedUuids.length; i++) {
      final key = orderedUuids[i];
      final entity = _box.get(key);
      if (entity != null) {
        entity.sortOrder = i;
        await _box.put(key, entity);
      }
    }
  }

  /// Update server snapshot data (called by ViewModel after polling)
  /// This is the key method that enables instant UI updates
  Future<void> updateSnapshot(String serverId, ServerStats stats) async {
    final existing = _box.get(serverId);

    if (existing != null) {
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
      existing.serverLocation = stats.serverLocation; // Persist Server Location
      existing.lastLatency = stats.latencyMs;

      existing.status =
          ServerStatus.online; // Mark as online on successful update

      existing.lastRamUsed = stats.ramUsed;
      existing.lastRamTotal = stats.ramTotal;
      existing.cpuModel = stats.cpuModel;
      existing.cpuCores = stats.cpuCores;
      existing.cpuSpeed = stats.cpuSpeed;

      await _box.put(serverId, existing);
    }
  }

  /// Set server status (called by ViewModel on connection errors)
  Future<void> setStatus(String serverId, ServerStatus status) async {
    final existing = _box.get(serverId);

    if (existing != null) {
      existing.status = status;
      await _box.put(serverId, existing);
    }
  }

  // --- Mappers ---

  Server _mapToDomain(HiveServer entity) {
    return Server(
      id: entity.uuid,
      name: entity.name,
      hostname: entity.hostname,
      port: entity.port,
      username: entity.username,
      password: '',
      privateKey: null,
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
      lastRamUsed: entity.lastRamUsed ?? 0,
      lastRamTotal: entity.lastRamTotal ?? 0,
      cpuModel: entity.cpuModel ?? '',
      cpuCores: entity.cpuCores ?? 0,
      cpuSpeed: entity.cpuSpeed ?? '',
    );
  }

  HiveServer _mapToEntity(Server domain) {
    return HiveServer(
      uuid: domain.id,
      name: domain.name,
      hostname: domain.hostname,
      port: domain.port,
      username: domain.username,
      authType: domain.authType,
      lastCpu: domain.lastCpu,
      lastRam: domain.lastRam,
      lastDisk: domain.lastDisk,
      lastDiskUsed: domain.lastDiskUsed,
      lastDiskTotal: domain.lastDiskTotal,
      lastSeen: domain.lastSeen,
      status: domain.status,
      osDistro: domain.osDistro,
      kernelVersion: domain.kernelVersion,
      uptime: domain.uptime,
      hostnameInfo: domain.hostnameInfo,
      ipAddress: domain.ipAddress,
      serverLocation: domain.serverLocation,
      lastLatency: domain.lastLatency,
      lastRamUsed: domain.lastRamUsed,
      lastRamTotal: domain.lastRamTotal,
      cpuModel: domain.cpuModel,
      cpuCores: domain.cpuCores,
      cpuSpeed: domain.cpuSpeed,
    );
  }
}
