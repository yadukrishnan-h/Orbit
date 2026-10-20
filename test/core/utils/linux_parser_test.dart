import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/utils/linux_parser.dart';

void main() {
  group('LinuxParser & CpuTicks [QA-001]', () {
    const rawCpuStat = '''
cpu  1000 200 300 8000 500 50 20 10
cpu0 500 100 150 4000 250 25 10 5
cpu1 500 100 150 4000 250 25 10 5
''';

    const rawFreeB = '''
               total        used        free      shared  buff/cache   available
Mem:     16000000000  8000000000  4000000000   100000000  4000000000  8000000000
Swap:     2000000000           0  2000000000
''';

    const rawDfK = '''
Filesystem     1K-blocks      Used Available Use% Mounted on
/dev/sda1      100000000  40000000  60000000  40% /
''';

    const rawUptime = '360000.50 720000.12'; // 360000 seconds = 4 days, 4 hours
    const rawHostname = 'production-node-1';
    const rawIp = '10.0.0.15';
    const rawOs = 'Ubuntu 22.04.4 LTS';
    const rawKernel = '5.15.0-105-generic';
    const rawLscpu = '''
Model name:          AMD EPYC 7763 64-Core Processor
CPU(s):              8
CPU max MHz:         3200.0000
''';

    test('parseAll parses full 9-part Linux metrics output accurately', () {
      final rawCombined = [
        rawCpuStat,
        rawFreeB,
        rawDfK,
        rawUptime,
        rawHostname,
        rawIp,
        rawOs,
        rawKernel,
        rawLscpu,
      ].join('|||');

      // First tick snapshot
      final firstPass = LinuxParser.parseAll(rawCombined);
      expect(firstPass['cpuPct'], 0.0); // No previous ticks
      expect(firstPass['hostname'], 'production-node-1');
      expect(firstPass['ipAddress'], '10.0.0.15');
      expect(firstPass['osDistro'], 'Ubuntu 22.04.4 LTS');
      expect(firstPass['kernelVersion'], '5.15.0-105-generic');
      expect(firstPass['uptime'], '4d 4h');
      expect(firstPass['cpuModel'], 'AMD EPYC 7763 64-Core Processor');
      expect(firstPass['cpuCores'], 8);
      expect(firstPass['cpuSpeed'], '3.20 GHz');

      // RAM
      expect(firstPass['ramPct'], 50.0);
      expect(firstPass['ramTotal'], 16000000000);
      expect(firstPass['ramUsed'], 8000000000);

      // Disk
      expect(firstPass['diskPct'], 40.0);
      expect(firstPass['diskTotal'], 100000000 * 1024);
      expect(firstPass['diskUsed'], 40000000 * 1024);

      // Second snapshot with updated ticks (simulate 50% CPU load)
      // Original ticks: total = 1000+200+300+8000+500+50+20+10 = 10080, idle = 8000+500 = 8500
      // Advance by: delta total = 200, delta idle = 100 => 50% usage
      const rawCpuStat2 = '''
cpu  1100 200 300 8100 500 50 20 10
''';
      final rawCombined2 = [
        rawCpuStat2,
        rawFreeB,
        rawDfK,
        rawUptime,
      ].join('|||');

      final secondPass = LinuxParser.parseAll(
        rawCombined2,
        prevIdle: 8500,
        prevTotal: 10080,
      );
      expect(secondPass['cpuPct'], closeTo(50.0, 0.01));
    });

    test(
      'parseAll throws FormatException when input has fewer than 4 parts',
      () {
        expect(
          () => LinuxParser.parseAll('part1|||part2|||part3'),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test('calculateCpuPercent handles edge cases correctly', () {
      // Zero or negative delta
      expect(LinuxParser.calculateCpuPercent(100, 100, 100, 100), 0.0);
      expect(LinuxParser.calculateCpuPercent(200, 200, 100, 100), 0.0);

      // 100% idle delta -> 0% usage
      expect(LinuxParser.calculateCpuPercent(0, 0, 100, 100), 0.0);

      // 0% idle delta -> 100% usage
      expect(LinuxParser.calculateCpuPercent(0, 0, 0, 100), 100.0);

      // 25% usage
      expect(LinuxParser.calculateCpuPercent(0, 0, 75, 100), 25.0);
    });

    test('parseRam handles fallback when available column is missing', () {
      const oldFree = '''
             total       used       free
Mem:    8000000000 4000000000 4000000000
''';
      final ram = LinuxParser.parseRam(oldFree);
      expect(ram['pct'], 50.0);
      expect(ram['total'], 8000000000);
      expect(ram['used'], 4000000000);
    });

    test('parseDisk handles Use% regex fallback when bytes fail to parse', () {
      const fallbackDf = '''
Filesystem     Mounted on  Use%
none           /           73%
''';
      final disk = LinuxParser.parseDisk(fallbackDf);
      expect(disk['pct'], 73.0);
    });

    test('parseUptime formats days, hours, and minutes correctly', () {
      // 45 minutes = 2700s
      expect(LinuxParser.parseUptime('2700 5400'), '45m');

      // 3 hours, 15 minutes = 11700s
      expect(LinuxParser.parseUptime('11700 23400'), '3h 15m');

      // 2 days, 5 hours = 190800s
      expect(LinuxParser.parseUptime('190800 381600'), '2d 5h');

      // Empty or invalid
      expect(LinuxParser.parseUptime(''), 'Unknown');
      expect(LinuxParser.parseUptime('invalid'), 'Unknown');
    });

    test('parseCpuHardware extracts model, cores, and clock speed', () {
      const cpuInfo = '''
model name : Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz
cpu MHz    : 3800.000
model name : Intel(R) Core(TM) i7-10700K CPU @ 3.80GHz
cpu MHz    : 3800.000
''';
      final hw = LinuxParser.parseCpuHardware(cpuInfo);
      expect(hw['model'], contains('i7-10700K'));
      expect(hw['cores'], 2);
      expect(hw['speed'], '3.80 GHz');
    });
  });
}
