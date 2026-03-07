// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ServerStats {
  double get cpuPct => throw _privateConstructorUsedError;
  double get ramPct => throw _privateConstructorUsedError;
  double get diskPct => throw _privateConstructorUsedError;
  String get uptime => throw _privateConstructorUsedError;
  double get netRx => throw _privateConstructorUsedError; // KB/s
  double get netTx => throw _privateConstructorUsedError; // KB/s
  int get cpuIdle => throw _privateConstructorUsedError;
  int get cpuTotal => throw _privateConstructorUsedError;
  int get latencyMs => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  String get hostname => throw _privateConstructorUsedError;
  String get ipAddress => throw _privateConstructorUsedError;
  String get serverLocation => throw _privateConstructorUsedError;
  String get osDistro => throw _privateConstructorUsedError;
  String get kernelVersion => throw _privateConstructorUsedError;
  int get diskUsed => throw _privateConstructorUsedError;
  int get diskTotal => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ServerStatsCopyWith<ServerStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServerStatsCopyWith<$Res> {
  factory $ServerStatsCopyWith(
          ServerStats value, $Res Function(ServerStats) then) =
      _$ServerStatsCopyWithImpl<$Res, ServerStats>;
  @useResult
  $Res call(
      {double cpuPct,
      double ramPct,
      double diskPct,
      String uptime,
      double netRx,
      double netTx,
      int cpuIdle,
      int cpuTotal,
      int latencyMs,
      DateTime? timestamp,
      String hostname,
      String ipAddress,
      String serverLocation,
      String osDistro,
      String kernelVersion,
      int diskUsed,
      int diskTotal});
}

/// @nodoc
class _$ServerStatsCopyWithImpl<$Res, $Val extends ServerStats>
    implements $ServerStatsCopyWith<$Res> {
  _$ServerStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuPct = null,
    Object? ramPct = null,
    Object? diskPct = null,
    Object? uptime = null,
    Object? netRx = null,
    Object? netTx = null,
    Object? cpuIdle = null,
    Object? cpuTotal = null,
    Object? latencyMs = null,
    Object? timestamp = freezed,
    Object? hostname = null,
    Object? ipAddress = null,
    Object? serverLocation = null,
    Object? osDistro = null,
    Object? kernelVersion = null,
    Object? diskUsed = null,
    Object? diskTotal = null,
  }) {
    return _then(_value.copyWith(
      cpuPct: null == cpuPct
          ? _value.cpuPct
          : cpuPct // ignore: cast_nullable_to_non_nullable
              as double,
      ramPct: null == ramPct
          ? _value.ramPct
          : ramPct // ignore: cast_nullable_to_non_nullable
              as double,
      diskPct: null == diskPct
          ? _value.diskPct
          : diskPct // ignore: cast_nullable_to_non_nullable
              as double,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as String,
      netRx: null == netRx
          ? _value.netRx
          : netRx // ignore: cast_nullable_to_non_nullable
              as double,
      netTx: null == netTx
          ? _value.netTx
          : netTx // ignore: cast_nullable_to_non_nullable
              as double,
      cpuIdle: null == cpuIdle
          ? _value.cpuIdle
          : cpuIdle // ignore: cast_nullable_to_non_nullable
              as int,
      cpuTotal: null == cpuTotal
          ? _value.cpuTotal
          : cpuTotal // ignore: cast_nullable_to_non_nullable
              as int,
      latencyMs: null == latencyMs
          ? _value.latencyMs
          : latencyMs // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hostname: null == hostname
          ? _value.hostname
          : hostname // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      serverLocation: null == serverLocation
          ? _value.serverLocation
          : serverLocation // ignore: cast_nullable_to_non_nullable
              as String,
      osDistro: null == osDistro
          ? _value.osDistro
          : osDistro // ignore: cast_nullable_to_non_nullable
              as String,
      kernelVersion: null == kernelVersion
          ? _value.kernelVersion
          : kernelVersion // ignore: cast_nullable_to_non_nullable
              as String,
      diskUsed: null == diskUsed
          ? _value.diskUsed
          : diskUsed // ignore: cast_nullable_to_non_nullable
              as int,
      diskTotal: null == diskTotal
          ? _value.diskTotal
          : diskTotal // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServerStatsImplCopyWith<$Res>
    implements $ServerStatsCopyWith<$Res> {
  factory _$$ServerStatsImplCopyWith(
          _$ServerStatsImpl value, $Res Function(_$ServerStatsImpl) then) =
      __$$ServerStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double cpuPct,
      double ramPct,
      double diskPct,
      String uptime,
      double netRx,
      double netTx,
      int cpuIdle,
      int cpuTotal,
      int latencyMs,
      DateTime? timestamp,
      String hostname,
      String ipAddress,
      String serverLocation,
      String osDistro,
      String kernelVersion,
      int diskUsed,
      int diskTotal});
}

/// @nodoc
class __$$ServerStatsImplCopyWithImpl<$Res>
    extends _$ServerStatsCopyWithImpl<$Res, _$ServerStatsImpl>
    implements _$$ServerStatsImplCopyWith<$Res> {
  __$$ServerStatsImplCopyWithImpl(
      _$ServerStatsImpl _value, $Res Function(_$ServerStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? cpuPct = null,
    Object? ramPct = null,
    Object? diskPct = null,
    Object? uptime = null,
    Object? netRx = null,
    Object? netTx = null,
    Object? cpuIdle = null,
    Object? cpuTotal = null,
    Object? latencyMs = null,
    Object? timestamp = freezed,
    Object? hostname = null,
    Object? ipAddress = null,
    Object? serverLocation = null,
    Object? osDistro = null,
    Object? kernelVersion = null,
    Object? diskUsed = null,
    Object? diskTotal = null,
  }) {
    return _then(_$ServerStatsImpl(
      cpuPct: null == cpuPct
          ? _value.cpuPct
          : cpuPct // ignore: cast_nullable_to_non_nullable
              as double,
      ramPct: null == ramPct
          ? _value.ramPct
          : ramPct // ignore: cast_nullable_to_non_nullable
              as double,
      diskPct: null == diskPct
          ? _value.diskPct
          : diskPct // ignore: cast_nullable_to_non_nullable
              as double,
      uptime: null == uptime
          ? _value.uptime
          : uptime // ignore: cast_nullable_to_non_nullable
              as String,
      netRx: null == netRx
          ? _value.netRx
          : netRx // ignore: cast_nullable_to_non_nullable
              as double,
      netTx: null == netTx
          ? _value.netTx
          : netTx // ignore: cast_nullable_to_non_nullable
              as double,
      cpuIdle: null == cpuIdle
          ? _value.cpuIdle
          : cpuIdle // ignore: cast_nullable_to_non_nullable
              as int,
      cpuTotal: null == cpuTotal
          ? _value.cpuTotal
          : cpuTotal // ignore: cast_nullable_to_non_nullable
              as int,
      latencyMs: null == latencyMs
          ? _value.latencyMs
          : latencyMs // ignore: cast_nullable_to_non_nullable
              as int,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hostname: null == hostname
          ? _value.hostname
          : hostname // ignore: cast_nullable_to_non_nullable
              as String,
      ipAddress: null == ipAddress
          ? _value.ipAddress
          : ipAddress // ignore: cast_nullable_to_non_nullable
              as String,
      serverLocation: null == serverLocation
          ? _value.serverLocation
          : serverLocation // ignore: cast_nullable_to_non_nullable
              as String,
      osDistro: null == osDistro
          ? _value.osDistro
          : osDistro // ignore: cast_nullable_to_non_nullable
              as String,
      kernelVersion: null == kernelVersion
          ? _value.kernelVersion
          : kernelVersion // ignore: cast_nullable_to_non_nullable
              as String,
      diskUsed: null == diskUsed
          ? _value.diskUsed
          : diskUsed // ignore: cast_nullable_to_non_nullable
              as int,
      diskTotal: null == diskTotal
          ? _value.diskTotal
          : diskTotal // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ServerStatsImpl implements _ServerStats {
  const _$ServerStatsImpl(
      {this.cpuPct = 0.0,
      this.ramPct = 0.0,
      this.diskPct = 0.0,
      this.uptime = '',
      this.netRx = 0.0,
      this.netTx = 0.0,
      this.cpuIdle = 0,
      this.cpuTotal = 0,
      this.latencyMs = 0,
      this.timestamp,
      this.hostname = '',
      this.ipAddress = '',
      this.serverLocation = '',
      this.osDistro = '',
      this.kernelVersion = '',
      this.diskUsed = 0,
      this.diskTotal = 0});

  @override
  @JsonKey()
  final double cpuPct;
  @override
  @JsonKey()
  final double ramPct;
  @override
  @JsonKey()
  final double diskPct;
  @override
  @JsonKey()
  final String uptime;
  @override
  @JsonKey()
  final double netRx;
// KB/s
  @override
  @JsonKey()
  final double netTx;
// KB/s
  @override
  @JsonKey()
  final int cpuIdle;
  @override
  @JsonKey()
  final int cpuTotal;
  @override
  @JsonKey()
  final int latencyMs;
  @override
  final DateTime? timestamp;
  @override
  @JsonKey()
  final String hostname;
  @override
  @JsonKey()
  final String ipAddress;
  @override
  @JsonKey()
  final String serverLocation;
  @override
  @JsonKey()
  final String osDistro;
  @override
  @JsonKey()
  final String kernelVersion;
  @override
  @JsonKey()
  final int diskUsed;
  @override
  @JsonKey()
  final int diskTotal;

  @override
  String toString() {
    return 'ServerStats(cpuPct: $cpuPct, ramPct: $ramPct, diskPct: $diskPct, uptime: $uptime, netRx: $netRx, netTx: $netTx, cpuIdle: $cpuIdle, cpuTotal: $cpuTotal, latencyMs: $latencyMs, timestamp: $timestamp, hostname: $hostname, ipAddress: $ipAddress, serverLocation: $serverLocation, osDistro: $osDistro, kernelVersion: $kernelVersion, diskUsed: $diskUsed, diskTotal: $diskTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServerStatsImpl &&
            (identical(other.cpuPct, cpuPct) || other.cpuPct == cpuPct) &&
            (identical(other.ramPct, ramPct) || other.ramPct == ramPct) &&
            (identical(other.diskPct, diskPct) || other.diskPct == diskPct) &&
            (identical(other.uptime, uptime) || other.uptime == uptime) &&
            (identical(other.netRx, netRx) || other.netRx == netRx) &&
            (identical(other.netTx, netTx) || other.netTx == netTx) &&
            (identical(other.cpuIdle, cpuIdle) || other.cpuIdle == cpuIdle) &&
            (identical(other.cpuTotal, cpuTotal) ||
                other.cpuTotal == cpuTotal) &&
            (identical(other.latencyMs, latencyMs) ||
                other.latencyMs == latencyMs) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.hostname, hostname) ||
                other.hostname == hostname) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress) &&
            (identical(other.serverLocation, serverLocation) ||
                other.serverLocation == serverLocation) &&
            (identical(other.osDistro, osDistro) ||
                other.osDistro == osDistro) &&
            (identical(other.kernelVersion, kernelVersion) ||
                other.kernelVersion == kernelVersion) &&
            (identical(other.diskUsed, diskUsed) ||
                other.diskUsed == diskUsed) &&
            (identical(other.diskTotal, diskTotal) ||
                other.diskTotal == diskTotal));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      cpuPct,
      ramPct,
      diskPct,
      uptime,
      netRx,
      netTx,
      cpuIdle,
      cpuTotal,
      latencyMs,
      timestamp,
      hostname,
      ipAddress,
      serverLocation,
      osDistro,
      kernelVersion,
      diskUsed,
      diskTotal);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServerStatsImplCopyWith<_$ServerStatsImpl> get copyWith =>
      __$$ServerStatsImplCopyWithImpl<_$ServerStatsImpl>(this, _$identity);
}

abstract class _ServerStats implements ServerStats {
  const factory _ServerStats(
      {final double cpuPct,
      final double ramPct,
      final double diskPct,
      final String uptime,
      final double netRx,
      final double netTx,
      final int cpuIdle,
      final int cpuTotal,
      final int latencyMs,
      final DateTime? timestamp,
      final String hostname,
      final String ipAddress,
      final String serverLocation,
      final String osDistro,
      final String kernelVersion,
      final int diskUsed,
      final int diskTotal}) = _$ServerStatsImpl;

  @override
  double get cpuPct;
  @override
  double get ramPct;
  @override
  double get diskPct;
  @override
  String get uptime;
  @override
  double get netRx;
  @override // KB/s
  double get netTx;
  @override // KB/s
  int get cpuIdle;
  @override
  int get cpuTotal;
  @override
  int get latencyMs;
  @override
  DateTime? get timestamp;
  @override
  String get hostname;
  @override
  String get ipAddress;
  @override
  String get serverLocation;
  @override
  String get osDistro;
  @override
  String get kernelVersion;
  @override
  int get diskUsed;
  @override
  int get diskTotal;
  @override
  @JsonKey(ignore: true)
  _$$ServerStatsImplCopyWith<_$ServerStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
