// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServerImpl _$$ServerImplFromJson(Map<String, dynamic> json) => _$ServerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      hostname: json['hostname'] as String,
      port: (json['port'] as num).toInt(),
      username: json['username'] as String,
      password: json['password'] as String,
      authType: $enumDecode(_$AuthTypeEnumMap, json['authType']),
      status: $enumDecodeNullable(_$ServerStatusEnumMap, json['status']) ??
          ServerStatus.unknown,
      lastCpu: (json['lastCpu'] as num?)?.toDouble(),
      lastRam: (json['lastRam'] as num?)?.toDouble(),
      lastDisk: (json['lastDisk'] as num?)?.toDouble(),
      lastSeen: json['lastSeen'] == null
          ? null
          : DateTime.parse(json['lastSeen'] as String),
      osDistro: json['osDistro'] as String? ?? '',
      kernelVersion: json['kernelVersion'] as String? ?? '',
      uptime: json['uptime'] as String? ?? '',
      hostnameInfo: json['hostnameInfo'] as String? ?? '',
      ipAddress: json['ipAddress'] as String? ?? '',
      serverLocation: json['serverLocation'] as String? ?? '',
      lastLatency: (json['lastLatency'] as num?)?.toInt() ?? 0,
      lastDiskUsed: (json['lastDiskUsed'] as num?)?.toInt() ?? 0,
      lastDiskTotal: (json['lastDiskTotal'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ServerImplToJson(_$ServerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'hostname': instance.hostname,
      'port': instance.port,
      'username': instance.username,
      'password': instance.password,
      'authType': _$AuthTypeEnumMap[instance.authType]!,
      'status': _$ServerStatusEnumMap[instance.status]!,
      'lastCpu': instance.lastCpu,
      'lastRam': instance.lastRam,
      'lastDisk': instance.lastDisk,
      'lastSeen': instance.lastSeen?.toIso8601String(),
      'osDistro': instance.osDistro,
      'kernelVersion': instance.kernelVersion,
      'uptime': instance.uptime,
      'hostnameInfo': instance.hostnameInfo,
      'ipAddress': instance.ipAddress,
      'serverLocation': instance.serverLocation,
      'lastLatency': instance.lastLatency,
      'lastDiskUsed': instance.lastDiskUsed,
      'lastDiskTotal': instance.lastDiskTotal,
    };

const _$AuthTypeEnumMap = {
  AuthType.password: 'password',
  AuthType.key: 'key',
};

const _$ServerStatusEnumMap = {
  ServerStatus.unknown: 'unknown',
  ServerStatus.online: 'online',
  ServerStatus.offline: 'offline',
  ServerStatus.error: 'error',
};
