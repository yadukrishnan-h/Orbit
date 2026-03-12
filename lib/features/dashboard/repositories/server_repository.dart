import 'dart:async';
import 'package:flutter/foundation.dart';
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
  /// UI should watch this stream for instant updates
  Stream<List<Server>> watchAllServers() async* {
    yield await getAllServers();
    yield* _box.watch().asyncMap((_) async => await getAllServers());
  }

  /// Watch a single server by ID as a reactive stream
  /// Returns null if server doesn't exist
  Stream<Server?> watchServer(String id) async* {
    yield await getServerById(id);
    yield* _box.watch(key: id).asyncMap((event) async {
      return await getServerById(id);
    });
  }

  /// Get a single server by ID
  Future<Server?> getServerById(String id) async {
    final entity = _box.get(id);
    return entity != null ? await _mapToDomainAsync(entity) : null;
  }

  /// Get all servers
  Future<List<Server>> getAllServers() async {
    final entities = _box.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return Future.wait(entities.map(_mapToDomainAsync));
  }

  /// Add a new server
  Future<void> addServer(Server server) async {
    final entity = _mapToEntity(server);
    await _box.put(server.id, entity);

    await _secureStorage.saveCredential(server.id, 'password', server.password);
    if (server.privateKey != null) {
      debugPrint("Saving private key of length: ${server.privateKey?.length}");
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
      debugPrint("Saving private key of length: ${server.privateKey?.length}");
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

  Future<Server> _mapToDomainAsync(HiveServer entity) async {
    final password =
        await _secureStorage.readCredential(entity.uuid, 'password') ?? '';
    final privateKey = await _secureStorage.readCredential(
      entity.uuid,
      'privateKey',
    );

    debugPrint("Loaded private key of length: ${privateKey?.length}");

    return Server(
      id: entity.uuid,
      name: entity.name,
      hostname: entity.hostname,
      port: entity.port,
      username: entity.username,
      password: password,
      privateKey: privateKey,
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
    );
  }
}
