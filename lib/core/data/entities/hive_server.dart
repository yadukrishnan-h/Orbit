import 'package:hive/hive.dart';
import 'package:orbit/core/models/server.dart';

// Since we removed hive_generator due to dependency issues, we write the TypeAdapter manually.

class HiveServer {
  String uuid;
  String name;
  String hostname;
  int port;
  String username;
  AuthType authType;
  double? lastCpu;
  double? lastRam;
  double? lastDisk;
  int? lastDiskUsed;
  int? lastDiskTotal;
  DateTime? lastSeen;
  String? osDistro;
  String? kernelVersion;
  String? uptime;
  String? hostnameInfo;
  String? ipAddress;
  String? serverLocation;
  int? lastLatency;
  ServerStatus status;
  int sortOrder;

  HiveServer({
    required this.uuid,
    required this.name,
    required this.hostname,
    required this.port,
    required this.username,
    required this.authType,
    this.lastCpu,
    this.lastRam,
    this.lastDisk,
    this.lastDiskUsed,
    this.lastDiskTotal,
    this.lastSeen,
    this.osDistro,
    this.kernelVersion,
    this.uptime,
    this.hostnameInfo,
    this.ipAddress,
    this.serverLocation,
    this.lastLatency,
    this.status = ServerStatus.unknown,
    this.sortOrder = 0,
  });
}

class HiveServerAdapter extends TypeAdapter<HiveServer> {
  @override
  final int typeId = 0;

  @override
  HiveServer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveServer(
      uuid: fields[0] as String,
      name: fields[1] as String,
      hostname: fields[2] as String,
      port: fields[3] as int,
      username: fields[4] as String,
      authType: AuthType.values.firstWhere((e) => e.name == fields[5] as String, orElse: () => AuthType.password),
      lastCpu: fields[6] as double?,
      lastRam: fields[7] as double?,
      lastDisk: fields[8] as double?,
      lastDiskUsed: fields[9] as int?,
      lastDiskTotal: fields[10] as int?,
      lastSeen: fields[11] as DateTime?,
      osDistro: fields[12] as String?,
      kernelVersion: fields[13] as String?,
      uptime: fields[14] as String?,
      hostnameInfo: fields[15] as String?,
      ipAddress: fields[16] as String?,
      serverLocation: fields[17] as String?,
      lastLatency: fields[18] as int?,
      status: ServerStatus.values.firstWhere((e) => e.name == fields[19] as String, orElse: () => ServerStatus.unknown),
      sortOrder: fields[20] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, HiveServer obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.hostname)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.authType.name)
      ..writeByte(6)
      ..write(obj.lastCpu)
      ..writeByte(7)
      ..write(obj.lastRam)
      ..writeByte(8)
      ..write(obj.lastDisk)
      ..writeByte(9)
      ..write(obj.lastDiskUsed)
      ..writeByte(10)
      ..write(obj.lastDiskTotal)
      ..writeByte(11)
      ..write(obj.lastSeen)
      ..writeByte(12)
      ..write(obj.osDistro)
      ..writeByte(13)
      ..write(obj.kernelVersion)
      ..writeByte(14)
      ..write(obj.uptime)
      ..writeByte(15)
      ..write(obj.hostnameInfo)
      ..writeByte(16)
      ..write(obj.ipAddress)
      ..writeByte(17)
      ..write(obj.serverLocation)
      ..writeByte(18)
      ..write(obj.lastLatency)
      ..writeByte(19)
      ..write(obj.status.name)
      ..writeByte(20)
      ..write(obj.sortOrder);
  }
}
