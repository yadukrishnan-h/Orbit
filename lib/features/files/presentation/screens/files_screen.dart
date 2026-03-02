import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/formatters.dart';
import 'package:orbit/features/files/data/remote_file.dart';
import 'package:orbit/features/files/providers/file_browser_provider.dart';
import 'package:orbit/features/files/presentation/widgets/remote_file_item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/widgets/system_card.dart';

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  bool _showServerSelector = true;
  final _breadcrumbController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = GoRouterState.of(context).extra;
      if (args is Server) {
        setState(() {
          _showServerSelector = false;
        });
        _connectToServer(args);
      }
    });
  }

  Future<void> _connectToServer(Server server) async {
    await ref.read(fileBrowserStateProvider.notifier).connectToServer(server);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(fileBrowserStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(state),
      body: Stack(
        children: [
          _buildBody(state),
          // Navigation loading overlay
          if (state.isNavigating) _buildNavigationOverlay(state),
        ],
      ),
    );
  }

  Widget _buildNavigationOverlay(FileBrowserState state) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: AppTheme.background.withValues(alpha: 0.6),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.border.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Opening Folder',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (state.navigatingToPath != null)
                        Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Text(
                            state.navigatingToPath!,
                            style: GoogleFonts.firaCode(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(FileBrowserState state) {
    return AppBar(
      title: Text(
        ref.tr('nav_files'),
        style: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      backgroundColor: AppTheme.background,
      elevation: 0,
      actions: [
        // Multi-select toggle
        if (state.isConnected && state.files.isNotEmpty)
          IconButton(
            icon: Icon(
              state.isMultiSelectMode ? LucideIcons.x : LucideIcons.checkSquare,
              color: state.isMultiSelectMode
                  ? AppTheme.primary
                  : AppTheme.textPrimary,
            ),
            onPressed: () => _toggleMultiSelect(),
            tooltip: state.isMultiSelectMode ? 'Cancel' : 'Select Multiple',
          ),
        // View mode toggle
        if (state.isConnected)
          IconButton(
            icon: Icon(
              state.viewMode == ViewMode.list
                  ? LucideIcons.grid
                  : LucideIcons.list,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => _toggleViewMode(),
            tooltip:
                state.viewMode == ViewMode.list ? 'Grid View' : 'List View',
          ),
        // Refresh button
        if (state.isConnected)
          IconButton(
            icon: Icon(
              LucideIcons.refreshCw,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            onPressed: state.isLoading ? null : () => _refresh(),
            tooltip: 'Refresh',
          ),
        // Upload button
        if (state.isConnected)
          IconButton(
            icon: const Icon(LucideIcons.upload, color: AppTheme.textPrimary),
            onPressed: () => _uploadFile(),
            tooltip: 'Upload',
          ),
        // Server selector button
        IconButton(
          icon: const Icon(LucideIcons.server, color: AppTheme.textPrimary),
          onPressed: () => _showServerSelectorDialog(),
          tooltip: 'Change Server',
        ),
      ],
    );
  }

  Widget _buildBody(FileBrowserState state) {
    if (_showServerSelector || !state.isConnected) {
      return _buildServerSelector(state);
    }

    return Column(
      children: [
        // Enhanced breadcrumb path bar
        _buildBreadcrumbBar(state),
        // Disk usage indicator
        if (state.diskUsage != null) _buildDiskUsageIndicator(state),
        // File list/grid
        Expanded(
          child: _buildFileList(state),
        ),
        // Multi-select action bar
        if (state.isMultiSelectMode) _buildMultiSelectBar(state),
      ],
    );
  }

  Widget _buildServerSelector(FileBrowserState state) {
    final serverListAsync = ref.watch(serverListStreamProvider);

    return serverListAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
      error: (e, _) => Center(
        child: Text('$e', style: const TextStyle(color: AppTheme.critical)),
      ),
      data: (servers) {
        if (servers.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 700),
                    builder: (_, v, child) =>
                        Transform.scale(scale: v, child: child),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.folderOpen,
                          size: 52, color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    ref.tr('no_servers_yet'),
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ref.tr('add_server_prompt_files'),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                builder: (_, v, child) => Opacity(opacity: v, child: child),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(LucideIcons.folderOpen,
                          size: 36, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ref.tr('file_manager'),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ref.tr('select_server_files'),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Divider
            const Divider(color: AppTheme.border, height: 1),
            const SizedBox(height: 12),

            // ── Server List ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: servers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _ServerTile(
                  server: servers[index],
                  onTap: () {
                    setState(() {
                      _showServerSelector = false;
                    });
                    _connectToServer(servers[index]);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBreadcrumbBar(FileBrowserState state) {
    final segments =
        state.currentPath.split('/').where((s) => s.isNotEmpty).toList();
    final paths = <String>[];
    for (int i = 0; i < segments.length; i++) {
      paths.add('/${segments.sublist(0, i + 1).join('/')}');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Home button
          IconButton(
            icon: const Icon(LucideIcons.home, size: 18),
            onPressed: () => _navigateToHome(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Home',
          ),
          const SizedBox(width: 4),
          // Up button
          IconButton(
            icon: const Icon(LucideIcons.arrowUp, size: 18),
            onPressed: state.currentPath == '/' ? null : () => _navigateUp(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            tooltip: 'Parent Directory',
          ),
          const SizedBox(width: 8),
          // Breadcrumb separator
          Icon(LucideIcons.chevronRight,
              size: 16, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          // Scrollable path segments
          Expanded(
            child: SingleChildScrollView(
              controller: _breadcrumbController,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Root
                  GestureDetector(
                    onTap: () => _navigateToHome(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.folder,
                              size: 14, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text(
                            'Root',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Segments
                  ...List.generate(segments.length, (index) {
                    final isLast = index == segments.length - 1;
                    final path = paths[index];
                    return Row(
                      children: [
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _navigateToPath(path),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : null,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              segments[index],
                              style: GoogleFonts.firaCode(
                                fontSize: 13,
                                fontWeight:
                                    isLast ? FontWeight.w600 : FontWeight.w400,
                                color: isLast
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiskUsageIndicator(FileBrowserState state) {
    if (state.diskUsage == null) return const SizedBox.shrink();

    final total = state.diskUsage!['total'] ?? 0;
    final used = state.diskUsage!['used'] ?? 0;
    final available = state.diskUsage!['available'] ?? 0;

    if (total == 0) return const SizedBox.shrink();

    final usagePercent = (used / total) * 100;
    final isCritical = usagePercent > 85;
    final isWarning = usagePercent > 70;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.background,
      child: Row(
        children: [
          Icon(
            LucideIcons.hardDrive,
            size: 16,
            color: isCritical
                ? AppTheme.critical
                : (isWarning ? AppTheme.warning : AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DISK USAGE',
                      style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 11),
                    ),
                    Text(
                      '${formatPercent(usagePercent)} (${_formatBytes(available)} free)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isCritical
                            ? AppTheme.critical
                            : (isWarning
                                ? AppTheme.warning
                                : AppTheme.textSecondary),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: usagePercent / 100,
                    backgroundColor: AppTheme.zinc800,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCritical
                          ? AppTheme.critical
                          : (isWarning ? AppTheme.warning : AppTheme.primary),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Widget _buildFileList(FileBrowserState state) {
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Fetching directory...',
              style: GoogleFonts.firaCode(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.critical.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppTheme.critical.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                LucideIcons.alertCircle,
                size: 48,
                color: AppTheme.critical,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading files',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                state.error!,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _refresh(),
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    if (state.files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.folder,
              size: 48,
              color: AppTheme.border,
            ),
            const SizedBox(height: 16),
            Text(
              'This folder is empty',
              style: AppTheme.infoLabelStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCompactActionButton(
                    LucideIcons.folderPlus, 'New Folder', _createDirectory),
                const SizedBox(width: 12),
                _buildCompactActionButton(
                    LucideIcons.upload, 'Upload', _uploadFile),
              ],
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refresh(),
      color: AppTheme.primary,
      backgroundColor: AppTheme.surface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: SystemCard(
          padding: EdgeInsets.zero,
          child: state.viewMode == ViewMode.list
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return RemoteFileItem(
                      file: file,
                      onTap: () => _onFileTap(file),
                      onLongPress: () => _showFileOptions(file),
                      isSelected: state.selectedFiles.contains(file.path),
                      isInMultiSelectMode: state.isMultiSelectMode,
                      isNavigationDisabled: state.isNavigating,
                      onToggleSelect: () => _toggleFileSelection(file.path),
                      viewMode: ViewMode.list,
                    );
                  },
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: state.files.length,
                  itemBuilder: (context, index) {
                    final file = state.files[index];
                    return RemoteFileItem(
                      file: file,
                      onTap: () => _onFileTap(file),
                      onLongPress: () => _showFileOptions(file),
                      isSelected: state.selectedFiles.contains(file.path),
                      isInMultiSelectMode: state.isMultiSelectMode,
                      isNavigationDisabled: state.isNavigating,
                      onToggleSelect: () => _toggleFileSelection(file.path),
                      viewMode: ViewMode.grid,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectBar(FileBrowserState state) {
    final selectedCount = state.selectedFiles.length;
    final hasSelection = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Selection count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedCount selected',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (hasSelection)
                    Text(
                      'Choose an action',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            // Action buttons
            if (hasSelection) ...[
              _buildActionButton(
                  LucideIcons.download, 'Download', () => _downloadSelected()),
              _buildActionButton(
                  LucideIcons.trash2, 'Delete', () => _deleteSelected(),
                  isDestructive: true),
            ],
            _buildActionButton(
                LucideIcons.check, 'Select All', () => _selectAll()),
            // Cancel button
            IconButton(
              icon: const Icon(LucideIcons.x, color: AppTheme.textSecondary),
              onPressed: () => _toggleMultiSelect(),
              tooltip: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(
      IconData icon, String label, VoidCallback onTap) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: AppTheme.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? AppTheme.critical : AppTheme.textPrimary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color:
                    isDestructive ? AppTheme.critical : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Actions
  void _onFileTap(RemoteFile file) {
    final state = ref.read(fileBrowserStateProvider);

    debugPrint(
        'FilesScreen: Tapped file "${file.name}", isDirectory: ${file.isDirectory}');
    debugPrint(
        'FilesScreen: Current state - isMultiSelectMode: ${state.isMultiSelectMode}, isNavigating: ${state.isNavigating}');

    // Don't allow navigation during multi-select or already navigating
    if (state.isMultiSelectMode || state.isNavigating) {
      debugPrint(
          'FilesScreen: Ignoring tap - multiSelect: ${state.isMultiSelectMode}, navigating: ${state.isNavigating}');
      return;
    }

    if (file.isDirectory) {
      debugPrint('FilesScreen: Navigating to folder: ${file.path}');
      // Navigate to folder
      ref
          .read(fileBrowserStateProvider.notifier)
          .navigateTo(file.path, file.name);
    } else {
      debugPrint('FilesScreen: Showing options for file: ${file.name}');
      // Show file options
      _showFileOptions(file);
    }
  }

  void _navigateUp() {
    ref.read(fileBrowserStateProvider.notifier).navigateUp();
  }

  void _navigateToHome() {
    ref.read(fileBrowserStateProvider.notifier).loadDirectory('/');
  }

  void _navigateToPath(String path) {
    ref.read(fileBrowserStateProvider.notifier).loadDirectory(path);
  }

  Future<void> _refresh() async {
    await ref.read(fileBrowserStateProvider.notifier).refresh();
  }

  void _toggleMultiSelect() {
    ref.read(fileBrowserStateProvider.notifier).toggleMultiSelectMode();
  }

  void _toggleFileSelection(String path) {
    ref.read(fileBrowserStateProvider.notifier).toggleFileSelection(path);
  }

  void _selectAll() {
    final state = ref.read(fileBrowserStateProvider);
    if (state.selectedFiles.length == state.files.length) {
      ref.read(fileBrowserStateProvider.notifier).deselectAll();
    } else {
      ref.read(fileBrowserStateProvider.notifier).selectAll();
    }
  }

  void _toggleViewMode() {
    ref.read(fileBrowserStateProvider.notifier).toggleViewMode();
  }

  Future<void> _createDirectory() async {
    final controller = TextEditingController();

    if (!mounted) return;

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Folder name',
            labelStyle: TextStyle(color: AppTheme.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty && mounted) {
      try {
        await ref.read(fileBrowserStateProvider.notifier).createDirectory(name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Folder created'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.critical,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }

  Future<void> _uploadFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      final bytes = file.bytes;

      if (bytes == null) {
        throw Exception('Could not read file');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Uploading...'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      await ref
          .read(fileBrowserStateProvider.notifier)
          .uploadFile(file.name, bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('File uploaded successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppTheme.critical,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _downloadSelected() async {
    final state = ref.read(fileBrowserStateProvider);
    final files =
        state.selectedFileObjects.where((f) => !f.isDirectory).toList();

    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No downloadable files selected'),
          backgroundColor: AppTheme.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${files.length} file(s)...'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      final directory = await getApplicationDocumentsDirectory();

      for (final file in files) {
        final bytes = await ref
            .read(fileBrowserStateProvider.notifier)
            .downloadFile(file);
        final filePath = '${directory.path}/${file.name}';
        final savedFile = File(filePath);
        await savedFile.writeAsBytes(bytes);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Downloaded ${files.length} file(s) to ${directory.path}'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      _toggleMultiSelect();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppTheme.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteSelected() async {
    final state = ref.read(fileBrowserStateProvider);
    final files = state.selectedFileObjects;

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete Selected Items'),
        content: Text(
          'Are you sure you want to delete ${files.length} item(s)?',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.critical),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(fileBrowserStateProvider.notifier).deleteSelectedItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deleted successfully'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showFileOptions(RemoteFile file) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    file.isDirectory ? LucideIcons.folder : LucideIcons.file,
                    color: AppTheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          file.formattedSize,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.border),
            // Actions
            if (!file.isDirectory) ...[
              _buildActionItem(
                icon: LucideIcons.download,
                label: 'Download',
                onTap: () => _downloadFile(file),
              ),
              _buildActionItem(
                icon: LucideIcons.share,
                label: 'Share',
                onTap: () => _shareFile(file),
              ),
            ],
            _buildActionItem(
              icon: LucideIcons.pencil,
              label: 'Rename',
              onTap: () => _renameFile(file),
            ),
            _buildActionItem(
              icon: LucideIcons.trash2,
              label: 'Delete',
              labelColor: AppTheme.critical,
              iconColor: AppTheme.critical,
              onTap: () => _deleteFile(file),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Color? labelColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.textSecondary),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor ?? AppTheme.textPrimary,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Future<void> _downloadFile(RemoteFile file) async {
    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Downloading...'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      final bytes =
          await ref.read(fileBrowserStateProvider.notifier).downloadFile(file);

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${file.name}';
      final savedFile = File(filePath);
      await savedFile.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved to $filePath'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: AppTheme.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _shareFile(RemoteFile file) async {
    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preparing file...'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      final bytes =
          await ref.read(fileBrowserStateProvider.notifier).downloadFile(file);

      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/${file.name}';
      final savedFile = File(filePath);
      await savedFile.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(filePath)]);

      await savedFile.delete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Share failed: $e'),
            backgroundColor: AppTheme.critical,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _renameFile(RemoteFile file) async {
    final controller = TextEditingController(text: file.name);

    if (!mounted) return;

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Rename'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'New name',
            labelStyle: TextStyle(color: AppTheme.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
          ),
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != file.name &&
        mounted) {
      try {
        await ref
            .read(fileBrowserStateProvider.notifier)
            .renameItem(file, newName);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Renamed successfully'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteFile(RemoteFile file) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Delete'),
        content: Text(
          'Are you sure you want to delete "${file.name}"?',
          style: const TextStyle(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.critical),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(fileBrowserStateProvider.notifier).deleteItem(file);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deleted successfully'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppTheme.critical,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Future<void> _showServerSelectorDialog() async {
    final servers =
        await (await ref.read(serverRepositoryProvider.future)).getAllServers();

    if (!mounted) return;

    final selectedServer = await showGeneralDialog<Server>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(Tween(begin: 0.9, end: 1.0)
                    .chain(CurveTween(curve: Curves.easeOutCubic))),
                child: AlertDialog(
                  backgroundColor: AppTheme.surface,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.border),
                  ),
                  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  title: Text(
                    'SELECT SERVER',
                    style: AppTheme.sectionHeaderStyle.copyWith(fontSize: 14),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: servers.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppTheme.border, height: 1),
                        itemBuilder: (context, index) {
                          final server = servers[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                LucideIcons.server,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                            ),
                            title: Text(
                              server.name,
                              style: GoogleFonts.inter(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${server.hostname}:${server.port}',
                              style: GoogleFonts.firaCode(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                            onTap: () => Navigator.pop(context, server),
                            trailing: const Icon(
                              LucideIcons.chevronRight,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.inter(
                          color: AppTheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (selectedServer != null && mounted) {
      setState(() {
        _showServerSelector = false;
      });
      await _connectToServer(selectedServer);
    }
  }

  @override
  void dispose() {
    _breadcrumbController.dispose();
    ref.read(fileBrowserStateProvider.notifier).disconnect();
    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Server tile (identical layout to terminal server tile)
// ─────────────────────────────────────────────────────────────────────────────

class _ServerTile extends StatelessWidget {
  const _ServerTile({required this.server, required this.onTap});

  final Server server;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isOnline = server.status == ServerStatus.online;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              // Server icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.server,
                    size: 20, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${server.username}@${server.hostname}:${server.port}',
                      style: GoogleFonts.firaCode(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isOnline ? AppTheme.success : AppTheme.disabled)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isOnline ? AppTheme.success : AppTheme.disabled,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isOnline ? AppTheme.success : AppTheme.disabled,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(LucideIcons.chevronRight,
                  size: 16, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
