import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:orbit/core/services/host_key_service.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/services/ssh_service.dart';
import 'package:orbit/core/utils/app_logger.dart';
import 'package:orbit/features/files/data/remote_file.dart';

/// Cache entry for directory listings
class _DirectoryCacheEntry {
  final List<RemoteFile> files;
  final DateTime timestamp;

  _DirectoryCacheEntry(this.files, this.timestamp);

  bool get isStale {
    // Cache is valid for 30 seconds
    return DateTime.now().difference(timestamp).inSeconds > 30;
  }
}

/// SFTP service with performance optimizations and hardened shell execution [SEC-001, SEC-014].
class SftpService {
  final HostKeyService? _hostKeyService;
  final SecureStorageService? _secureStorage;
  SSHClient? _sshClient;
  SftpClient? _sftpClient;
  bool _isConnecting = false;
  String? _lastHost;
  int? _lastPort;
  String? _lastUsername;

  // LRU Cache for directory listings (max 50 entries)
  final _directoryCache = <String, _DirectoryCacheEntry>{};
  static const int _maxCacheSize = 50;

  // Cache for file metadata
  final _fileMetadataCache = <String, RemoteFile>{};
  static const int _maxMetadataCacheSize = 100;

  SftpService([this._hostKeyService, this._secureStorage]);

  /// Escapes an argument for safe POSIX shell interpolation [SEC-001].
  ///
  /// Rejects null bytes and wraps the argument in single quotes, escaping
  /// any embedded single quotes using `'\''`.
  static String escapePosixShellArg(String arg) {
    if (arg.contains('\u0000')) {
      throw ArgumentError('POSIX shell argument cannot contain null bytes');
    }
    return "'${arg.replaceAll("'", r"'\''")}'";
  }

  /// Connect to SSH server with connection reuse and key/password authentication [SEC-014].
  Future<void> connect({
    required String host,
    required int port,
    required String username,
    String? password,
    String? serverId,
    String? privateKey,
  }) async {
    // Check if already connected to the same server
    if (_sshClient != null &&
        _sftpClient != null &&
        _lastHost == host &&
        _lastPort == port &&
        _lastUsername == username &&
        _sshClient!.isClosed == false) {
      AppLogger.debug('SFTP: Reusing existing connection');
      return;
    }

    if (_isConnecting) {
      AppLogger.debug('SFTP: Connection in progress');
      throw Exception('Connection already in progress');
    }

    _isConnecting = true;
    try {
      AppLogger.info('SFTP: Connecting to $host:$port as $username...');

      // Disconnect existing connection if different server
      if (_sshClient != null) {
        await disconnect();
      }

      var effectivePassword = password;
      var effectivePrivateKey = privateKey;

      // JIT credential lookup if serverId and secureStorage are available
      if (serverId != null && serverId.isNotEmpty && _secureStorage != null) {
        final secPass = await _secureStorage.readCredential(
          serverId,
          'password',
        );
        final secKey = await _secureStorage.readCredential(
          serverId,
          'privateKey',
        );
        if (secPass != null && secPass.isNotEmpty) effectivePassword = secPass;
        if (secKey != null && secKey.isNotEmpty) effectivePrivateKey = secKey;
      }

      final normalizedKey = effectivePrivateKey != null
          ? SshService.normalizePem(effectivePrivateKey)
          : null;

      final String? validPassphrase =
          (effectivePassword != null && effectivePassword.trim().isNotEmpty)
          ? effectivePassword
          : null;

      SSHSocket? socket;
      try {
        socket = await SSHSocket.connect(
          host,
          port,
          timeout: const Duration(seconds: 10),
        );

        _sshClient = SSHClient(
          socket,
          username: username,
          onPasswordRequest: () => effectivePassword ?? '',
          identities: normalizedKey != null && normalizedKey.trim().isNotEmpty
              ? SSHKeyPair.fromPem(normalizedKey, validPassphrase)
              : null,
          onVerifyHostKey:
              (serverId != null &&
                  serverId.isNotEmpty &&
                  _hostKeyService != null)
              ? (type, fingerprint) =>
                    _hostKeyService.verifyHostKey(serverId, type, fingerprint)
              : null,
        );

        // Authenticate
        await _sshClient!.authenticated.timeout(
          const Duration(seconds: 10),
          onTimeout: () =>
              throw TimeoutException('SFTP authentication timed out'),
        );

        // Start the native SFTP subsystem
        _sftpClient = await _sshClient!.sftp().timeout(
          const Duration(seconds: 15),
          onTimeout: () =>
              throw TimeoutException('SFTP subsystem connection timed out'),
        );

        _lastHost = host;
        _lastPort = port;
        _lastUsername = username;

        // Clear cache when connecting to new server
        _clearCache();

        AppLogger.info('SFTP: Connected successfully');
      } catch (e) {
        if (_sshClient == null) {
          socket?.close();
        }
        AppLogger.error('SFTP: Connection failed: $e');
        await disconnect();
        throw Exception('Failed to connect to server: $e');
      }
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect from server and clear all caches
  Future<void> disconnect() async {
    AppLogger.debug('SFTP: Disconnecting...');
    final sftp = _sftpClient;
    final ssh = _sshClient;
    _sftpClient = null;
    _sshClient = null;
    _lastHost = null;
    _lastPort = null;
    _lastUsername = null;
    _clearCache();

    try {
      sftp?.close();
      ssh?.close();
    } catch (e) {
      AppLogger.error('SFTP: Error during disconnect teardown: $e');
    } finally {
      AppLogger.debug('SFTP: Disconnected');
    }
  }

  /// Clear all caches
  void _clearCache() {
    _directoryCache.clear();
    _fileMetadataCache.clear();
    AppLogger.debug('SFTP: Cache cleared');
  }

  /// Check if connected
  bool get isConnected => _sshClient != null && _sftpClient != null;

  /// List files in directory with caching
  Future<List<RemoteFile>> listDir(String path) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    // Check cache first
    final cachedEntry = _directoryCache[path];
    if (cachedEntry != null && !cachedEntry.isStale) {
      AppLogger.debug('SFTP: Cache hit for $path');
      return List.unmodifiable(cachedEntry.files);
    }

    try {
      AppLogger.debug('SFTP: Listing directory: $path');

      final items = await _sftpClient!
          .listdir(path)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw TimeoutException('Directory listing timed out'),
          );
      final files = <RemoteFile>[];

      for (final item in items) {
        if (item.filename == '.' || item.filename == '..') {
          continue;
        }

        final file = _convertSftpName(item, path);
        files.add(file);
        // Cache individual file metadata
        _updateFileMetadataCache(file);
      }

      AppLogger.debug(
        'SFTP: Successfully parsed ${files.length} files/directories',
      );

      // Sort: directories first, then files, alphabetically
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      _updateCache(path, files);
      return files;
    } catch (e) {
      AppLogger.error('SFTP: Failed to list directory: $e');
      throw Exception('Failed to list directory: $e');
    }
  }

  /// Convert dartssh2 SftpName to RemoteFile
  RemoteFile _convertSftpName(SftpName item, String dirPath) {
    bool isDir = false;
    bool isLink = false;
    int size = item.attr.size ?? 0;
    // 'modifyTime' is the correct property name in dartssh2 for SftpFileAttrs
    DateTime modified = DateTime.fromMillisecondsSinceEpoch(
      (item.attr.modifyTime ?? 0) * 1000,
    );
    String permissions = '';

    // Parse permissions if available in longname (e.g., "drwxr-xr-x 2 user group ...")
    final longname = item.longname;
    if (longname.isNotEmpty) {
      final parts = longname.trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) {
        final permStr = parts[0];
        isDir = permStr.startsWith('d');
        isLink = permStr.startsWith('l');
        if (permStr.length > 1) {
          permissions = permStr.substring(1);
        }
      }
    } else {
      // Fallback using attributes if longname is missing
      isDir = item.attr.isDirectory;
      isLink = item.attr.isSymbolicLink;
      if (item.attr.mode != null) {
        // Generate basic rwx string from mode integer
        permissions = _permissionsToString(item.attr.mode!.value);
      }
    }

    return RemoteFile(
      name: item.filename,
      path: dirPath == '/' ? '/${item.filename}' : '$dirPath/${item.filename}',
      isDirectory: isDir,
      size: size,
      modified: modified,
      permissions: permissions,
      owner: item.attr.userID?.toString() ?? '',
      group: item.attr.groupID?.toString() ?? '',
      isLink: isLink,
    );
  }

  String _permissionsToString(int mode) {
    final String user =
        '${(mode & 256) != 0 ? 'r' : '-'}${(mode & 128) != 0 ? 'w' : '-'}${(mode & 64) != 0 ? 'x' : '-'}';
    final String group =
        '${(mode & 32) != 0 ? 'r' : '-'}${(mode & 16) != 0 ? 'w' : '-'}${(mode & 8) != 0 ? 'x' : '-'}';
    final String other =
        '${(mode & 4) != 0 ? 'r' : '-'}${(mode & 2) != 0 ? 'w' : '-'}${(mode & 1) != 0 ? 'x' : '-'}';
    return '$user$group$other';
  }

  /// Update directory cache
  void _updateCache(String path, List<RemoteFile> files) {
    // Remove old entry if exists
    _directoryCache.remove(path);
    // Add new entry
    _directoryCache[path] = _DirectoryCacheEntry(files, DateTime.now());
    // Trim cache
    while (_directoryCache.length > _maxCacheSize) {
      _directoryCache.remove(_directoryCache.keys.first);
    }
  }

  /// Update file metadata cache
  void _updateFileMetadataCache(RemoteFile file) {
    _fileMetadataCache[file.path] = file;
    while (_fileMetadataCache.length > _maxMetadataCacheSize) {
      _fileMetadataCache.remove(_fileMetadataCache.keys.first);
    }
  }

  /// Invalidate cache for specific path
  void invalidateCache(String path) {
    _directoryCache.remove(path);
    // Also invalidate parent directory
    final parentIndex = path.lastIndexOf('/');
    if (parentIndex > 0) {
      final parentPath = path.substring(0, parentIndex);
      _directoryCache.remove(parentPath.isEmpty ? '/' : parentPath);
    } else {
      _directoryCache.remove('/');
    }
  }

  /// Downloads a remote file by streaming chunks directly to disk using [IOSink],
  /// preventing Out-Of-Memory (OOM) crashes on large files.
  /// If [destinationPath] is omitted, saves to a temporary directory file.
  Future<File> downloadFile(
    String remotePath, {
    String? destinationPath,
    void Function(int received, int total)? onProgress,
  }) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    File? outFile;
    IOSink? sink;
    try {
      AppLogger.debug('SFTP: Streaming download for file: $remotePath');

      final file = await _sftpClient!.open(remotePath);
      final attrs = await file.stat();
      final totalSize = attrs.size ?? 0;

      if (destinationPath != null) {
        outFile = File(destinationPath);
        final parent = outFile.parent;
        if (!parent.existsSync()) {
          parent.createSync(recursive: true);
        }
      } else {
        final tempDir = await getTemporaryDirectory();
        final sanitizedFileName = remotePath.split('/').last;
        outFile = File('${tempDir.path}/$sanitizedFileName');
      }

      sink = outFile.openWrite();
      int receivedBytes = 0;

      await for (final chunk in file.read()) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        onProgress?.call(receivedBytes, totalSize);
      }

      await sink.flush();
      AppLogger.debug('SFTP: Streamed $receivedBytes bytes to ${outFile.path}');
      return outFile;
    } catch (e) {
      AppLogger.error('SFTP: Failed to download file: $e');
      if (outFile != null && outFile.existsSync()) {
        try {
          await outFile.delete();
        } catch (_) {}
      }
      throw Exception('Failed to download file: $e');
    } finally {
      await sink?.close();
    }
  }

  /// Upload file with progress callback support
  Future<void> uploadFile(
    String remotePath,
    Uint8List data, {
    void Function(int, int)? onProgress,
  }) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      AppLogger.debug(
        'SFTP: Uploading file to: $remotePath (${data.length} bytes)',
      );

      // Create parent directory if needed
      final parentDir = remotePath.substring(0, remotePath.lastIndexOf('/'));
      if (parentDir.isNotEmpty && parentDir != '/') {
        // Attempt to create parent dir. Ignore error if it already exists.
        try {
          await createDirectory(parentDir);
        } catch (_) {}
      }

      final file = await _sftpClient!.open(
        remotePath,
        mode:
            SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );

      // Upload in chunks
      const chunkSize = 32 * 1024; // 32KB chunks
      int offset = 0;

      while (offset < data.length) {
        final end = (offset + chunkSize < data.length)
            ? offset + chunkSize
            : data.length;
        final chunk = data.sublist(offset, end);
        await file.writeBytes(chunk);
        offset = end;
        onProgress?.call(offset, data.length);
      }

      await file.close();

      // Invalidate cache for parent directory
      invalidateCache(remotePath);

      AppLogger.debug('SFTP: Upload complete');
    } catch (e) {
      AppLogger.error('SFTP: Failed to upload file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload file by streaming chunks directly to prevent Out-Of-Memory (OOM)
  /// crashes on large files [UI-004].
  Future<void> uploadFileStream(
    String remotePath,
    Stream<List<int>> stream,
    int totalBytes, {
    void Function(int received, int total)? onProgress,
  }) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      AppLogger.debug(
        'SFTP: Streaming upload to: $remotePath ($totalBytes bytes)',
      );

      // Create parent directory if needed
      final parentDir = remotePath.substring(0, remotePath.lastIndexOf('/'));
      if (parentDir.isNotEmpty && parentDir != '/') {
        try {
          await createDirectory(parentDir);
        } catch (_) {}
      }

      final file = await _sftpClient!.open(
        remotePath,
        mode:
            SftpFileOpenMode.create |
            SftpFileOpenMode.write |
            SftpFileOpenMode.truncate,
      );

      final uint8Stream = stream.map<Uint8List>(
        (chunk) => chunk is Uint8List ? chunk : Uint8List.fromList(chunk),
      );

      final writer = file.write(
        uint8Stream,
        onProgress: (sent) {
          onProgress?.call(sent, totalBytes);
        },
      );

      await writer.done;
      await file.close();

      invalidateCache(remotePath);
      AppLogger.debug('SFTP: Streaming upload complete');
    } catch (e) {
      AppLogger.error('SFTP: Failed to stream upload file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Create directory
  Future<void> createDirectory(String path) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      AppLogger.debug('SFTP: Creating directory: $path');
      // dartssh2 sftp doesn't have a direct `mkdir -p`. We try recreating the exact directory
      await _sftpClient!.mkdir(path);

      // Invalidate parent directory cache
      invalidateCache(path);

      AppLogger.debug('SFTP: Directory created');
    } catch (e) {
      // DartSSH2 throws if directory exists. Let's assume it failed if it wasn't a pre-existing error.
      AppLogger.warning(
        'SFTP: Warning - Failed to create directory (might exist): $e',
      );
      // No rethrow here so that upload parent folder creation doesn't crash if it exists
    }
  }

  /// Delete file
  Future<void> deleteFile(String path) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      AppLogger.debug('SFTP: Deleting file: $path');
      await _sftpClient!.remove(path);

      // Invalidate cache
      invalidateCache(path);

      AppLogger.debug('SFTP: File deleted');
    } catch (e) {
      AppLogger.error('SFTP: Failed to delete file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete directory safely avoiding shell injection [SEC-001].
  Future<void> deleteDirectory(String path) async {
    final trimmed = path.trim();
    if (trimmed.isEmpty || trimmed == '.' || trimmed == '/' || trimmed == '~') {
      throw ArgumentError(
        'Refusing to delete unsafe or root directory path: $path',
      );
    }

    if (_sftpClient == null || _sshClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      final safePath = escapePosixShellArg(trimmed);
      AppLogger.debug('SFTP: Deleting directory: $safePath');
      await _sshClient!.run('rm -rf -- $safePath');

      // Invalidate cache
      invalidateCache(path);

      AppLogger.debug('SFTP: Directory deleted');
    } catch (e) {
      AppLogger.error('SFTP: Failed to delete directory: $e');
      throw Exception('Failed to delete directory: $e');
    }
  }

  /// Rename file/directory
  Future<void> rename(String oldPath, String newPath) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      AppLogger.debug('SFTP: Renaming: $oldPath -> $newPath');
      await _sftpClient!.rename(oldPath, newPath);

      // Invalidate both old and new parent directories
      invalidateCache(oldPath);
      invalidateCache(newPath);

      AppLogger.debug('SFTP: Rename complete');
    } catch (e) {
      AppLogger.error('SFTP: Failed to rename: $e');
      throw Exception('Failed to rename: $e');
    }
  }

  /// Get file info (stat)
  Future<RemoteFile?> statFile(String path) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    // Check metadata cache first
    final cached = _fileMetadataCache[path];
    if (cached != null) {
      return cached;
    }

    try {
      AppLogger.debug('SFTP: Getting file info: $path');

      final attr = await _sftpClient!.stat(path);
      final filename = path.split('/').last;

      final isDir = attr.isDirectory;
      final isLink = attr.isSymbolicLink;

      final file = RemoteFile(
        name: filename,
        path: path,
        isDirectory: isDir,
        size: attr.size ?? 0,
        modified: DateTime.fromMillisecondsSinceEpoch(
          (attr.modifyTime ?? 0) * 1000,
        ),
        permissions: attr.mode != null
            ? _permissionsToString(attr.mode!.value)
            : '',
        owner: attr.userID?.toString() ?? '',
        group: attr.groupID?.toString() ?? '',
        isLink: isLink,
      );

      _updateFileMetadataCache(file);
      return file;
    } catch (e) {
      AppLogger.error('SFTP: Failed to get file info: $e');
      return null;
    }
  }

  /// Check if file exists
  Future<bool> fileExists(String path) async {
    try {
      final stat = await statFile(path);
      return stat != null;
    } catch (_) {
      return false;
    }
  }

  /// Get disk usage info for path [SEC-001, LOGIC-005]
  Future<Map<String, int>> getDiskUsage(String path) async {
    if (_sshClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      final trimmed = path.trim();
      final safePath = escapePosixShellArg(trimmed.isEmpty ? '.' : trimmed);
      final result = await _sshClient!.run('df -B1 -- $safePath | tail -1');
      final output = utf8.decode(result, allowMalformed: true).trim();
      final parts = output.split(RegExp(r'\s+'));

      if (parts.length >= 4) {
        return {
          'total': int.tryParse(parts[1]) ?? 0,
          'used': int.tryParse(parts[2]) ?? 0,
          'available': int.tryParse(parts[3]) ?? 0,
        };
      }

      return {'total': 0, 'used': 0, 'available': 0};
    } catch (e) {
      AppLogger.error('SFTP: Failed to get disk usage: $e');
      return {'total': 0, 'used': 0, 'available': 0};
    }
  }
}
