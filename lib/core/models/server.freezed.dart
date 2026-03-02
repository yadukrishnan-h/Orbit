// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Server _$ServerFromJson(Map<String, dynamic> json) {
  return _Server.fromJson(json);
}

/// @nodoc
mixin _$Server {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get hostname => throw _privateConstructorUsedError;
  int get port => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get password =>
      throw _privateConstructorUsedError; // Added password field
  AuthType get authType => throw _privateConstructorUsedError;
  ServerStatus get status =>
      throw _privateConstructorUsedError; // Snapshot Data
  double? get lastCpu => throw _privateConstructorUsedError;
  double? get lastRam => throw _privateConstructorUsedError;
  double? get lastDisk => throw _privateConstructorUsedError;
  DateTime? get lastSeen =>
      throw _privateConstructorUsedError; // Persisted System Info
  String get osDistro => throw _privateConstructorUsedError;
  String get kernelVersion => throw _privateConstructorUsedError;
  String get uptime => throw _privateConstructorUsedError;
  String get hostnameInfo => throw _privateConstructorUsedError;
  String get ipAddress =>
      throw _privateConstructorUsedError; // Added IP Persistence
  String get serverLocation =>
      throw _privateConstructorUsedError; // Geolocation data
  int get lastLatency => throw _privateConstructorUsedError;
  int get lastDiskUsed => throw _privateConstructorUsedError; // Disk Used Bytes
  int get lastDiskTotal => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServerCopyWith<Server> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerCopyWith<$Res> {
  factory $ServerCopyWith(Server value, $Res Function(Server) then) =
      _$ServerCopyWithImpl<$Res, Server>;
  @useResult
  $Res call(
      {String id,
      String name,
      String hostname,
      int port,
      String username,
      String password,
      AuthType authType,
      ServerStatus status,
      double? lastCpu,
      double? lastRam,
      double? lastDisk,
      DateTime? lastSeen,
      String osDistro,
      String kernelVersion,
      String uptime,
      String hostnameInfo,
      String ipAddress,
      String serverLocation,
      int lastLatency,
      int lastDiskUsed,
      int lastDiskTotal});
}

/// @nodoc
class _$ServerCopyWithImpl<$Res, $Val extends Server>
    implements $ServerCopyWith<$Res> {
  _$ServerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? hostname = null,
    Object? port = null,
    Object? username = null,
    Object? password = null,
    Object? authType = null,
    Object? status = null,
    Object? lastCpu = freezed,
    Object? lastRam = freezed,
    Object? lastDisk = freezed,
    Object? lastSeen = freezed,
    Object? osDistro = null,
    Object? kernelVersion = null,
    Object? uptime = null,
    Object? hostnameInfo = null,
    Object? ipAddress = null,
    Object? serverLocation = null,
    Object? lastLatency = null,
    Object? lastDiskUsed = null,
    Object? lastDiskTotal = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hostname: null == hostname
          ? _value.hostname
          : hostname // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      authType: null == authType
          ? _value.authType
          : authType // ignore: cast_nullable_to_non_nullable
              as AuthType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ServerStatus,
      lastCpu: freezed == lastCpu
          ? _value.lastCpu
          : lastCpu // ignore: cast_nullable_to_non_nullable
              as double?,
      lastRam: freezed == lastRam
          ? _value.lastRam
          : lastRam // ignore: cast_nullable_to_non_nullable
              as double?,
      lastDisk: freezed == lastDisk
          ? _value.lastDisk
          : lastDisk // ignore: cast_nullable_to_non_nullable
              as double?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      osDistro: null == osDistro
          ? _value.osDistro
          : osDistro // ignore: cast_nullable_to_non_nullable
              as String,
      kernelVersion: null == kernelVersion
          ? _value.kernelVersion
          : kernelVersion // ignore: cast_nullable_to_non_nullable
              as String,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as String,
      hostnameInfo: null == hostnameInfo
          ? _value.hostnameInfo
          : hostnameInfo // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      serverLocation: null == serverLocation
          ? _value.serverLocation
          : serverLocation // ignore: cast_nullable_to_non_nullable
              as String,
      lastLatency: null == lastLatency
          ? _value.lastLatency
          : lastLatency // ignore: cast_nullable_to_non_nullable
              as int,
      lastDiskUsed: null == lastDiskUsed
          ? _value.lastDiskUsed
          : lastDiskUsed // ignore: cast_nullable_to_non_nullable
              as int,
      lastDiskTotal: null == lastDiskTotal
          ? _value.lastDiskTotal
          : lastDiskTotal // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServerImplCopyWith<$Res> implements $ServerCopyWith<$Res> {
  factory _$$ServerImplCopyWith(
          _$ServerImpl value, $Res Function(_$ServerImpl) then) =
      __$$ServerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String hostname,
      int port,
      String username,
      String password,
      AuthType authType,
      ServerStatus status,
      double? lastCpu,
      double? lastRam,
      double? lastDisk,
      DateTime? lastSeen,
      String osDistro,
      String kernelVersion,
      String uptime,
      String hostnameInfo,
      String ipAddress,
      String serverLocation,
      int lastLatency,
      int lastDiskUsed,
      int lastDiskTotal});
}

/// @nodoc
class __$$ServerImplCopyWithImpl<$Res>
    extends _$ServerCopyWithImpl<$Res, _$ServerImpl>
    implements _$$ServerImplCopyWith<$Res> {
  __$$ServerImplCopyWithImpl(
      _$ServerImpl _value, $Res Function(_$ServerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? hostname = null,
    Object? port = null,
    Object? username = null,
    Object? password = null,
    Object? authType = null,
    Object? status = null,
    Object? lastCpu = freezed,
    Object? lastRam = freezed,
    Object? lastDisk = freezed,
    Object? lastSeen = freezed,
    Object? osDistro = null,
    Object? kernelVersion = null,
    Object? uptime = null,
    Object? hostnameInfo = null,
    Object? ipAddress = null,
    Object? serverLocation = null,
    Object? lastLatency = null,
    Object? lastDiskUsed = null,
    Object? lastDiskTotal = null,
  }) {
    return _then(_$ServerImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      hostname: null == hostname
          ? _value.hostname
          : hostname // ignore: cast_nullable_to_non_nullable
              as String,
      port: null == port
          ? _value.port
          : port // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      authType: null == authType
          ? _value.authType
          : authType // ignore: cast_nullable_to_non_nullable
              as AuthType,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ServerStatus,
      lastCpu: freezed == lastCpu
          ? _value.lastCpu
          : lastCpu // ignore: cast_nullable_to_non_nullable
              as double?,
      lastRam: freezed == lastRam
          ? _value.lastRam
          : lastRam // ignore: cast_nullable_to_non_nullable
              as double?,
      lastDisk: freezed == lastDisk
          ? _value.lastDisk
          : lastDisk // ignore: cast_nullable_to_non_nullable
              as double?,
      lastSeen: freezed == lastSeen
          ? _value.lastSeen
          : lastSeen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      osDistro: null == osDistro
          ? _value.osDistro
          : osDistro // ignore: cast_nullable_to_non_nullable
              as String,
      kernelVersion: null == kernelVersion
          ? _value.kernelVersion
          : kernelVersion // ignore: cast_nullable_to_non_nullable
              as String,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as String,
      hostnameInfo: null == hostnameInfo
          ? _value.hostnameInfo
          : hostnameInfo // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      serverLocation: null == serverLocation
          ? _value.serverLocation
          : serverLocation // ignore: cast_nullable_to_non_nullable
              as String,
      lastLatency: null == lastLatency
          ? _value.lastLatency
          : lastLatency // ignore: cast_nullable_to_non_nullable
              as int,
      lastDiskUsed: null == lastDiskUsed
          ? _value.lastDiskUsed
          : lastDiskUsed // ignore: cast_nullable_to_non_nullable
              as int,
      lastDiskTotal: null == lastDiskTotal
          ? _value.lastDiskTotal
          : lastDiskTotal // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServerImpl implements _Server {
  const _$ServerImpl(
      {required this.id,
      required this.name,
      required this.hostname,
      required this.port,
      required this.username,
      required this.password,
      required this.authType,
      this.status = ServerStatus.unknown,
      this.lastCpu,
      this.lastRam,
      this.lastDisk,
      this.lastSeen,
      this.osDistro = '',
      this.kernelVersion = '',
      this.uptime = '',
      this.hostnameInfo = '',
      this.ipAddress = '',
      this.serverLocation = '',
      this.lastLatency = 0,
      this.lastDiskUsed = 0,
      this.lastDiskTotal = 0});

  factory _$ServerImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServerImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String hostname;
  @override
  final int port;
  @override
  final String username;
  @override
  final String password;
// Added password field
  @override
  final AuthType authType;
  @override
  @JsonKey()
  final ServerStatus status;
// Snapshot Data
  @override
  final double? lastCpu;
  @override
  final double? lastRam;
  @override
  final double? lastDisk;
  @override
  final DateTime? lastSeen;
// Persisted System Info
  @override
  @JsonKey()
  final String osDistro;
  @override
  @JsonKey()
  final String kernelVersion;
  @override
  @JsonKey()
  final String uptime;
  @override
  @JsonKey()
  final String hostnameInfo;
  @override
  @JsonKey()
  final String ipAddress;
// Added IP Persistence
  @override
  @JsonKey()
  final String serverLocation;
// Geolocation data
  @override
  @JsonKey()
  final int lastLatency;
  @override
  @JsonKey()
  final int lastDiskUsed;
// Disk Used Bytes
  @override
  @JsonKey()
  final int lastDiskTotal;

  @override
  String toString() {
    return 'Server(id: $id, name: $name, hostname: $hostname, port: $port, username: $username, password: $password, authType: $authType, status: $status, lastCpu: $lastCpu, lastRam: $lastRam, lastDisk: $lastDisk, lastSeen: $lastSeen, osDistro: $osDistro, kernelVersion: $kernelVersion, uptime: $uptime, hostnameInfo: $hostnameInfo, ipAddress: $ipAddress, serverLocation: $serverLocation, lastLatency: $lastLatency, lastDiskUsed: $lastDiskUsed, lastDiskTotal: $lastDiskTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.hostname, hostname) ||
                other.hostname == hostname) &&
            (identical(other.port, port) || other.port == port) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.authType, authType) ||
                other.authType == authType) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastCpu, lastCpu) || other.lastCpu == lastCpu) &&
            (identical(other.lastRam, lastRam) || other.lastRam == lastRam) &&
            (identical(other.lastDisk, lastDisk) ||
                other.lastDisk == lastDisk) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.osDistro, osDistro) ||
                other.osDistro == osDistro) &&
            (identical(other.kernelVersion, kernelVersion) ||
                other.kernelVersion == kernelVersion) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.hostnameInfo, hostnameInfo) ||
                other.hostnameInfo == hostnameInfo) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.serverLocation, serverLocation) ||
                other.serverLocation == serverLocation) &&
            (identical(other.lastLatency, lastLatency) ||
                other.lastLatency == lastLatency) &&
            (identical(other.lastDiskUsed, lastDiskUsed) ||
                other.lastDiskUsed == lastDiskUsed) &&
            (identical(other.lastDiskTotal, lastDiskTotal) ||
                other.lastDiskTotal == lastDiskTotal));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        hostname,
        port,
        username,
        password,
        authType,
        status,
        lastCpu,
        lastRam,
        lastDisk,
        lastSeen,
        osDistro,
        kernelVersion,
        uptime,
        hostnameInfo,
        ipAddress,
        serverLocation,
        lastLatency,
        lastDiskUsed,
        lastDiskTotal
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerImplCopyWith<_$ServerImpl> get copyWith =>
      __$$ServerImplCopyWithImpl<_$ServerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServerImplToJson(
      this,
    );
  }
}

abstract class _Server implements Server {
  const factory _Server(
      {required final String id,
      required final String name,
      required final String hostname,
      required final int port,
      required final String username,
      required final String password,
      required final AuthType authType,
      final ServerStatus status,
      final double? lastCpu,
      final double? lastRam,
      final double? lastDisk,
      final DateTime? lastSeen,
      final String osDistro,
      final String kernelVersion,
      final String uptime,
      final String hostnameInfo,
      final String ipAddress,
      final String serverLocation,
      final int lastLatency,
      final int lastDiskUsed,
      final int lastDiskTotal}) = _$ServerImpl;

  factory _Server.fromJson(Map<String, dynamic> json) = _$ServerImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get hostname;
  @override
  int get port;
  @override
  String get username;
  @override
  String get password;
  @override // Added password field
  AuthType get authType;
  @override
  ServerStatus get status;
  @override // Snapshot Data
  double? get lastCpu;
  @override
  double? get lastRam;
  @override
  double? get lastDisk;
  @override
  DateTime? get lastSeen;
  @override // Persisted System Info
  String get osDistro;
  @override
  String get kernelVersion;
  @override
  String get uptime;
  @override
  String get hostnameInfo;
  @override
  String get ipAddress;
  @override // Added IP Persistence
  String get serverLocation;
  @override // Geolocation data
  int get lastLatency;
  @override
  int get lastDiskUsed;
  @override // Disk Used Bytes
  int get lastDiskTotal;
  @override
  @JsonKey(ignore: true)
  _$$ServerImplCopyWith<_$ServerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
