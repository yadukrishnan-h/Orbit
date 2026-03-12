// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerStats {

 double get cpuPct; double get ramPct; double get diskPct; String get uptime; double get netRx;// KB/s
 double get netTx;// KB/s
 int get cpuIdle; int get cpuTotal; int get latencyMs; DateTime? get timestamp; String get hostname; String get ipAddress; String get serverLocation; String get osDistro; String get kernelVersion; int get diskUsed; int get diskTotal;
/// Create a copy of ServerStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerStatsCopyWith<ServerStats> get copyWith => _$ServerStatsCopyWithImpl<ServerStats>(this as ServerStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerStats&&(identical(other.cpuPct, cpuPct) || other.cpuPct == cpuPct)&&(identical(other.ramPct, ramPct) || other.ramPct == ramPct)&&(identical(other.diskPct, diskPct) || other.diskPct == diskPct)&&(identical(other.uptime, uptime) || other.uptime == uptime)&&(identical(other.netRx, netRx) || other.netRx == netRx)&&(identical(other.netTx, netTx) || other.netTx == netTx)&&(identical(other.cpuIdle, cpuIdle) || other.cpuIdle == cpuIdle)&&(identical(other.cpuTotal, cpuTotal) || other.cpuTotal == cpuTotal)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.serverLocation, serverLocation) || other.serverLocation == serverLocation)&&(identical(other.osDistro, osDistro) || other.osDistro == osDistro)&&(identical(other.kernelVersion, kernelVersion) || other.kernelVersion == kernelVersion)&&(identical(other.diskUsed, diskUsed) || other.diskUsed == diskUsed)&&(identical(other.diskTotal, diskTotal) || other.diskTotal == diskTotal));
}


@override
int get hashCode => Object.hash(runtimeType,cpuPct,ramPct,diskPct,uptime,netRx,netTx,cpuIdle,cpuTotal,latencyMs,timestamp,hostname,ipAddress,serverLocation,osDistro,kernelVersion,diskUsed,diskTotal);

@override
String toString() {
  return 'ServerStats(cpuPct: $cpuPct, ramPct: $ramPct, diskPct: $diskPct, uptime: $uptime, netRx: $netRx, netTx: $netTx, cpuIdle: $cpuIdle, cpuTotal: $cpuTotal, latencyMs: $latencyMs, timestamp: $timestamp, hostname: $hostname, ipAddress: $ipAddress, serverLocation: $serverLocation, osDistro: $osDistro, kernelVersion: $kernelVersion, diskUsed: $diskUsed, diskTotal: $diskTotal)';
}


}

/// @nodoc
abstract mixin class $ServerStatsCopyWith<$Res>  {
  factory $ServerStatsCopyWith(ServerStats value, $Res Function(ServerStats) _then) = _$ServerStatsCopyWithImpl;
@useResult
$Res call({
 double cpuPct, double ramPct, double diskPct, String uptime, double netRx, double netTx, int cpuIdle, int cpuTotal, int latencyMs, DateTime? timestamp, String hostname, String ipAddress, String serverLocation, String osDistro, String kernelVersion, int diskUsed, int diskTotal
});




}
/// @nodoc
class _$ServerStatsCopyWithImpl<$Res>
    implements $ServerStatsCopyWith<$Res> {
  _$ServerStatsCopyWithImpl(this._self, this._then);

  final ServerStats _self;
  final $Res Function(ServerStats) _then;

/// Create a copy of ServerStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cpuPct = null,Object? ramPct = null,Object? diskPct = null,Object? uptime = null,Object? netRx = null,Object? netTx = null,Object? cpuIdle = null,Object? cpuTotal = null,Object? latencyMs = null,Object? timestamp = freezed,Object? hostname = null,Object? ipAddress = null,Object? serverLocation = null,Object? osDistro = null,Object? kernelVersion = null,Object? diskUsed = null,Object? diskTotal = null,}) {
  return _then(_self.copyWith(
cpuPct: null == cpuPct ? _self.cpuPct : cpuPct // ignore: cast_nullable_to_non_nullable
as double,ramPct: null == ramPct ? _self.ramPct : ramPct // ignore: cast_nullable_to_non_nullable
as double,diskPct: null == diskPct ? _self.diskPct : diskPct // ignore: cast_nullable_to_non_nullable
as double,uptime: null == uptime ? _self.uptime : uptime // ignore: cast_nullable_to_non_nullable
as String,netRx: null == netRx ? _self.netRx : netRx // ignore: cast_nullable_to_non_nullable
as double,netTx: null == netTx ? _self.netTx : netTx // ignore: cast_nullable_to_non_nullable
as double,cpuIdle: null == cpuIdle ? _self.cpuIdle : cpuIdle // ignore: cast_nullable_to_non_nullable
as int,cpuTotal: null == cpuTotal ? _self.cpuTotal : cpuTotal // ignore: cast_nullable_to_non_nullable
as int,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,serverLocation: null == serverLocation ? _self.serverLocation : serverLocation // ignore: cast_nullable_to_non_nullable
as String,osDistro: null == osDistro ? _self.osDistro : osDistro // ignore: cast_nullable_to_non_nullable
as String,kernelVersion: null == kernelVersion ? _self.kernelVersion : kernelVersion // ignore: cast_nullable_to_non_nullable
as String,diskUsed: null == diskUsed ? _self.diskUsed : diskUsed // ignore: cast_nullable_to_non_nullable
as int,diskTotal: null == diskTotal ? _self.diskTotal : diskTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerStats].
extension ServerStatsPatterns on ServerStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerStats value)  $default,){
final _that = this;
switch (_that) {
case _ServerStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerStats value)?  $default,){
final _that = this;
switch (_that) {
case _ServerStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double cpuPct,  double ramPct,  double diskPct,  String uptime,  double netRx,  double netTx,  int cpuIdle,  int cpuTotal,  int latencyMs,  DateTime? timestamp,  String hostname,  String ipAddress,  String serverLocation,  String osDistro,  String kernelVersion,  int diskUsed,  int diskTotal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerStats() when $default != null:
return $default(_that.cpuPct,_that.ramPct,_that.diskPct,_that.uptime,_that.netRx,_that.netTx,_that.cpuIdle,_that.cpuTotal,_that.latencyMs,_that.timestamp,_that.hostname,_that.ipAddress,_that.serverLocation,_that.osDistro,_that.kernelVersion,_that.diskUsed,_that.diskTotal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double cpuPct,  double ramPct,  double diskPct,  String uptime,  double netRx,  double netTx,  int cpuIdle,  int cpuTotal,  int latencyMs,  DateTime? timestamp,  String hostname,  String ipAddress,  String serverLocation,  String osDistro,  String kernelVersion,  int diskUsed,  int diskTotal)  $default,) {final _that = this;
switch (_that) {
case _ServerStats():
return $default(_that.cpuPct,_that.ramPct,_that.diskPct,_that.uptime,_that.netRx,_that.netTx,_that.cpuIdle,_that.cpuTotal,_that.latencyMs,_that.timestamp,_that.hostname,_that.ipAddress,_that.serverLocation,_that.osDistro,_that.kernelVersion,_that.diskUsed,_that.diskTotal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double cpuPct,  double ramPct,  double diskPct,  String uptime,  double netRx,  double netTx,  int cpuIdle,  int cpuTotal,  int latencyMs,  DateTime? timestamp,  String hostname,  String ipAddress,  String serverLocation,  String osDistro,  String kernelVersion,  int diskUsed,  int diskTotal)?  $default,) {final _that = this;
switch (_that) {
case _ServerStats() when $default != null:
return $default(_that.cpuPct,_that.ramPct,_that.diskPct,_that.uptime,_that.netRx,_that.netTx,_that.cpuIdle,_that.cpuTotal,_that.latencyMs,_that.timestamp,_that.hostname,_that.ipAddress,_that.serverLocation,_that.osDistro,_that.kernelVersion,_that.diskUsed,_that.diskTotal);case _:
  return null;

}
}

}

/// @nodoc


class _ServerStats implements ServerStats {
  const _ServerStats({this.cpuPct = 0.0, this.ramPct = 0.0, this.diskPct = 0.0, this.uptime = '', this.netRx = 0.0, this.netTx = 0.0, this.cpuIdle = 0, this.cpuTotal = 0, this.latencyMs = 0, this.timestamp, this.hostname = '', this.ipAddress = '', this.serverLocation = '', this.osDistro = '', this.kernelVersion = '', this.diskUsed = 0, this.diskTotal = 0});
  

@override@JsonKey() final  double cpuPct;
@override@JsonKey() final  double ramPct;
@override@JsonKey() final  double diskPct;
@override@JsonKey() final  String uptime;
@override@JsonKey() final  double netRx;
// KB/s
@override@JsonKey() final  double netTx;
// KB/s
@override@JsonKey() final  int cpuIdle;
@override@JsonKey() final  int cpuTotal;
@override@JsonKey() final  int latencyMs;
@override final  DateTime? timestamp;
@override@JsonKey() final  String hostname;
@override@JsonKey() final  String ipAddress;
@override@JsonKey() final  String serverLocation;
@override@JsonKey() final  String osDistro;
@override@JsonKey() final  String kernelVersion;
@override@JsonKey() final  int diskUsed;
@override@JsonKey() final  int diskTotal;

/// Create a copy of ServerStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerStatsCopyWith<_ServerStats> get copyWith => __$ServerStatsCopyWithImpl<_ServerStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerStats&&(identical(other.cpuPct, cpuPct) || other.cpuPct == cpuPct)&&(identical(other.ramPct, ramPct) || other.ramPct == ramPct)&&(identical(other.diskPct, diskPct) || other.diskPct == diskPct)&&(identical(other.uptime, uptime) || other.uptime == uptime)&&(identical(other.netRx, netRx) || other.netRx == netRx)&&(identical(other.netTx, netTx) || other.netTx == netTx)&&(identical(other.cpuIdle, cpuIdle) || other.cpuIdle == cpuIdle)&&(identical(other.cpuTotal, cpuTotal) || other.cpuTotal == cpuTotal)&&(identical(other.latencyMs, latencyMs) || other.latencyMs == latencyMs)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.hostname, hostname) || other.hostname == hostname)&&(identical(other.ipAddress, ipAddress) || other.ipAddress == ipAddress)&&(identical(other.serverLocation, serverLocation) || other.serverLocation == serverLocation)&&(identical(other.osDistro, osDistro) || other.osDistro == osDistro)&&(identical(other.kernelVersion, kernelVersion) || other.kernelVersion == kernelVersion)&&(identical(other.diskUsed, diskUsed) || other.diskUsed == diskUsed)&&(identical(other.diskTotal, diskTotal) || other.diskTotal == diskTotal));
}


@override
int get hashCode => Object.hash(runtimeType,cpuPct,ramPct,diskPct,uptime,netRx,netTx,cpuIdle,cpuTotal,latencyMs,timestamp,hostname,ipAddress,serverLocation,osDistro,kernelVersion,diskUsed,diskTotal);

@override
String toString() {
  return 'ServerStats(cpuPct: $cpuPct, ramPct: $ramPct, diskPct: $diskPct, uptime: $uptime, netRx: $netRx, netTx: $netTx, cpuIdle: $cpuIdle, cpuTotal: $cpuTotal, latencyMs: $latencyMs, timestamp: $timestamp, hostname: $hostname, ipAddress: $ipAddress, serverLocation: $serverLocation, osDistro: $osDistro, kernelVersion: $kernelVersion, diskUsed: $diskUsed, diskTotal: $diskTotal)';
}


}

/// @nodoc
abstract mixin class _$ServerStatsCopyWith<$Res> implements $ServerStatsCopyWith<$Res> {
  factory _$ServerStatsCopyWith(_ServerStats value, $Res Function(_ServerStats) _then) = __$ServerStatsCopyWithImpl;
@override @useResult
$Res call({
 double cpuPct, double ramPct, double diskPct, String uptime, double netRx, double netTx, int cpuIdle, int cpuTotal, int latencyMs, DateTime? timestamp, String hostname, String ipAddress, String serverLocation, String osDistro, String kernelVersion, int diskUsed, int diskTotal
});




}
/// @nodoc
class __$ServerStatsCopyWithImpl<$Res>
    implements _$ServerStatsCopyWith<$Res> {
  __$ServerStatsCopyWithImpl(this._self, this._then);

  final _ServerStats _self;
  final $Res Function(_ServerStats) _then;

/// Create a copy of ServerStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cpuPct = null,Object? ramPct = null,Object? diskPct = null,Object? uptime = null,Object? netRx = null,Object? netTx = null,Object? cpuIdle = null,Object? cpuTotal = null,Object? latencyMs = null,Object? timestamp = freezed,Object? hostname = null,Object? ipAddress = null,Object? serverLocation = null,Object? osDistro = null,Object? kernelVersion = null,Object? diskUsed = null,Object? diskTotal = null,}) {
  return _then(_ServerStats(
cpuPct: null == cpuPct ? _self.cpuPct : cpuPct // ignore: cast_nullable_to_non_nullable
as double,ramPct: null == ramPct ? _self.ramPct : ramPct // ignore: cast_nullable_to_non_nullable
as double,diskPct: null == diskPct ? _self.diskPct : diskPct // ignore: cast_nullable_to_non_nullable
as double,uptime: null == uptime ? _self.uptime : uptime // ignore: cast_nullable_to_non_nullable
as String,netRx: null == netRx ? _self.netRx : netRx // ignore: cast_nullable_to_non_nullable
as double,netTx: null == netTx ? _self.netTx : netTx // ignore: cast_nullable_to_non_nullable
as double,cpuIdle: null == cpuIdle ? _self.cpuIdle : cpuIdle // ignore: cast_nullable_to_non_nullable
as int,cpuTotal: null == cpuTotal ? _self.cpuTotal : cpuTotal // ignore: cast_nullable_to_non_nullable
as int,latencyMs: null == latencyMs ? _self.latencyMs : latencyMs // ignore: cast_nullable_to_non_nullable
as int,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,hostname: null == hostname ? _self.hostname : hostname // ignore: cast_nullable_to_non_nullable
as String,ipAddress: null == ipAddress ? _self.ipAddress : ipAddress // ignore: cast_nullable_to_non_nullable
as String,serverLocation: null == serverLocation ? _self.serverLocation : serverLocation // ignore: cast_nullable_to_non_nullable
as String,osDistro: null == osDistro ? _self.osDistro : osDistro // ignore: cast_nullable_to_non_nullable
as String,kernelVersion: null == kernelVersion ? _self.kernelVersion : kernelVersion // ignore: cast_nullable_to_non_nullable
as String,diskUsed: null == diskUsed ? _self.diskUsed : diskUsed // ignore: cast_nullable_to_non_nullable
as int,diskTotal: null == diskTotal ? _self.diskTotal : diskTotal // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
