import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/utils/linux_parser.dart';
import 'package:orbit/features/dashboard/models/server_stats.dart';
import 'package:orbit/core/services/geolocation_service.dart';

// StreamProvider family to provide separate streams for each server
final serverStatsProvider =
    StreamProvider.family.autoDispose<ServerStats, Server>((ref, server) {
  final pollingService = ref.watch(pollingServiceProvider);
  return pollingService.streamStats(server);
});

final pollingServiceProvider = Provider<PollingService>((ref) {
  // serverServiceProvider is a FutureProvider, so we must use the AsyncValue property carefully
  final serverServiceAsync = ref.watch(serverServiceProvider);
  return PollingService(
    ref.watch(sshServiceProvider),
    serverServiceAsync.asData?.value, // Handled as nullable in PollingService
  );
});

class PollingService {
  final dynamic _sshService;
  final dynamic _serverService; // Add reference

  PollingService(this._sshService, this._serverService);

  Stream<ServerStats> streamStats(Server server) async* {
    SSHClient? client;
    int prevIdle = 0;
    int prevTotal = 0;

    try {
      // 1. Connect
      debugPrint('Polling Service: Connecting to ${server.hostname}...');
      client = await _sshService.connect(
        server.hostname,
        server.port,
        server.username,
        server.password,
      );

      if (client == null) throw Exception('Connection failed');

      // 2. Periodic Polling Logic: Adaptive Stop-and-Wait
      const String pollingCmd =
          'cat /proc/stat; echo "|||"; free -b; echo "|||"; df -k /; echo "|||"; cat /proc/uptime; echo "|||"; hostname; echo "|||"; hostname -I | awk \'{print \$1}\'; echo "|||"; cat /etc/os-release | grep PRETTY_NAME | cut -d" -f2; echo "|||"; uname -r; exit';

      while (true) {
        double cpuPct = 0.0;
        double ramPct = 0.0;
        double diskPct = 0.0;
        String uptime = 'Connected';
        int latencyMs = 0;

        String hostname = '';
        String ipAddress = '';
        String osDistro = '';
        String kernelVersion = '';
        int diskUsed = 0;
        int diskTotal = 0;
        String serverLocation = server.serverLocation;

        try {
          final stopwatch = Stopwatch()..start();
          final rawOutput =
              await _runCommand(client, pollingCmd, timeoutSeconds: 15);
          stopwatch.stop();
          latencyMs = stopwatch.elapsedMilliseconds;

          // Bulletproof Parsing (Danger Zone)
          try {
            final statsMap = LinuxParser.parseAll(rawOutput,
                prevIdle: prevIdle, prevTotal: prevTotal);

            cpuPct = statsMap['cpuPct'];
            ramPct = statsMap['ramPct'];
            diskPct = statsMap['diskPct'];
            uptime = statsMap['uptime'];
            prevIdle = statsMap['cpuIdle'];
            prevTotal = statsMap['cpuTotal'];
            hostname = statsMap['hostname'];
            ipAddress = statsMap['ipAddress'];
            osDistro = statsMap['osDistro'];
            kernelVersion = statsMap['kernelVersion'];
            diskUsed = statsMap['diskUsed'] ?? 0;
            diskTotal = statsMap['diskTotal'] ?? 0;
          } catch (parseError) {
            debugPrint("SSH: PARSER CRASHED: $parseError");
            uptime = "Parser Error";
          }

          if (serverLocation.isEmpty && ipAddress.isNotEmpty) {
            try {
              serverLocation =
                  await GeolocationService.getLocationFromIp(ipAddress);
            } catch (e) {
              debugPrint('Polling Service: Error fetching geolocation: $e');
            }
          }

          final stats = ServerStats(
            cpuPct: cpuPct,
            ramPct: ramPct,
            diskPct: diskPct,
            uptime: uptime,
            cpuIdle: prevIdle,
            cpuTotal: prevTotal,
            latencyMs: latencyMs,
            timestamp: DateTime.now(),
            hostname: hostname,
            ipAddress: ipAddress,
            serverLocation: serverLocation,
            osDistro: osDistro,
            kernelVersion: kernelVersion,
            diskUsed: diskUsed,
            diskTotal: diskTotal,
          );

          yield stats;

          // Fire and Forget: Save snapshot to DB for Home Screen
          if (_serverService != null) {
            _serverService.updateSnapshot(server.id, stats);
          }
        } catch (e) {
          debugPrint('Polling Error: $e');
          yield ServerStats(
            cpuPct: 0.0,
            ramPct: 0.0,
            diskPct: 0.0,
            uptime: 'Network Error',
            cpuIdle: prevIdle,
            cpuTotal: prevTotal,
            latencyMs: latencyMs,
            timestamp: DateTime.now(),
          );
        }

        // Wait for next cycle AFTER current one finishes
        await Future.delayed(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint('Polling Stream Error: $e');
      rethrow;
    } finally {
      client?.close();
      debugPrint('Polling Service: Connection closed for ${server.hostname}');
    }
  }

  Future<String> _runCommand(SSHClient client, String command,
      {int timeoutSeconds = 5}) async {
    try {
      final result = await client.run(command).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          debugPrint('SSH: Command "$command" timed out!');
          throw TimeoutException('Command execution timed out');
        },
      );
      return utf8.decode(result);
    } catch (e) {
      debugPrint('SSH: Command execution failed: $e');
      rethrow;
    }
  }
}
