import 'package:isar/isar.dart';
import 'package:orbit/core/models/server.dart';

part 'isar_server.g.dart';

@collection
class IsarServer {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  late String hostname;
  late int port;
  late String username;

  // Storing password/key temporarily here for MVP simplicity,
  // though FlutterSecureStorage is preferred for production.
  // The plan allows this for now as per "Phase 3" details.
  late String password;

  @Enumerated(EnumType.name)
  late AuthType authType;

  // Snapshot data (cached metrics)
  double? lastCpu;
  double? lastRam;
  double? lastDisk;
  int? lastDiskUsed;
  int? lastDiskTotal;
  DateTime? lastSeen;

  // Metadata
  String? osDistro;
  String? kernelVersion;
  String? uptime;
  String? hostnameInfo;
  String? ipAddress; // Added IP Persistence
  String? serverLocation; // Geolocation data
  int? lastLatency;

  // Connection status
  @Enumerated(EnumType.name)
  ServerStatus status = ServerStatus.unknown;

  // Display ordering (for drag-to-reorder in ManageServersScreen)
  int sortOrder = 0;
}
