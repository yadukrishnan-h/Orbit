import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/services/host_key_service.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/services/sftp_service.dart';
import 'package:orbit/features/files/data/remote_file.dart';
import 'package:orbit/features/files/presentation/widgets/remote_file_item.dart';

/// Provider for SFTP service instance
final sftpServiceProvider = Provider<SftpService>((ref) {
  final hostKeyService = ref.watch(hostKeyServiceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return SftpService(hostKeyService, secureStorage);
});

/// Provider for file browser state
final fileBrowserStateProvider =
    StateNotifierProvider<FileBrowserNotifier, FileBrowserState>((ref) {
      return FileBrowserNotifier(
        sftpService: ref.watch(sftpServiceProvider),
        ref: ref,
      );
    });

/// File browser state
class FileBrowserState {
  final bool isConnected;
  final bool isConnecting;
  final bool isLoading;
  final bool isNavigating;
  final String? navigatingToPath;
  final bool isMultiSelectMode;
  final Set<String> selectedFiles;
  final List<RemoteFile> files;
  final String currentPath;
  final String? error;
  final Server? server;
  final ViewMode viewMode;
  final Map<String, int>? diskUsage;

  FileBrowserState({
    this.isConnected = false,
    this.isConnecting = false,
    this.isLoading = false,
    this.isNavigating = false,
    this.navigatingToPath,
    this.isMultiSelectMode = false,
    this.selectedFiles = const {},
    this.files = const [],
    this.currentPath = '/',
    this.error,
    this.server,
    this.viewMode = ViewMode.list,
    this.diskUsage,
  });

  FileBrowserState copyWith({
    bool? isConnected,
    bool? isConnecting,
    bool? isLoading,
    bool? isNavigating,
    String? navigatingToPath,
    bool clearNavigatingToPath = false,
    bool? isMultiSelectMode,
    Set<String>? selectedFiles,
    List<RemoteFile>? files,
    String? currentPath,
    String? error,
    bool clearError = false,
    Server? server,
    ViewMode? viewMode,
    Map<String, int>? diskUsage,
  }) {
    return FileBrowserState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      isLoading: isLoading ?? this.isLoading,
      isNavigating: isNavigating ?? this.isNavigating,
      navigatingToPath: clearNavigatingToPath
          ? null
          : (navigatingToPath ?? this.navigatingToPath),
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      files: files ?? this.files,
      currentPath: currentPath ?? this.currentPath,
      error: clearError ? null : (error ?? this.error),
      server: server ?? this.server,
      viewMode: viewMode ?? this.viewMode,
      diskUsage: diskUsage ?? this.diskUsage,
    );
  }

  /// Get list of selected file objects
  List<RemoteFile> get selectedFileObjects {
    return files.where((f) => selectedFiles.contains(f.path)).toList();
  }
}

/// File browser notifier with enhanced features
class FileBrowserNotifier extends StateNotifier<FileBrowserState> {
  final SftpService _sftpService;
  final Ref? _ref;

  FileBrowserNotifier({required SftpService sftpService, Ref? ref})
    : _sftpService = sftpService,
      _ref = ref,
      super(FileBrowserState()) {
    // Clean up active SFTP session if the current server is deleted [LOGIC-008]
    _ref?.listen<AsyncValue<List<Server>>>(serverListStreamProvider, (
      prev,
      next,
    ) {
      final serverId = state.server?.id;
      if (serverId != null) {
        final servers = next.asData?.value;
        if (servers != null && !servers.any((s) => s.id == serverId)) {
          disconnect();
        }
      }
    });
  }

  /// Connect to server
  Future<void> connectToServer(Server server) async {
    state = state.copyWith(isConnecting: true, clearError: true);

    try {
      await _sftpService.connect(
        host: server.hostname,
        port: server.port,
        username: server.username,
        password: server.password,
        serverId: server.id,
        privateKey: server.privateKey,
      );

      state = state.copyWith(
        isConnected: true,
        isConnecting: false,
        server: server,
        clearError: true,
      );

      // Load root directory and disk usage
      await loadDirectory('/');
      await _loadDiskUsage('/');
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        error: e.toString(),
      );
    }
  }

  /// Connect to server and fetch initial directory (throws exceptions for UI feedback)
  Future<void> connectAndFetchInitialDirectory(Server server) async {
    state = state.copyWith(isConnecting: true, clearError: true);

    try {
      await _sftpService.connect(
        host: server.hostname,
        port: server.port,
        username: server.username,
        password: server.password,
        serverId: server.id,
        privateKey: server.privateKey,
      );

      state = state.copyWith(
        isConnected: true,
        isConnecting: false,
        server: server,
      );

      // Load root directory manually to throw on failure
      final files = await _sftpService.listDir('/');

      state = state.copyWith(
        files: files,
        currentPath: '/',
        isLoading: false,
        isNavigating: false,
        clearNavigatingToPath: true,
        selectedFiles: {},
        isMultiSelectMode: false,
        clearError: true,
      );

      await _loadDiskUsage('/');
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isConnecting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Load disk usage info
  Future<void> _loadDiskUsage(String path) async {
    try {
      final usage = await _sftpService.getDiskUsage(path);
      state = state.copyWith(diskUsage: usage);
    } catch (_) {
      // Ignore disk usage errors
    }
  }

  /// Load directory contents
  Future<void> loadDirectory(String path, {bool isNavigation = false}) async {
    if (!_sftpService.isConnected) {
      debugPrint('FileBrowser: Not connected to server');
      state = state.copyWith(
        error: 'Not connected to server',
        isNavigating: false,
        clearNavigatingToPath: true,
      );
      return;
    }

    debugPrint(
      'FileBrowser: Loading directory: $path (isNavigation: $isNavigation)',
    );

    state = state.copyWith(
      isLoading: true,
      isNavigating: isNavigation,
      navigatingToPath: isNavigation ? path : null,
      clearNavigatingToPath: !isNavigation,
      clearError: true,
    );

    try {
      debugPrint('FileBrowser: Calling _sftpService.listDir($path)');
      final files = await _sftpService.listDir(path);
      debugPrint('FileBrowser: Received ${files.length} files');

      state = state.copyWith(
        files: files,
        currentPath: path,
        isLoading: false,
        isNavigating: false,
        clearNavigatingToPath: true,
        selectedFiles: {},
        isMultiSelectMode: false,
        clearError: true,
      );

      // Load disk usage for current path
      await _loadDiskUsage(path);
    } catch (e) {
      debugPrint('FileBrowser: Error loading directory: $e');
      state = state.copyWith(
        isLoading: false,
        isNavigating: false,
        clearNavigatingToPath: true,
        error: e.toString(),
      );
    }
  }

  /// Navigate to subdirectory with loading state
  Future<void> navigateTo(String path, String name) async {
    debugPrint('FileBrowser: navigateTo called - path: $path, name: $name');
    await loadDirectory(path, isNavigation: true);
  }

  /// Navigate to parent directory
  Future<void> navigateUp() async {
    final currentPath = state.currentPath;
    if (currentPath == '/') return;

    final parentPath = currentPath.substring(0, currentPath.lastIndexOf('/'));
    await loadDirectory(
      parentPath.isEmpty ? '/' : parentPath,
      isNavigation: true,
    );
  }

  /// Create new directory
  Future<void> createDirectory(String name) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final path = state.currentPath == '/'
        ? '/$name'
        : '${state.currentPath}/$name';

    await _sftpService.createDirectory(path);
    await refresh();
  }

  /// Delete single item
  Future<void> deleteItem(RemoteFile file) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    if (file.isDirectory) {
      await _sftpService.deleteDirectory(file.path);
    } else {
      await _sftpService.deleteFile(file.path);
    }

    await refresh();
  }

  /// Delete multiple selected items
  Future<void> deleteSelectedItems() async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    for (final file in state.selectedFileObjects) {
      if (file.isDirectory) {
        await _sftpService.deleteDirectory(file.path);
      } else {
        await _sftpService.deleteFile(file.path);
      }
    }

    state = state.copyWith(selectedFiles: {}, isMultiSelectMode: false);

    await refresh();
  }

  /// Download file to disk
  Future<File> downloadFile(RemoteFile file, {String? destinationPath}) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    return await _sftpService.downloadFile(
      file.path,
      destinationPath: destinationPath,
    );
  }

  /// Download multiple files to disk
  Future<List<File>> downloadMultipleFiles(
    List<RemoteFile> files, {
    String? targetDirectory,
  }) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final results = <File>[];
    for (final file in files) {
      if (!file.isDirectory) {
        final dest = targetDirectory != null
            ? '$targetDirectory/${file.name}'
            : null;
        final downloaded = await _sftpService.downloadFile(
          file.path,
          destinationPath: dest,
        );
        results.add(downloaded);
      }
    }
    return results;
  }

  /// Upload file
  Future<void> uploadFile(String name, Uint8List data) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final path = state.currentPath == '/'
        ? '/$name'
        : '${state.currentPath}/$name';

    await _sftpService.uploadFile(path, data);
    await refresh();
  }

  /// Upload file using a stream to avoid OOM crashes on large files [UI-004]
  Future<void> uploadFileStream(
    String name,
    Stream<List<int>> stream,
    int totalBytes, {
    void Function(int received, int total)? onProgress,
  }) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final path = state.currentPath == '/'
        ? '/$name'
        : '${state.currentPath}/$name';

    await _sftpService.uploadFileStream(
      path,
      stream,
      totalBytes,
      onProgress: onProgress,
    );
    await refresh();
  }

  /// Rename file/directory
  Future<void> renameItem(RemoteFile file, String newName) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final oldPath = file.path;
    final newPath = state.currentPath == '/'
        ? '/$newName'
        : '${state.currentPath}/$newName';

    await _sftpService.rename(oldPath, newPath);
    await refresh();
  }

  /// Toggle multi-select mode
  void toggleMultiSelectMode() {
    state = state.copyWith(
      isMultiSelectMode: !state.isMultiSelectMode,
      selectedFiles: {},
    );
  }

  /// Toggle file selection
  void toggleFileSelection(String path) {
    final selected = Set<String>.from(state.selectedFiles);
    if (selected.contains(path)) {
      selected.remove(path);
    } else {
      selected.add(path);
    }
    state = state.copyWith(selectedFiles: selected);
  }

  /// Select all files
  void selectAll() {
    final allPaths = state.files.map((f) => f.path).toSet();
    state = state.copyWith(selectedFiles: allPaths);
  }

  /// Deselect all files
  void deselectAll() {
    state = state.copyWith(selectedFiles: {});
  }

  /// Toggle view mode
  void toggleViewMode() {
    state = state.copyWith(
      viewMode: state.viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list,
    );
  }

  /// Disconnect from server
  Future<void> disconnect() async {
    await _sftpService.disconnect();
    if (mounted) {
      state = FileBrowserState();
    }
  }

  /// Refresh current directory
  Future<void> refresh() async {
    await loadDirectory(state.currentPath);
  }

  @override
  void dispose() {
    unawaited(_sftpService.disconnect().catchError((_) {}));
    super.dispose();
  }
}
