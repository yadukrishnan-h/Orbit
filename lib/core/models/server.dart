import 'package:freezed_annotation/freezed_annotation.dart';

part 'server.freezed.dart';
part 'server.g.dart';

enum AuthType {
  password,
  key,
}

enum ServerStatus {
  unknown,
  online,
  offline,
  error,
}

@freezed
class Server with _$Server {
  const factory Server({
    required String id,
    required String name,
    required String hostname,
    required int port,
    required String username,
    required String password, // Added password field
    required AuthType authType,
    @Default(ServerStatus.unknown) ServerStatus status,

    // Snapshot Data
    double? lastCpu,
    double? lastRam,
    double? lastDisk,
    DateTime? lastSeen,

    // Persisted System Info
    @Default('') String osDistro,
    @Default('') String kernelVersion,
    @Default('') String uptime,
    @Default('') String hostnameInfo,
    @Default('') String ipAddress, // Added IP Persistence
    @Default('') String serverLocation, // Geolocation data
    @Default(0) int lastLatency,
    @Default(0) int lastDiskUsed, // Disk Used Bytes
    @Default(0) int lastDiskTotal, // Disk Total Bytes
  }) = _Server;

  factory Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);
}
