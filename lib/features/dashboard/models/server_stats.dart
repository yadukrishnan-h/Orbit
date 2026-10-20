import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_stats.freezed.dart';

@freezed
abstract class ServerStats with _$ServerStats {
  const factory ServerStats({
    @Default(0.0) double cpuPct,
    @Default(0.0) double ramPct,
    @Default(0.0) double diskPct,
    @Default('') String uptime,
    @Default(0.0) double netRx, // KB/s
    @Default(0.0) double netTx, // KB/s
    @Default(0) int cpuIdle,
    @Default(0) int cpuTotal,
    @Default(0) int latencyMs,
    DateTime? timestamp,
    @Default('') String hostname,
    @Default('') String ipAddress,
    @Default('') String serverLocation,
    @Default('') String osDistro,
    @Default('') String kernelVersion,
    @Default(0) int diskUsed,
    @Default(0) int diskTotal,
    @Default(0) int ramUsed,
    @Default(0) int ramTotal,
    @Default('') String cpuModel,
    @Default(0) int cpuCores,
    @Default('') String cpuSpeed,
    @Default(0.0) double load1,
    @Default(0.0) double load5,
    @Default(0.0) double load15,
  }) = _ServerStats;
}
