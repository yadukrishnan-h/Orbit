import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/services/sftp_service.dart';
import 'package:orbit/features/files/data/remote_file.dart';
import 'package:orbit/features/files/presentation/widgets/remote_file_item.dart';

/// Provider for SFTP service instance
final sftpServiceProvider = Provider<SftpService>((ref) {
  return SftpService();
});

/// Provider for file browser state
final fileBrowserStateProvider =
    StateNotifierProvider<FileBrowserNotifier, FileBrowserState>((ref) {
  return FileBrowserNotifier(
    sftpService: ref.watch(sftpServiceProvider),
  );
});

/// File browser state
class FileBrowserState {
  final bool isConnected;
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
    bool? isLoading,
    bool? isNavigating,
    String? navigatingToPath,
    bool? isMultiSelectMode,
    Set<String>? selectedFiles,
    List<RemoteFile>? files,
    String? currentPath,
    String? error,
    Server? server,
    ViewMode? viewMode,
    Map<String, int>? diskUsage,
  }) {
    return FileBrowserState(
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      isNavigating: isNavigating ?? this.isNavigating,
      navigatingToPath: navigatingToPath ?? this.navigatingToPath,
      isMultiSelectMode: isMultiSelectMode ?? this.isMultiSelectMode,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      files: files ?? this.files,
      currentPath: currentPath ?? this.currentPath,
      error: error ?? this.error,
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

  FileBrowserNotifier({
    required SftpService sftpService,
  })  : _sftpService = sftpService,
        super(FileBrowserState());

  /// Connect to server
  Future<void> connectToServer(Server server) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _sftpService.connect(
        host: server.hostname,
        port: server.port,
        username: server.username,
        password: server.password,
      );

      state = state.copyWith(
        isConnected: true,
        server: server,
        isLoading: false,
      );

      // Load root directory and disk usage
      await loadDirectory('/');
      await _loadDiskUsage('/');
    } catch (e) {
      state = state.copyWith(
        isConnected: false,
        isLoading: false,
        error: e.toString(),
      );
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
      state =
          state.copyWith(error: 'Not connected to server', isNavigating: false);
      return;
    }

    debugPrint(
        'FileBrowser: Loading directory: $path (isNavigation: $isNavigation)');

    state = state.copyWith(
      isLoading: isNavigation,
      isNavigating: isNavigation,
      navigatingToPath: isNavigation ? path : null,
      error: null,
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
        navigatingToPath: null,
        selectedFiles: {},
        isMultiSelectMode: false,
      );

      // Load disk usage for current path
      await _loadDiskUsage(path);
    } catch (e) {
      debugPrint('FileBrowser: Error loading directory: $e');
      state = state.copyWith(
        isLoading: false,
        isNavigating: false,
        navigatingToPath: null,
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
    await loadDirectory(parentPath.isEmpty ? '/' : parentPath,
        isNavigation: true);
  }

  /// Create new directory
  Future<void> createDirectory(String name) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final path =
        state.currentPath == '/' ? '/$name' : '${state.currentPath}/$name';

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

    state = state.copyWith(
      selectedFiles: {},
      isMultiSelectMode: false,
    );

    await refresh();
  }

  /// Download file
  Future<Uint8List> downloadFile(RemoteFile file) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    return await _sftpService.downloadFile(file.path);
  }

  /// Download multiple files (returns map of filename to bytes)
  Future<Map<String, Uint8List>> downloadMultipleFiles(
      List<RemoteFile> files) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final results = <String, Uint8List>{};
    for (final file in files) {
      if (!file.isDirectory) {
        results[file.name] = await _sftpService.downloadFile(file.path);
      }
    }
    return results;
  }

  /// Upload file
  Future<void> uploadFile(String name, Uint8List data) async {
    if (!_sftpService.isConnected) {
      throw Exception('Not connected to server');
    }

    final path =
        state.currentPath == '/' ? '/$name' : '${state.currentPath}/$name';

    await _sftpService.uploadFile(path, data);
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
    state = FileBrowserState();
  }

  /// Refresh current directory
  Future<void> refresh() async {
    await loadDirectory(state.currentPath);
  }
}
