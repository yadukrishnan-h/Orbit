import 'dart:async';
// import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
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

/// SFTP service with performance optimizations
class SftpService {
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

  SftpService();

  /// Connect to SSH server with connection reuse
  Future<void> connect({
    required String host,
    required int port,
    required String username,
    required String password,
  }) async {
    // Check if already connected to the same server
    if (_sshClient != null &&
        _sftpClient != null &&
        _lastHost == host &&
        _lastPort == port &&
        _lastUsername == username &&
        _sshClient!.isClosed == false) {
      debugPrint('SFTP: Reusing existing connection');
      return;
    }

    if (_isConnecting) {
      debugPrint('SFTP: Connection in progress');
      throw Exception('Connection already in progress');
    }

    _isConnecting = true;
    try {
      debugPrint('SFTP: Connecting to $host:$port as $username...');

      // Disconnect existing connection if different server
      if (_sshClient != null) {
        await disconnect();
      }

      final socket = await SSHSocket.connect(host, port).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timed out'),
      );

      _sshClient = SSHClient(
        socket,
        username: username,
        onPasswordRequest: () => password,
      );

      // Start the native SFTP subsystem
      _sftpClient = await _sshClient!.sftp();

      _lastHost = host;
      _lastPort = port;
      _lastUsername = username;

      // Clear cache when connecting to new server
      _clearCache();

      debugPrint('SFTP: Connected successfully');
    } catch (e) {
      debugPrint('SFTP: Connection failed: $e');
      await disconnect();
      throw Exception('Failed to connect to server: $e');
    } finally {
      _isConnecting = false;
    }
  }

  /// Disconnect from server and clear all caches
  Future<void> disconnect() async {
    debugPrint('SFTP: Disconnecting...');
    _sftpClient?.close();
    _sshClient?.close();
    _sftpClient = null;
    _sshClient = null;
    _lastHost = null;
    _lastPort = null;
    _lastUsername = null;
    _clearCache();
    debugPrint('SFTP: Disconnected');
  }

  /// Clear all caches
  void _clearCache() {
    _directoryCache.clear();
    _fileMetadataCache.clear();
    debugPrint('SFTP: Cache cleared');
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
      debugPrint('SFTP: Cache hit for $path');
      return List.unmodifiable(cachedEntry.files);
    }

    try {
      debugPrint('SFTP: Listing directory: $path');

      final items = await _sftpClient!.listdir(path);
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

      debugPrint('SFTP: Successfully parsed ${files.length} files/directories');

      // Sort: directories first, then files, alphabetically
      files.sort((a, b) {
        if (a.isDirectory && !b.isDirectory) return -1;
        if (!a.isDirectory && b.isDirectory) return 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      _updateCache(path, files);
      return files;
    } catch (e) {
      debugPrint('SFTP: Failed to list directory: $e');
      throw Exception('Failed to list directory: $e');
    }
  }

  /// Convert dartssh2 SftpName to RemoteFile
  RemoteFile _convertSftpName(SftpName item, String dirPath) {
    bool isDir = false;
    bool isLink = false;
    int size = item.attr.size ?? 0;
    // 'modifyTime' is the correct property name in dartssh2 for SftpFileAttrs
    DateTime modified =
        DateTime.fromMillisecondsSinceEpoch((item.attr.modifyTime ?? 0) * 1000);
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

  /// Download file with progress callback support
  Future<Uint8List> downloadFile(String path,
      {void Function(int, int)? onProgress}) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      debugPrint('SFTP: Downloading file: $path');

      final file = await _sftpClient!.open(path);
      final attrs = await file.stat();
      final totalSize = attrs.size ?? 0;

      final data = <int>[];
      await for (final chunk in file.read()) {
        data.addAll(chunk);
        onProgress?.call(data.length, totalSize);
      }

      debugPrint('SFTP: Downloaded ${data.length} bytes');
      return Uint8List.fromList(data);
    } catch (e) {
      debugPrint('SFTP: Failed to download file: $e');
      throw Exception('Failed to download file: $e');
    }
  }

  /// Upload file with progress callback support
  Future<void> uploadFile(String remotePath, Uint8List data,
      {void Function(int, int)? onProgress}) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      debugPrint('SFTP: Uploading file to: $remotePath (${data.length} bytes)');

      // Create parent directory if needed
      final parentDir = remotePath.substring(0, remotePath.lastIndexOf('/'));
      if (parentDir.isNotEmpty && parentDir != '/') {
        // Attempt to create parent dir. Ignore error if it already exists.
        try {
          await createDirectory(parentDir);
        } catch (_) {}
      }

      final file = await _sftpClient!.open(remotePath,
          mode: SftpFileOpenMode.create |
              SftpFileOpenMode.write |
              SftpFileOpenMode.truncate);

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

      debugPrint('SFTP: Upload complete');
    } catch (e) {
      debugPrint('SFTP: Failed to upload file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Create directory
  Future<void> createDirectory(String path) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      debugPrint('SFTP: Creating directory: $path');
      // dartssh2 sftp doesn't have a direct `mkdir -p`. We try recreating the exact directory
      await _sftpClient!.mkdir(path);

      // Invalidate parent directory cache
      invalidateCache(path);

      debugPrint('SFTP: Directory created');
    } catch (e) {
      // DartSSH2 throws if directory exists. Let's assume it failed if it wasn't a pre-existing error.
      debugPrint(
          'SFTP: Warning - Failed to create directory (might exist): $e');
      // No rethrow here so that upload parent folder creation doesn't crash if it exists
    }
  }

  /// Delete file
  Future<void> deleteFile(String path) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      debugPrint('SFTP: Deleting file: $path');
      await _sftpClient!.remove(path);

      // Invalidate cache
      invalidateCache(path);

      debugPrint('SFTP: File deleted');
    } catch (e) {
      debugPrint('SFTP: Failed to delete file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete directory
  Future<void> deleteDirectory(String path) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      // Currently `dartssh2` native `_sftpClient!.rmdir` requires the directory to be empty.
      debugPrint('SFTP: Deleting directory: $path');
      await _sshClient!
          .run('rm -rf "$path"'); // Fallback to rm -rf for recursive deletion

      // Invalidate cache
      invalidateCache(path);

      debugPrint('SFTP: Directory deleted');
    } catch (e) {
      debugPrint('SFTP: Failed to delete directory: $e');
      throw Exception('Failed to delete directory: $e');
    }
  }

  /// Rename file/directory
  Future<void> rename(String oldPath, String newPath) async {
    if (_sftpClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      debugPrint('SFTP: Renaming: $oldPath -> $newPath');
      await _sftpClient!.rename(oldPath, newPath);

      // Invalidate both old and new parent directories
      invalidateCache(oldPath);
      invalidateCache(newPath);

      debugPrint('SFTP: Rename complete');
    } catch (e) {
      debugPrint('SFTP: Failed to rename: $e');
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
      debugPrint('SFTP: Getting file info: $path');

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
              (attr.modifyTime ?? 0) * 1000),
          permissions:
              attr.mode != null ? _permissionsToString(attr.mode!.value) : '',
          owner: attr.userID?.toString() ?? '',
          group: attr.groupID?.toString() ?? '',
          isLink: isLink);

      _updateFileMetadataCache(file);
      return file;
    } catch (e) {
      debugPrint('SFTP: Failed to get file info: $e');
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

  /// Get disk usage info for path
  Future<Map<String, int>> getDiskUsage(String path) async {
    if (_sshClient == null) {
      throw Exception('Not connected to server');
    }

    try {
      // Native SFTP client doesn't have disk usage out of the box (SFTP v3), so we still run df command over SSH
      final result = await _sshClient!.run('df -B1 "$path" | tail -1');
      final output = String.fromCharCodes(result).trim();
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
      debugPrint('SFTP: Failed to get disk usage: $e');
      return {'total': 0, 'used': 0, 'available': 0};
    }
  }
}
