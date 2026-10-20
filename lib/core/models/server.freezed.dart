// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Server {

 String get id; String get name; String get hostname; int get port; String get username; String get password; String? get privateKey; AuthType get authType; ServerStatus get status; double? get lastCpu; double? get lastRam; double? get lastDisk; DateTime? get lastSeen; String get osDistro; String get kernelVersion; String get uptime; String get hostnameInfo; String get ipAddress; String get serverLocation; int get lastLatency; int get lastDiskUsed; int get lastDiskTotal; int get lastRamUsed; int get lastRamTotal; String get cpuModel; int get cpuCores; String get cpuSpeed; double get lastLoad1; double get lastLoad5; double get lastLoad15;
/// Create a copy of Server
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerCopyWith<Server> get copyWith => _$ServerCopyWithImpl<Server>(this as Server, _$identity);

  /// Serializes this Server to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Server;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Server&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.hostname, _this.hostname) || other.hostname == _this.hostname)&&(identical(other.port, _this.port) || other.port == _this.port)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.password, _this.password) || other.password == _this.password)&&(identical(other.privateKey, _this.privateKey) || other.privateKey == _this.privateKey)&&(identical(other.authType, _this.authType) || other.authType == _this.authType)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.lastCpu, _this.lastCpu) || other.lastCpu == _this.lastCpu)&&(identical(other.lastRam, _this.lastRam) || other.lastRam == _this.lastRam)&&(identical(other.lastDisk, _this.lastDisk) || other.lastDisk == _this.lastDisk)&&(identical(other.lastSeen, _this.lastSeen) || other.lastSeen == _this.lastSeen)&&(identical(other.osDistro, _this.osDistro) || other.osDistro == _this.osDistro)&&(identical(other.kernelVersion, _this.kernelVersion) || other.kernelVersion == _this.kernelVersion)&&(identical(other.uptime, _this.uptime) || other.uptime == _this.uptime)&&(identical(other.hostnameInfo, _this.hostnameInfo) || other.hostnameInfo == _this.hostnameInfo)&&(identical(other.ipAddress, _this.ipAddress) || other.ipAddress == _this.ipAddress)&&(identical(other.serverLocation, _this.serverLocation) || other.serverLocation == _this.serverLocation)&&(identical(other.lastLatency, _this.lastLatency) || other.lastLatency == _this.lastLatency)&&(identical(other.lastDiskUsed, _this.lastDiskUsed) || other.lastDiskUsed == _this.lastDiskUsed)&&(identical(other.lastDiskTotal, _this.lastDiskTotal) || other.lastDiskTotal == _this.lastDiskTotal)&&(identical(other.lastRamUsed, _this.lastRamUsed) || other.lastRamUsed == _this.lastRamUsed)&&(identical(other.lastRamTotal, _this.lastRamTotal) || other.lastRamTotal == _this.lastRamTotal)&&(identical(other.cpuModel, _this.cpuModel) || other.cpuModel == _this.cpuModel)&&(identical(other.cpuCores, _this.cpuCores) || other.cpuCores == _this.cpuCores)&&(identical(other.cpuSpeed, _this.cpuSpeed) || other.cpuSpeed == _this.cpuSpeed)&&(identical(other.lastLoad1, _this.lastLoad1) || other.lastLoad1 == _this.lastLoad1)&&(identical(other.lastLoad5, _this.lastLoad5) || other.lastLoad5 == _this.lastLoad5)&&(identical(other.lastLoad15, _this.lastLoad15) || other.lastLoad15 == _this.lastLoad15));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Server;
  return Object.hashAll([runtimeType,_this.id,_this.name,_this.hostname,_this.port,_this.username,_this.password,_this.privateKey,_this.authType,_this.status,_this.lastCpu,_this.lastRam,_this.lastDisk,_this.lastSeen,_this.osDistro,_this.kernelVersion,_this.uptime,_this.hostnameInfo,_this.ipAddress,_this.serverLocation,_this.lastLatency,_this.lastDiskUsed,_this.lastDiskTotal,_this.lastRamUsed,_this.lastRamTotal,_this.cpuModel,_this.cpuCores,_this.cpuSpeed,_this.lastLoad1,_this.lastLoad5,_this.lastLoad15]);
}

@override
String toString() {
  final _this = this as Server;
  return 'Server(id: ${_this.id}, name: ${_this.name}, hostname: ${_this.hostname}, port: ${_this.port}, username: ${_this.username}, password: ${_this.password}, privateKey: ${_this.privateKey}, authType: ${_this.authType}, status: ${_this.status}, lastCpu: ${_this.lastCpu}, lastRam: ${_this.lastRam}, lastDisk: ${_this.lastDisk}, lastSeen: ${_this.lastSeen}, osDistro: ${_this.osDistro}, kernelVersion: ${_this.kernelVersion}, uptime: ${_this.uptime}, hostnameInfo: ${_this.hostnameInfo}, ipAddress: ${_this.ipAddress}, serverLocation: ${_this.serverLocation}, lastLatency: ${_this.lastLatency}, lastDiskUsed: ${_this.lastDiskUsed}, lastDiskTotal: ${_this.lastDiskTotal}, lastRamUsed: ${_this.lastRamUsed}, lastRamTotal: ${_this.lastRamTotal}, cpuModel: ${_this.cpuModel}, cpuCores: ${_this.cpuCores}, cpuSpeed: ${_this.cpuSpeed}, lastLoad1: ${_this.lastLoad1}, lastLoad5: ${_this.lastLoad5}, lastLoad15: ${_this.lastLoad15})';
}


}

/// @nodoc
abstract mixin class $ServerCopyWith<$Res>  {
  factory $ServerCopyWith(Server value, $Res Function(Server) _then) = _$ServerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String hostname, int port, String username, String password, String? privateKey, AuthType authType, ServerStatus status, double? lastCpu, double? lastRam, double? lastDisk, DateTime? lastSeen, String osDistro, String kernelVersion, String uptime, String hostnameInfo, String ipAddress, String serverLocation, int lastLatency, int lastDiskUsed, int lastDiskTotal, int lastRamUsed, int lastRamTotal, String cpuModel, int cpuCores, String cpuSpeed, double lastLoad1, double lastLoad5, double lastLoad15
});




}
/// @nodoc
class _$ServerCopyWithImpl<$Res>
    implements $ServerCopyWith<$Res> {
  _$ServerCopyWithImpl(this._self, this._then);

  final Server _self;
  final $Res Function(Server) _then;

/// Create a copy of Server
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? hostname = null,Object? port = null,Object? username = null,Object? password = null,Object? privateKey = freezed,Object? authType = null,Object? status = null,Object? lastCpu = freezed,Object? lastRam = freezed,Object? lastDisk = freezed,Object? lastSeen = freezed,Object? osDistro = null,Object? kernelVersion = null,Object? uptime = null,Object? hostnameInfo = null,Object? ipAddress = null,Object? serverLocation = null,Object? lastLatency = null,Object? lastDiskUsed = null,Object? lastDiskTotal = null,Object? lastRamUsed = null,Object? lastRamTotal = null,Object? cpuModel = null,Object? cpuCores = null,Object? cpuSpeed = null,Object? lastLoad1 = null,Object? lastLoad5 = null,Object? lastLoad15 = null,}) {
  return _then(Server(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,privateKey: freezed == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as String?,authType: null == authType ? _self.authType : authType // ignore: cast_nullable_to_non_nullable
as AuthType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ServerStatus,lastCpu: freezed == lastCpu ? _self.lastCpu : lastCpu // ignore: cast_nullable_to_non_nullable
as double?,lastRam: freezed == lastRam ? _self.lastRam : lastRam // ignore: cast_nullable_to_non_nullable
as double?,lastDisk: freezed == lastDisk ? _self.lastDisk : lastDisk // ignore: cast_nullable_to_non_nullable
as double?,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,osDistro: null == osDistro ? _self.osDistro : osDistro // ignore: cast_nullable_to_non_nullable
as String,kernelVersion: null == kernelVersion ? _self.kernelVersion : kernelVersion // ignore: cast_nullable_to_non_nullable
as String,uptime: null == uptime ? _self.uptime : uptime // ignore: cast_nullable_to_non_nullable
as String,hostnameInfo: null == hostnameInfo ? _self.hostnameInfo : hostnameInfo // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,serverLocation: null == serverLocation ? _self.serverLocation : serverLocation // ignore: cast_nullable_to_non_nullable
as String,lastLatency: null == lastLatency ? _self.lastLatency : lastLatency // ignore: cast_nullable_to_non_nullable
as int,lastDiskUsed: null == lastDiskUsed ? _self.lastDiskUsed : lastDiskUsed // ignore: cast_nullable_to_non_nullable
as int,lastDiskTotal: null == lastDiskTotal ? _self.lastDiskTotal : lastDiskTotal // ignore: cast_nullable_to_non_nullable
as int,lastRamUsed: null == lastRamUsed ? _self.lastRamUsed : lastRamUsed // ignore: cast_nullable_to_non_nullable
as int,lastRamTotal: null == lastRamTotal ? _self.lastRamTotal : lastRamTotal // ignore: cast_nullable_to_non_nullable
as int,cpuModel: null == cpuModel ? _self.cpuModel : cpuModel // ignore: cast_nullable_to_non_nullable
as String,cpuCores: null == cpuCores ? _self.cpuCores : cpuCores // ignore: cast_nullable_to_non_nullable
as int,cpuSpeed: null == cpuSpeed ? _self.cpuSpeed : cpuSpeed // ignore: cast_nullable_to_non_nullable
as String,lastLoad1: null == lastLoad1 ? _self.lastLoad1 : lastLoad1 // ignore: cast_nullable_to_non_nullable
as double,lastLoad5: null == lastLoad5 ? _self.lastLoad5 : lastLoad5 // ignore: cast_nullable_to_non_nullable
as double,lastLoad15: null == lastLoad15 ? _self.lastLoad15 : lastLoad15 // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Server].
extension ServerPatterns on Server {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Server value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Server() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Server value)  $default,){
final _that = this;
switch (_that) {
case _Server():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Server value)?  $default,){
final _that = this;
switch (_that) {
case _Server() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String hostname,  int port,  String username,  String password,  String? privateKey,  AuthType authType,  ServerStatus status,  double? lastCpu,  double? lastRam,  double? lastDisk,  DateTime? lastSeen,  String osDistro,  String kernelVersion,  String uptime,  String hostnameInfo,  String ipAddress,  String serverLocation,  int lastLatency,  int lastDiskUsed,  int lastDiskTotal,  int lastRamUsed,  int lastRamTotal,  String cpuModel,  int cpuCores,  String cpuSpeed,  double lastLoad1,  double lastLoad5,  double lastLoad15)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Server() when $default != null:
return $default(_that.id,_that.name,_that.hostname,_that.port,_that.username,_that.password,_that.privateKey,_that.authType,_that.status,_that.lastCpu,_that.lastRam,_that.lastDisk,_that.lastSeen,_that.osDistro,_that.kernelVersion,_that.uptime,_that.hostnameInfo,_that.ipAddress,_that.serverLocation,_that.lastLatency,_that.lastDiskUsed,_that.lastDiskTotal,_that.lastRamUsed,_that.lastRamTotal,_that.cpuModel,_that.cpuCores,_that.cpuSpeed,_that.lastLoad1,_that.lastLoad5,_that.lastLoad15);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String hostname,  int port,  String username,  String password,  String? privateKey,  AuthType authType,  ServerStatus status,  double? lastCpu,  double? lastRam,  double? lastDisk,  DateTime? lastSeen,  String osDistro,  String kernelVersion,  String uptime,  String hostnameInfo,  String ipAddress,  String serverLocation,  int lastLatency,  int lastDiskUsed,  int lastDiskTotal,  int lastRamUsed,  int lastRamTotal,  String cpuModel,  int cpuCores,  String cpuSpeed,  double lastLoad1,  double lastLoad5,  double lastLoad15)  $default,) {final _that = this;
switch (_that) {
case _Server():
return $default(_that.id,_that.name,_that.hostname,_that.port,_that.username,_that.password,_that.privateKey,_that.authType,_that.status,_that.lastCpu,_that.lastRam,_that.lastDisk,_that.lastSeen,_that.osDistro,_that.kernelVersion,_that.uptime,_that.hostnameInfo,_that.ipAddress,_that.serverLocation,_that.lastLatency,_that.lastDiskUsed,_that.lastDiskTotal,_that.lastRamUsed,_that.lastRamTotal,_that.cpuModel,_that.cpuCores,_that.cpuSpeed,_that.lastLoad1,_that.lastLoad5,_that.lastLoad15);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String hostname,  int port,  String username,  String password,  String? privateKey,  AuthType authType,  ServerStatus status,  double? lastCpu,  double? lastRam,  double? lastDisk,  DateTime? lastSeen,  String osDistro,  String kernelVersion,  String uptime,  String hostnameInfo,  String ipAddress,  String serverLocation,  int lastLatency,  int lastDiskUsed,  int lastDiskTotal,  int lastRamUsed,  int lastRamTotal,  String cpuModel,  int cpuCores,  String cpuSpeed,  double lastLoad1,  double lastLoad5,  double lastLoad15)?  $default,) {final _that = this;
switch (_that) {
case _Server() when $default != null:
return $default(_that.id,_that.name,_that.hostname,_that.port,_that.username,_that.password,_that.privateKey,_that.authType,_that.status,_that.lastCpu,_that.lastRam,_that.lastDisk,_that.lastSeen,_that.osDistro,_that.kernelVersion,_that.uptime,_that.hostnameInfo,_that.ipAddress,_that.serverLocation,_that.lastLatency,_that.lastDiskUsed,_that.lastDiskTotal,_that.lastRamUsed,_that.lastRamTotal,_that.cpuModel,_that.cpuCores,_that.cpuSpeed,_that.lastLoad1,_that.lastLoad5,_that.lastLoad15);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Server implements Server {
  const _Server({required this.id, required this.name, required this.hostname, required this.port, required this.username, required this.password, this.privateKey, required this.authType, this.status = ServerStatus.unknown, this.lastCpu, this.lastRam, this.lastDisk, this.lastSeen, this.osDistro = '', this.kernelVersion = '', this.uptime = '', this.hostnameInfo = '', this.ipAddress = '', this.serverLocation = '', this.lastLatency = 0, this.lastDiskUsed = 0, this.lastDiskTotal = 0, this.lastRamUsed = 0, this.lastRamTotal = 0, this.cpuModel = '', this.cpuCores = 0, this.cpuSpeed = '', this.lastLoad1 = 0.0, this.lastLoad5 = 0.0, this.lastLoad15 = 0.0});
  factory _Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String hostname;
@override final  int port;
@override final  String username;
@override final  String password;
@override final  String? privateKey;
@override final  AuthType authType;
@override@JsonKey() final  ServerStatus status;
@override final  double? lastCpu;
@override final  double? lastRam;
@override final  double? lastDisk;
@override final  DateTime? lastSeen;
@override@JsonKey() final  String osDistro;
@override@JsonKey() final  String kernelVersion;
@override@JsonKey() final  String uptime;
@override@JsonKey() final  String hostnameInfo;
@override@JsonKey() final  String ipAddress;
@override@JsonKey() final  String serverLocation;
@override@JsonKey() final  int lastLatency;
@override@JsonKey() final  int lastDiskUsed;
@override@JsonKey() final  int lastDiskTotal;
@override@JsonKey() final  int lastRamUsed;
@override@JsonKey() final  int lastRamTotal;
@override@JsonKey() final  String cpuModel;
@override@JsonKey() final  int cpuCores;
@override@JsonKey() final  String cpuSpeed;
@override@JsonKey() final  double lastLoad1;
@override@JsonKey() final  double lastLoad5;
@override@JsonKey() final  double lastLoad15;

/// Create a copy of Server
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerCopyWith<_Server> get copyWith => __$ServerCopyWithImpl<_Server>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Server&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.port, port) || other.port == port)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.privateKey, privateKey) || other.privateKey == privateKey)&&(identical(other.authType, authType) || other.authType == authType)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastCpu, lastCpu) || other.lastCpu == lastCpu)&&(identical(other.lastRam, lastRam) || other.lastRam == lastRam)&&(identical(other.lastDisk, lastDisk) || other.lastDisk == lastDisk)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.osDistro, osDistro) || other.osDistro == osDistro)&&(identical(other.kernelVersion, kernelVersion) || other.kernelVersion == kernelVersion)&&(identical(other.uptime, uptime) || other.uptime == uptime)&&(identical(other.hostnameInfo, hostnameInfo) || other.hostnameInfo == hostnameInfo)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.serverLocation, serverLocation) || other.serverLocation == serverLocation)&&(identical(other.lastLatency, lastLatency) || other.lastLatency == lastLatency)&&(identical(other.lastDiskUsed, lastDiskUsed) || other.lastDiskUsed == lastDiskUsed)&&(identical(other.lastDiskTotal, lastDiskTotal) || other.lastDiskTotal == lastDiskTotal)&&(identical(other.lastRamUsed, lastRamUsed) || other.lastRamUsed == lastRamUsed)&&(identical(other.lastRamTotal, lastRamTotal) || other.lastRamTotal == lastRamTotal)&&(identical(other.cpuModel, cpuModel) || other.cpuModel == cpuModel)&&(identical(other.cpuCores, cpuCores) || other.cpuCores == cpuCores)&&(identical(other.cpuSpeed, cpuSpeed) || other.cpuSpeed == cpuSpeed)&&(identical(other.lastLoad1, lastLoad1) || other.lastLoad1 == lastLoad1)&&(identical(other.lastLoad5, lastLoad5) || other.lastLoad5 == lastLoad5)&&(identical(other.lastLoad15, lastLoad15) || other.lastLoad15 == lastLoad15));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,name,hostname,port,username,password,privateKey,authType,status,lastCpu,lastRam,lastDisk,lastSeen,osDistro,kernelVersion,uptime,hostnameInfo,ipAddress,serverLocation,lastLatency,lastDiskUsed,lastDiskTotal,lastRamUsed,lastRamTotal,cpuModel,cpuCores,cpuSpeed,lastLoad1,lastLoad5,lastLoad15]);
}

@override
String toString() {
    return 'Server(id: $id, name: $name, hostname: $hostname, port: $port, username: $username, password: $password, privateKey: $privateKey, authType: $authType, status: $status, lastCpu: $lastCpu, lastRam: $lastRam, lastDisk: $lastDisk, lastSeen: $lastSeen, osDistro: $osDistro, kernelVersion: $kernelVersion, uptime: $uptime, hostnameInfo: $hostnameInfo, ipAddress: $ipAddress, serverLocation: $serverLocation, lastLatency: $lastLatency, lastDiskUsed: $lastDiskUsed, lastDiskTotal: $lastDiskTotal, lastRamUsed: $lastRamUsed, lastRamTotal: $lastRamTotal, cpuModel: $cpuModel, cpuCores: $cpuCores, cpuSpeed: $cpuSpeed, lastLoad1: $lastLoad1, lastLoad5: $lastLoad5, lastLoad15: $lastLoad15)';
}


}

/// @nodoc
abstract mixin class _$ServerCopyWith<$Res> implements $ServerCopyWith<$Res> {
  factory _$ServerCopyWith(_Server value, $Res Function(_Server) _then) = __$ServerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String hostname, int port, String username, String password, String? privateKey, AuthType authType, ServerStatus status, double? lastCpu, double? lastRam, double? lastDisk, DateTime? lastSeen, String osDistro, String kernelVersion, String uptime, String hostnameInfo, String ipAddress, String serverLocation, int lastLatency, int lastDiskUsed, int lastDiskTotal, int lastRamUsed, int lastRamTotal, String cpuModel, int cpuCores, String cpuSpeed, double lastLoad1, double lastLoad5, double lastLoad15
});




}
/// @nodoc
class __$ServerCopyWithImpl<$Res>
    implements _$ServerCopyWith<$Res> {
  __$ServerCopyWithImpl(this._self, this._then);

  final _Server _self;
  final $Res Function(_Server) _then;

/// Create a copy of Server
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? hostname = null,Object? port = null,Object? username = null,Object? password = null,Object? privateKey = freezed,Object? authType = null,Object? status = null,Object? lastCpu = freezed,Object? lastRam = freezed,Object? lastDisk = freezed,Object? lastSeen = freezed,Object? osDistro = null,Object? kernelVersion = null,Object? uptime = null,Object? hostnameInfo = null,Object? ipAddress = null,Object? serverLocation = null,Object? lastLatency = null,Object? lastDiskUsed = null,Object? lastDiskTotal = null,Object? lastRamUsed = null,Object? lastRamTotal = null,Object? cpuModel = null,Object? cpuCores = null,Object? cpuSpeed = null,Object? lastLoad1 = null,Object? lastLoad5 = null,Object? lastLoad15 = null,}) {
  return _then(_Server(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,port: null == port ? _self.port : port // ignore: cast_nullable_to_non_nullable
as int,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,privateKey: freezed == privateKey ? _self.privateKey : privateKey // ignore: cast_nullable_to_non_nullable
as String?,authType: null == authType ? _self.authType : authType // ignore: cast_nullable_to_non_nullable
as AuthType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ServerStatus,lastCpu: freezed == lastCpu ? _self.lastCpu : lastCpu // ignore: cast_nullable_to_non_nullable
as double?,lastRam: freezed == lastRam ? _self.lastRam : lastRam // ignore: cast_nullable_to_non_nullable
as double?,lastDisk: freezed == lastDisk ? _self.lastDisk : lastDisk // ignore: cast_nullable_to_non_nullable
as double?,lastSeen: freezed == lastSeen ? _self.lastSeen : lastSeen // ignore: cast_nullable_to_non_nullable
as DateTime?,osDistro: null == osDistro ? _self.osDistro : osDistro // ignore: cast_nullable_to_non_nullable
as String,kernelVersion: null == kernelVersion ? _self.kernelVersion : kernelVersion // ignore: cast_nullable_to_non_nullable
as String,uptime: null == uptime ? _self.uptime : uptime // ignore: cast_nullable_to_non_nullable
as String,hostnameInfo: null == hostnameInfo ? _self.hostnameInfo : hostnameInfo // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,serverLocation: null == serverLocation ? _self.serverLocation : serverLocation // ignore: cast_nullable_to_non_nullable
as String,lastLatency: null == lastLatency ? _self.lastLatency : lastLatency // ignore: cast_nullable_to_non_nullable
as int,lastDiskUsed: null == lastDiskUsed ? _self.lastDiskUsed : lastDiskUsed // ignore: cast_nullable_to_non_nullable
as int,lastDiskTotal: null == lastDiskTotal ? _self.lastDiskTotal : lastDiskTotal // ignore: cast_nullable_to_non_nullable
as int,lastRamUsed: null == lastRamUsed ? _self.lastRamUsed : lastRamUsed // ignore: cast_nullable_to_non_nullable
as int,lastRamTotal: null == lastRamTotal ? _self.lastRamTotal : lastRamTotal // ignore: cast_nullable_to_non_nullable
as int,cpuModel: null == cpuModel ? _self.cpuModel : cpuModel // ignore: cast_nullable_to_non_nullable
as String,cpuCores: null == cpuCores ? _self.cpuCores : cpuCores // ignore: cast_nullable_to_non_nullable
as int,cpuSpeed: null == cpuSpeed ? _self.cpuSpeed : cpuSpeed // ignore: cast_nullable_to_non_nullable
as String,lastLoad1: null == lastLoad1 ? _self.lastLoad1 : lastLoad1 // ignore: cast_nullable_to_non_nullable
as double,lastLoad5: null == lastLoad5 ? _self.lastLoad5 : lastLoad5 // ignore: cast_nullable_to_non_nullable
as double,lastLoad15: null == lastLoad15 ? _self.lastLoad15 : lastLoad15 // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
