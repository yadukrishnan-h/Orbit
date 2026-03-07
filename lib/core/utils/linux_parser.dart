import 'package:flutter/foundation.dart';

/// CPU ticks data structure for delta calculation
class CpuTicks {
  final int total;
  final int idle;

  CpuTicks(this.total, this.idle);

  factory CpuTicks.parse(String rawData) {
    try {
      // 1. Find the line starting with "cpu " (aggregate)
      // This ignores "cpu0", "cpu1", etc.
      final lines = rawData.split('\n');

      final cpuLine = lines.firstWhere(
        (line) => line.trim().startsWith('cpu '),
        orElse: () => "",
      );

      if (cpuLine.isEmpty) {
        debugPrint("CpuTicks Parser Error: Could not find 'cpu' line in data");
        return CpuTicks(0, 0);
      }

      // 2. Extract numbers using Regex (handles multiple spaces)
      // Matches: cpu  <user> <nice> <system> <idle> <iowait> <irq> <softirq> <steal>
      final RegExp regExp = RegExp(
          r'cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)(?:\s+(\d+))?(?:\s+(\d+))?(?:\s+(\d+))?(?:\s+(\d+))?');
      final match = regExp.firstMatch(cpuLine);

      if (match == null) {
        debugPrint(
            "CpuTicks Parser Error: Regex failed to match line: $cpuLine");
        return CpuTicks(0, 0);
      }

      // 3. Parse fields
      // /proc/stat columns: user, nice, system, idle, iowait, irq, softirq, steal
      final user = int.parse(match.group(1)!);
      final nice = int.parse(match.group(2)!);
      final system = int.parse(match.group(3)!);
      final idleVal = int.parse(match.group(4)!);
      final iowait = int.tryParse(match.group(5) ?? '0') ?? 0;
      final irq = int.tryParse(match.group(6) ?? '0') ?? 0;
      final softirq = int.tryParse(match.group(7) ?? '0') ?? 0;
      final steal = int.tryParse(match.group(8) ?? '0') ?? 0;

      // 4. Calculate Totals
      // Idle = idle + iowait (both represent idle time)
      final currentIdle = idleVal + iowait;
      // Total = Sum of all fields
      final currentTotal =
          user + nice + system + idleVal + iowait + irq + softirq + steal;

      return CpuTicks(currentTotal, currentIdle);
    } catch (e) {
      debugPrint("CpuTicks Parser Exception: $e");
      return CpuTicks(0, 0);
    }
  }
}

class LinuxParser {
  static final RegExp _whiteSpace = RegExp(r'\s+');

  /// Parses /proc/stat CPU line: "cpu  2255 34 2290 22625563 6290 127 456"
  /// Returns [idle, total]
  static List<int> parseCpuLine(String line) {
    try {
      if (!line.startsWith('cpu ')) return [0, 0];

      final parts = line.trim().split(_whiteSpace);
      if (parts.length < 5) return [0, 0];

      // parts[0] is 'cpu'
      // user force nice idle iowait irq softirq
      final user = int.parse(parts[1]);
      final nice = int.parse(parts[2]);
      final system = int.parse(parts[3]);
      final idle = int.parse(parts[4]);
      final iowait = parts.length > 5 ? int.parse(parts[5]) : 0;
      final irq = parts.length > 6 ? int.parse(parts[6]) : 0;
      final softirq = parts.length > 7 ? int.parse(parts[7]) : 0;
      final steal = parts.length > 8 ? int.parse(parts[8]) : 0;

      final total =
          user + nice + system + idle + iowait + irq + softirq + steal;
      return [idle, total];
    } catch (e) {
      return [0, 0];
    }
  }

  /// Calculates usage percentage from previous and current stats
  /// Calculates CPU usage percentage from two snapshots (raw ticks).
  /// Returns a value between 0.0 and 100.0 with high precision.
  static double calculateCpuPercent(
      int prevIdle, int prevTotal, int currIdle, int currTotal) {
    final totalDelta = (currTotal - prevTotal).toDouble();
    final idleDelta = (currIdle - prevIdle).toDouble();

    if (totalDelta <= 0) {
      return 0.0; // Avoid division by zero or negative delta
    }

    final usageDelta = totalDelta - idleDelta;
    final cpuPct = (usageDelta / totalDelta) * 100.0;

    if (cpuPct < 0.0) return 0.0;
    if (cpuPct > 100.0) return 100.0;

    return cpuPct;
  }

  /// Parses memory (RAM) usage from `free -b`
  /// Returns percentage 0.0-100.0 (High Precision)
  static double parseRam(String output) {
    try {
      final lines = output.trim().split('\n');
      if (lines.length < 2) return 0.0;

      // Header: total used free shared buff/cache available
      // Mem: 16000000 8000000 ... ... ... 7000000
      final parts = lines[1].trim().split(_whiteSpace);
      if (parts.length < 7) return 0.0;

      final total = double.tryParse(parts[1]) ?? 0;
      final available = double.tryParse(parts[6]) ?? 0;

      if (total == 0) return 0.0;
      return ((total - available) / total * 100).clamp(0.0, 100.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// Parses `df -k /` output for Disk usage
  /// Returns map with percentage, used bytes, and total bytes
  static Map<String, dynamic> parseDisk(String output) {
    try {
      // df -k / output looks like:
      // Filesystem     1K-blocks        Used   Available Use% Mounted on
      // /dev/root       30536450    24112345    28125215   8% /

      final lines = output.trim().split('\n');
      if (lines.length < 2) {
        debugPrint('DiskParser: Not enough lines. Output: $output');
        return {'pct': 0.0, 'used': 0, 'total': 0};
      }

      final parts = lines[1].trim().split(_whiteSpace);
      // Expected indices (1K blocks):
      // 0: Filesystem, 1: Total(1K), 2: Used(1K), 3: Avail, 4: Use%, 5: Mount

      if (parts.length >= 3) {
        final total1k = double.tryParse(parts[1]);
        final used1k = double.tryParse(parts[2]);

        if (total1k != null && used1k != null && total1k > 0) {
          final totalBytes = total1k * 1024;
          final usedBytes = used1k * 1024;
          final pct = (used1k / total1k) * 100.0;
          return {
            'pct': pct.clamp(0.0, 100.0),
            'used': usedBytes.toInt(),
            'total': totalBytes.toInt(),
          };
        }
      }

      // Fallback to Use% regex if byte parsing fails
      final RegExp regExp = RegExp(r'\s+(\d+)%');
      final matches = regExp.allMatches(output);
      if (matches.isNotEmpty) {
        for (final match in matches) {
          final val = int.tryParse(match.group(1) ?? '');
          if (val != null) {
            debugPrint('DiskParser: Fallback regex percentage: $val%');
            return {'pct': val.toDouble(), 'used': 0, 'total': 0};
          }
        }
      }

      return {'pct': 0.0, 'used': 0, 'total': 0};
    } catch (e) {
      debugPrint('DiskParser: Exception: $e');
      return {'pct': 0.0, 'used': 0, 'total': 0};
    }
  }

  /// Parses /proc/uptime output (e.g. "23423.45 12312.33")
  static String parseUptime(String output) {
    try {
      final parts = output.trim().split(_whiteSpace);
      if (parts.isEmpty) return 'Unknown';

      // First part is total uptime in seconds
      final seconds = double.tryParse(parts[0])?.toInt() ?? 0;
      if (seconds == 0) return 'Unknown';

      final duration = Duration(seconds: seconds);

      if (duration.inDays > 0) {
        return '${duration.inDays}d ${duration.inHours % 24}h';
      } else if (duration.inHours > 0) {
        return '${duration.inHours}h ${duration.inMinutes % 60}m';
      } else {
        return '${duration.inMinutes}m'; // e.g. "45m"
      }
    } catch (e) {
      debugPrint('UptimeParser: Exception: $e');
      return 'Unknown';
    }
  }

  /// Bulletproof parsing of atomic output
  static Map<String, dynamic> parseAll(String raw,
      {int prevIdle = 0, int prevTotal = 0}) {
    final parts = raw.split('|||');

    if (parts.length < 4) {
      throw FormatException(
          'Incomplete data: Expected 4 parts, got ${parts.length}');
    }

    // 1. CPU - Use new CpuTicks parser
    final currentTicks = CpuTicks.parse(parts[0]);
    final currIdle = currentTicks.idle;
    final currTotal = currentTicks.total;

    double cpuPct = 0.0;
    if (prevTotal != 0 && currTotal > 0) {
      cpuPct = calculateCpuPercent(prevIdle, prevTotal, currIdle, currTotal);
    }

    // 2. RAM
    final ramPct = _safeParseDouble(parts[1], parseRam, 0.0);

    // 3. Disk
    final diskData =
        _safeParseMap(parts[2], parseDisk, {'pct': 0.0, 'used': 0, 'total': 0});
    final diskPct = diskData['pct'] as double;
    final diskUsed = diskData['used'] as int;
    final diskTotal = diskData['total'] as int;

    // 4. Uptime
    final uptime = _safeParseString(parts[3], parseUptime, 'N/A');

    // 5. Metadata (Optional parts 5-8)
    final hostname = parts.length > 4 ? parts[4].trim() : '';

    // IP Address extraction - can be messy if multiple IPs
    String ipAddress = parts.length > 5 ? parts[5].trim() : '';
    if (ipAddress.contains(' ')) {
      ipAddress = ipAddress.split(' ').first;
    }

    // OS Distro Parsing (Robust Regex from /etc/os-release content)
    final rawOsRelease = parts.length > 6 ? parts[6] : '';
    String osDistro = 'Linux';
    if (rawOsRelease.isNotEmpty) {
      // Look for PRETTY_NAME="Ubuntu 22.04 LTS"
      final prettyNameMatch =
          RegExp(r'PRETTY_NAME="([^"]+)"').firstMatch(rawOsRelease);
      if (prettyNameMatch != null) {
        osDistro = prettyNameMatch.group(1) ?? 'Linux';
      } else {
        // Fallback to NAME="Ubuntu"
        final nameMatch = RegExp(r'NAME="([^"]+)"').firstMatch(rawOsRelease);
        if (nameMatch != null) {
          osDistro = nameMatch.group(1) ?? 'Linux';
        }
      }
    }

    final kernelVersion = parts.length > 7 ? parts[7].trim() : '';

    return {
      'cpuPct': cpuPct,
      'ramPct': ramPct,
      'diskPct': diskPct,
      'uptime': uptime,
      'cpuIdle': currIdle,
      'cpuTotal': currTotal,
      'hostname': hostname,
      'ipAddress': ipAddress,
      'osDistro': osDistro,
      'kernelVersion': kernelVersion,
      'diskUsed': diskUsed,
      'diskTotal': diskTotal,
    };
  }

  static double _safeParseDouble(
      String raw, double Function(String) parser, double fallback) {
    try {
      return parser(raw);
    } catch (e) {
      return fallback;
    }
  }

  static String _safeParseString(
      String raw, String Function(String) parser, String fallback) {
    try {
      return parser(raw);
    } catch (e) {
      return fallback;
    }
  }

  static Map<String, dynamic> _safeParseMap(
      String raw,
      Map<String, dynamic> Function(String) parser,
      Map<String, dynamic> fallback) {
    try {
      return parser(raw);
    } catch (e) {
      return fallback;
    }
  }
}
