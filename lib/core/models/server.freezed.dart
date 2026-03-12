// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Server {

 String get id; String get name; String get hostname; int get port; String get username; String get password;// Added password field
 String? get privateKey;// Added private key field
 AuthType get authType; ServerStatus get status;// Snapshot Data
 double? get lastCpu; double? get lastRam; double? get lastDisk; DateTime? get lastSeen;// Persisted System Info
 String get osDistro; String get kernelVersion; String get uptime; String get hostnameInfo; String get ipAddress;// Added IP Persistence
 String get serverLocation;// Geolocation data
 int get lastLatency; int get lastDiskUsed;// Disk Used Bytes
 int get lastDiskTotal;
/// Create a copy of Server
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerCopyWith<Server> get copyWith => _$ServerCopyWithImpl<Server>(this as Server, _$identity);

  /// Serializes this Server to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Server&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.port, port) || other.port == port)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.privateKey, privateKey) || other.privateKey == privateKey)&&(identical(other.authType, authType) || other.authType == authType)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastCpu, lastCpu) || other.lastCpu == lastCpu)&&(identical(other.lastRam, lastRam) || other.lastRam == lastRam)&&(identical(other.lastDisk, lastDisk) || other.lastDisk == lastDisk)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.osDistro, osDistro) || other.osDistro == osDistro)&&(identical(other.kernelVersion, kernelVersion) || other.kernelVersion == kernelVersion)&&(identical(other.uptime, uptime) || other.uptime == uptime)&&(identical(other.hostnameInfo, hostnameInfo) || other.hostnameInfo == hostnameInfo)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.serverLocation, serverLocation) || other.serverLocation == serverLocation)&&(identical(other.lastLatency, lastLatency) || other.lastLatency == lastLatency)&&(identical(other.lastDiskUsed, lastDiskUsed) || other.lastDiskUsed == lastDiskUsed)&&(identical(other.lastDiskTotal, lastDiskTotal) || other.lastDiskTotal == lastDiskTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,hostname,port,username,password,privateKey,authType,status,lastCpu,lastRam,lastDisk,lastSeen,osDistro,kernelVersion,uptime,hostnameInfo,ipAddress,serverLocation,lastLatency,lastDiskUsed,lastDiskTotal]);

@override
String toString() {
  return 'Server(id: $id, name: $name, hostname: $hostname, port: $port, username: $username, password: $password, privateKey: $privateKey, authType: $authType, status: $status, lastCpu: $lastCpu, lastRam: $lastRam, lastDisk: $lastDisk, lastSeen: $lastSeen, osDistro: $osDistro, kernelVersion: $kernelVersion, uptime: $uptime, hostnameInfo: $hostnameInfo, ipAddress: $ipAddress, serverLocation: $serverLocation, lastLatency: $lastLatency, lastDiskUsed: $lastDiskUsed, lastDiskTotal: $lastDiskTotal)';
}


}

/// @nodoc
abstract mixin class $ServerCopyWith<$Res>  {
  factory $ServerCopyWith(Server value, $Res Function(Server) _then) = _$ServerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String hostname, int port, String username, String password, String? privateKey, AuthType authType, ServerStatus status, double? lastCpu, double? lastRam, double? lastDisk, DateTime? lastSeen, String osDistro, String kernelVersion, String uptime, String hostnameInfo, String ipAddress, String serverLocation, int lastLatency, int lastDiskUsed, int lastDiskTotal
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? hostname = null,Object? port = null,Object? username = null,Object? password = null,Object? privateKey = freezed,Object? authType = null,Object? status = null,Object? lastCpu = freezed,Object? lastRam = freezed,Object? lastDisk = freezed,Object? lastSeen = freezed,Object? osDistro = null,Object? kernelVersion = null,Object? uptime = null,Object? hostnameInfo = null,Object? ipAddress = null,Object? serverLocation = null,Object? lastLatency = null,Object? lastDiskUsed = null,Object? lastDiskTotal = null,}) {
  return _then(_self.copyWith(
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
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String hostname,  int port,  String username,  String password,  String? privateKey,  AuthType authType,  ServerStatus status,  double? lastCpu,  double? lastRam,  double? lastDisk,  DateTime? lastSeen,  String osDistro,  String kernelVersion,  String uptime,  String hostnameInfo,  String ipAddress,  String serverLocation,  int lastLatency,  int lastDiskUsed,  int lastDiskTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Server() when $default != null:
return $default(_that.id,_that.name,_that.hostname,_that.port,_that.username,_that.password,_that.privateKey,_that.authType,_that.status,_that.lastCpu,_that.lastRam,_that.lastDisk,_that.lastSeen,_that.osDistro,_that.kernelVersion,_that.uptime,_that.hostnameInfo,_that.ipAddress,_that.serverLocation,_that.lastLatency,_that.lastDiskUsed,_that.lastDiskTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String hostname,  int port,  String username,  String password,  String? privateKey,  AuthType authType,  ServerStatus status,  double? lastCpu,  double? lastRam,  double? lastDisk,  DateTime? lastSeen,  String osDistro,  String kernelVersion,  String uptime,  String hostnameInfo,  String ipAddress,  String serverLocation,  int lastLatency,  int lastDiskUsed,  int lastDiskTotal)  $default,) {final _that = this;
switch (_that) {
case _Server():
return $default(_that.id,_that.name,_that.hostname,_that.port,_that.username,_that.password,_that.privateKey,_that.authType,_that.status,_that.lastCpu,_that.lastRam,_that.lastDisk,_that.lastSeen,_that.osDistro,_that.kernelVersion,_that.uptime,_that.hostnameInfo,_that.ipAddress,_that.serverLocation,_that.lastLatency,_that.lastDiskUsed,_that.lastDiskTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String hostname,  int port,  String username,  String password,  String? privateKey,  AuthType authType,  ServerStatus status,  double? lastCpu,  double? lastRam,  double? lastDisk,  DateTime? lastSeen,  String osDistro,  String kernelVersion,  String uptime,  String hostnameInfo,  String ipAddress,  String serverLocation,  int lastLatency,  int lastDiskUsed,  int lastDiskTotal)?  $default,) {final _that = this;
switch (_that) {
case _Server() when $default != null:
return $default(_that.id,_that.name,_that.hostname,_that.port,_that.username,_that.password,_that.privateKey,_that.authType,_that.status,_that.lastCpu,_that.lastRam,_that.lastDisk,_that.lastSeen,_that.osDistro,_that.kernelVersion,_that.uptime,_that.hostnameInfo,_that.ipAddress,_that.serverLocation,_that.lastLatency,_that.lastDiskUsed,_that.lastDiskTotal);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Server implements Server {
  const _Server({required this.id, required this.name, required this.hostname, required this.port, required this.username, required this.password, this.privateKey, required this.authType, this.status = ServerStatus.unknown, this.lastCpu, this.lastRam, this.lastDisk, this.lastSeen, this.osDistro = '', this.kernelVersion = '', this.uptime = '', this.hostnameInfo = '', this.ipAddress = '', this.serverLocation = '', this.lastLatency = 0, this.lastDiskUsed = 0, this.lastDiskTotal = 0});
  factory _Server.fromJson(Map<String, dynamic> json) => _$ServerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String hostname;
@override final  int port;
@override final  String username;
@override final  String password;
// Added password field
@override final  String? privateKey;
// Added private key field
@override final  AuthType authType;
@override@JsonKey() final  ServerStatus status;
// Snapshot Data
@override final  double? lastCpu;
@override final  double? lastRam;
@override final  double? lastDisk;
@override final  DateTime? lastSeen;
// Persisted System Info
@override@JsonKey() final  String osDistro;
@override@JsonKey() final  String kernelVersion;
@override@JsonKey() final  String uptime;
@override@JsonKey() final  String hostnameInfo;
@override@JsonKey() final  String ipAddress;
// Added IP Persistence
@override@JsonKey() final  String serverLocation;
// Geolocation data
@override@JsonKey() final  int lastLatency;
@override@JsonKey() final  int lastDiskUsed;
// Disk Used Bytes
@override@JsonKey() final  int lastDiskTotal;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Server&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.port, port) || other.port == port)&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password)&&(identical(other.privateKey, privateKey) || other.privateKey == privateKey)&&(identical(other.authType, authType) || other.authType == authType)&&(identical(other.status, status) || other.status == status)&&(identical(other.lastCpu, lastCpu) || other.lastCpu == lastCpu)&&(identical(other.lastRam, lastRam) || other.lastRam == lastRam)&&(identical(other.lastDisk, lastDisk) || other.lastDisk == lastDisk)&&(identical(other.lastSeen, lastSeen) || other.lastSeen == lastSeen)&&(identical(other.osDistro, osDistro) || other.osDistro == osDistro)&&(identical(other.kernelVersion, kernelVersion) || other.kernelVersion == kernelVersion)&&(identical(other.uptime, uptime) || other.uptime == uptime)&&(identical(other.hostnameInfo, hostnameInfo) || other.hostnameInfo == hostnameInfo)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.serverLocation, serverLocation) || other.serverLocation == serverLocation)&&(identical(other.lastLatency, lastLatency) || other.lastLatency == lastLatency)&&(identical(other.lastDiskUsed, lastDiskUsed) || other.lastDiskUsed == lastDiskUsed)&&(identical(other.lastDiskTotal, lastDiskTotal) || other.lastDiskTotal == lastDiskTotal));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,hostname,port,username,password,privateKey,authType,status,lastCpu,lastRam,lastDisk,lastSeen,osDistro,kernelVersion,uptime,hostnameInfo,ipAddress,serverLocation,lastLatency,lastDiskUsed,lastDiskTotal]);

@override
String toString() {
  return 'Server(id: $id, name: $name, hostname: $hostname, port: $port, username: $username, password: $password, privateKey: $privateKey, authType: $authType, status: $status, lastCpu: $lastCpu, lastRam: $lastRam, lastDisk: $lastDisk, lastSeen: $lastSeen, osDistro: $osDistro, kernelVersion: $kernelVersion, uptime: $uptime, hostnameInfo: $hostnameInfo, ipAddress: $ipAddress, serverLocation: $serverLocation, lastLatency: $lastLatency, lastDiskUsed: $lastDiskUsed, lastDiskTotal: $lastDiskTotal)';
}


}

/// @nodoc
abstract mixin class _$ServerCopyWith<$Res> implements $ServerCopyWith<$Res> {
  factory _$ServerCopyWith(_Server value, $Res Function(_Server) _then) = __$ServerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String hostname, int port, String username, String password, String? privateKey, AuthType authType, ServerStatus status, double? lastCpu, double? lastRam, double? lastDisk, DateTime? lastSeen, String osDistro, String kernelVersion, String uptime, String hostnameInfo, String ipAddress, String serverLocation, int lastLatency, int lastDiskUsed, int lastDiskTotal
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? hostname = null,Object? port = null,Object? username = null,Object? password = null,Object? privateKey = freezed,Object? authType = null,Object? status = null,Object? lastCpu = freezed,Object? lastRam = freezed,Object? lastDisk = freezed,Object? lastSeen = freezed,Object? osDistro = null,Object? kernelVersion = null,Object? uptime = null,Object? hostnameInfo = null,Object? ipAddress = null,Object? serverLocation = null,Object? lastLatency = null,Object? lastDiskUsed = null,Object? lastDiskTotal = null,}) {
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
as int,
  ));
}


}

// dart format on
