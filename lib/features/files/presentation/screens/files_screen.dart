import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

class FilesScreen extends ConsumerStatefulWidget {
  const FilesScreen({super.key});

  @override
  ConsumerState<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends ConsumerState<FilesScreen> {
  bool _showServerSelector = true;
  final _breadcrumbController = ScrollController();
  bool _isSearchOpen = false;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _fileSearchQuery = '';

  Future<Directory> _getSharedCacheDir() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/shared_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  void _cleanSharedCache() {
    unawaited(() async {
      try {
        final cacheDir = await _getSharedCacheDir();
        if (await cacheDir.exists()) {
          final entities = cacheDir.listSync();
          for (final entity in entities) {
            try {
              entity.deleteSync(recursive: true);
            } catch (_) {}
          }
        }
      } catch (_) {}
    }());
  }

  @override
  void initState() {
    super.initState();
    _cleanSharedCache();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = GoRouterState.of(context).extra;
      if (args is Server) {
        setState(() {
          _showServerSelector = false;
        });

        final state = ref.read(fileBrowserStateProvider);
        if (state.isConnected && state.server?.id == args.id) {
          // Already connected (likely via blocking UX), skip reconnecting
          return;
        }

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
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: _buildAppBar(state),
      body: Stack(
        children: [
          _buildBody(state),
          // Connection loading overlay
          if (state.isConnecting) _buildConnectionOverlay(state),
          // Navigation loading overlay
          if (state.isNavigating) _buildNavigationOverlay(state),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: state.isConnected
          ? Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00E676).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _uploadFile(),
                backgroundColor: Colors.transparent,
                elevation: 0,
                tooltip: 'Upload File',
                child: const Icon(LucideIcons.upload, color: Color(0xFF0A0A0C)),
              ),
            )
          : null,
    );
  }

  Widget _buildConnectionOverlay(FileBrowserState state) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: AppTheme.background.withValues(alpha: 0.8),
          child: Center(
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
                  'Connecting to Server...',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (state.server != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.server!.name,
                    style: GoogleFonts.firaCode(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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
                            horizontal: 12,
                            vertical: 6,
                          ),
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
        // Search button
        if (state.isConnected)
          IconButton(
            icon: Icon(
              _isSearchOpen ? LucideIcons.x : LucideIcons.search,
              color: _isSearchOpen ? AppTheme.primary : AppTheme.textPrimary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                if (!_isSearchOpen) {
                  _fileSearchQuery = '';
                  _searchController.clear();
                  _searchFocusNode.unfocus();
                } else {
                  _searchFocusNode.requestFocus();
                }
              });
            },
            tooltip: _isSearchOpen ? 'Close search' : 'Search files',
          ),
        // Refresh button
        if (state.isConnected)
          IconButton(
            icon: const Icon(
              LucideIcons.refreshCw,
              color: AppTheme.textPrimary,
              size: 20,
            ),
            onPressed: state.isLoading ? null : () => _refresh(),
            tooltip: 'Refresh',
          ),
        // Three-dot overflow menu for secondary actions
        if (state.isConnected)
          PopupMenuButton<String>(
            icon: const Icon(
              LucideIcons.moreVertical,
              color: AppTheme.textPrimary,
            ),
            color: AppTheme.surface,
            onSelected: (value) {
              if (value == 'select') {
                if (state.files.isNotEmpty) {
                  _toggleMultiSelect();
                }
              } else if (value == 'view') {
                _toggleViewMode();
              } else if (value == 'disconnect') {
                ref.read(fileBrowserStateProvider.notifier).disconnect();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'select',
                enabled: state.files.isNotEmpty,
                child: Text(
                  'Select Files',
                  style: GoogleFonts.inter(color: AppTheme.textPrimary),
                ),
              ),
              PopupMenuItem(
                value: 'view',
                child: Text(
                  'Toggle Grid/List View',
                  style: GoogleFonts.inter(color: AppTheme.textPrimary),
                ),
              ),
              PopupMenuItem(
                value: 'disconnect',
                child: Text(
                  'Disconnect',
                  style: GoogleFonts.inter(color: AppTheme.critical),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFileSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: Color(0x0CFFFFFF), width: 1)),
      ),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Icon(LucideIcons.search, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: (val) {
                  setState(() {
                    _fileSearchQuery = val.trim().toLowerCase();
                  });
                },
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Filter files by name...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (_fileSearchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {
                    _fileSearchQuery = '';
                  });
                },
                child: const Icon(
                  LucideIcons.x,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
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
        // File search bar when active
        if (_isSearchOpen) _buildFileSearchBar(),
        // Disk usage indicator
        if (state.diskUsage != null) _buildDiskUsageIndicator(state),
        // File list/grid
        Expanded(child: _buildFileList(state)),
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
                      child: const Icon(
                        LucideIcons.folderOpen,
                        size: 52,
                        color: AppTheme.primary,
                      ),
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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Select a system to browse, upload, and download directories remotely using a secure FTP connection.',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            Text('AVAILABLE SESSIONS', style: AppTheme.sectionTitleStyle),
            const SizedBox(height: 12),
            ...List.generate(servers.length, (index) {
              final server = servers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildFileSessionCard(
                  server: server,
                  onTap: () {
                    setState(() {
                      _showServerSelector = false;
                    });
                    _connectToServer(server);
                  },
                ),
              );
            }),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        );
      },
    );
  }

  Widget _buildFileSessionCard({
    required Server server,
    required VoidCallback onTap,
  }) {
    final isOnline = server.status == ServerStatus.online;
    final statusColor = isOnline
        ? AppTheme.terminalMint
        : const Color(0xFF7E8492);
    final statusBgColor = isOnline
        ? AppTheme.terminalMint.withValues(alpha: 0.12)
        : const Color(0xFF7E8492).withValues(alpha: 0.12);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Leading icon tile
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isOnline
                    ? AppTheme.terminalMint.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOnline
                      ? AppTheme.terminalMint.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              child: Icon(
                LucideIcons.folder,
                size: 20,
                color: isOnline
                    ? AppTheme.terminalMint
                    : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            // Server name & technical subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    server.name,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${server.username}@${server.hostname}:${server.port}',
                    style: GoogleFonts.firaCode(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Pill status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: isOnline
                          ? [
                              BoxShadow(
                                color: statusColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? 'Online' : 'Offline',
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbBar(FileBrowserState state) {
    final segments = state.currentPath
        .split('/')
        .where((s) => s.isNotEmpty)
        .toList();
    final paths = <String>[];
    for (int i = 0; i < segments.length; i++) {
      paths.add('/${segments.sublist(0, i + 1).join('/')}');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0CFFFFFF), width: 1)),
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
          Icon(
            LucideIcons.chevronRight,
            size: 16,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
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
                        horizontal: 14,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: segments.isEmpty
                            ? AppTheme.primary.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: segments.isEmpty
                              ? AppTheme.primary.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.08),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.folder,
                            size: 14,
                            color: segments.isEmpty
                                ? AppTheme.primary
                                : AppTheme.textPrimary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Root',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: segments.isEmpty
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: segments.isEmpty
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
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
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isLast
                                  ? AppTheme.primary.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isLast
                                    ? AppTheme.primary.withValues(alpha: 0.5)
                                    : Colors.white.withValues(alpha: 0.08),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              segments[index],
                              style: GoogleFonts.firaCode(
                                fontSize: 13,
                                fontWeight: isLast
                                    ? FontWeight.w600
                                    : FontWeight.w400,
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                      style: AppTheme.sectionHeaderStyle.copyWith(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '${formatPercent(usagePercent)} (${_formatBytes(available)} free)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isCritical
                            ? AppTheme.critical
                            : (isWarning ? AppTheme.warning : Colors.white),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: usagePercent / 100,
                    backgroundColor: const Color(0xFF2A2C31),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCritical
                          ? AppTheme.critical
                          : (isWarning
                                ? AppTheme.warning
                                : const Color(0xFF00E676)),
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
                border: Border.all(
                  color: AppTheme.critical.withValues(alpha: 0.3),
                ),
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
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
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
            const Icon(LucideIcons.folder, size: 48, color: AppTheme.border),
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
                  LucideIcons.folderPlus,
                  'New Folder',
                  _createDirectory,
                ),
                const SizedBox(width: 12),
                _buildCompactActionButton(
                  LucideIcons.upload,
                  'Upload',
                  _uploadFile,
                ),
              ],
            ),
          ],
        ),
      );
    }

    final filteredFiles = _fileSearchQuery.isEmpty
        ? state.files
        : state.files
              .where((f) => f.name.toLowerCase().contains(_fileSearchQuery))
              .toList();

    if (state.files.isNotEmpty && filteredFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.searchX, size: 48, color: AppTheme.border),
            const SizedBox(height: 16),
            Text(
              'No files match "$_fileSearchQuery"',
              style: AppTheme.infoLabelStyle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _fileSearchQuery = '';
                });
              },
              child: const Text('Clear Filter'),
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
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: state.viewMode == ViewMode.list
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredFiles.length,
                itemBuilder: (context, index) {
                  final file = filteredFiles[index];
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
                itemCount: filteredFiles.length,
                itemBuilder: (context, index) {
                  final file = filteredFiles[index];
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
    );
  }

  Widget _buildMultiSelectBar(FileBrowserState state) {
    final selectedCount = state.selectedFiles.length;
    final hasSelection = selectedCount > 0;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
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
              LucideIcons.download,
              'Download',
              () => _downloadSelected(),
            ),
            _buildActionButton(
              LucideIcons.trash2,
              'Delete',
              () => _deleteSelected(),
              isDestructive: true,
            ),
          ],
          _buildActionButton(
            LucideIcons.check,
            'Select All',
            () => _selectAll(),
          ),
          // Cancel button
          IconButton(
            icon: const Icon(LucideIcons.x, color: AppTheme.textSecondary),
            onPressed: () => _toggleMultiSelect(),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 14),
      label: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: AppTheme.primary.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
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
                color: isDestructive
                    ? AppTheme.critical
                    : AppTheme.textSecondary,
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
      'FilesScreen: Tapped file "${file.name}", isDirectory: ${file.isDirectory}',
    );
    debugPrint(
      'FilesScreen: Current state - isMultiSelectMode: ${state.isMultiSelectMode}, isNavigating: ${state.isNavigating}',
    );

    // Don't allow navigation during multi-select or already navigating
    if (state.isMultiSelectMode || state.isNavigating) {
      debugPrint(
        'FilesScreen: Ignoring tap - multiSelect: ${state.isMultiSelectMode}, navigating: ${state.isNavigating}',
      );
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
    ref
        .read(fileBrowserStateProvider.notifier)
        .loadDirectory('/', isNavigation: true);
  }

  void _navigateToPath(String path) {
    ref
        .read(fileBrowserStateProvider.notifier)
        .loadDirectory(path, isNavigation: true);
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

    try {
      final name = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF141518),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          title: Text(
            'New Folder',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Folder name',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: const Color(0xFF181A20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.terminalMint),
              ),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text(
                'Create',
                style: TextStyle(
                  color: AppTheme.terminalMint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (name != null && name.isNotEmpty && mounted) {
        try {
          await ref
              .read(fileBrowserStateProvider.notifier)
              .createDirectory(name);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Folder created'),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _uploadFile() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.any);

      if (files.isEmpty) return;

      final file = files.first;
      final uploadStream = file.xFile.openRead();
      final totalBytes = file.lengthSync() ?? (await file.length()) ?? 0;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading ${file.name}...'),
            backgroundColor: AppTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      await ref
          .read(fileBrowserStateProvider.notifier)
          .uploadFileStream(file.name, uploadStream, totalBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File ${file.name} uploaded successfully'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _downloadSelected() async {
    final state = ref.read(fileBrowserStateProvider);
    final files = state.selectedFileObjects
        .where((f) => !f.isDirectory)
        .toList();

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

      final directoryPath = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select download folder',
      );

      if (directoryPath == null) {
        // User cancelled destination folder selection
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${files.length} file(s)...'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      for (final file in files) {
        final filePath = '$directoryPath/${file.name}';
        await ref
            .read(fileBrowserStateProvider.notifier)
            .downloadFile(file, destinationPath: filePath);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Downloaded ${files.length} file(s) to $directoryPath',
            ),
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
        backgroundColor: const Color(0xFF141518),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: Text(
          'Delete Selected Items',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${files.length} item(s)?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppTheme.critical,
                fontWeight: FontWeight.bold,
              ),
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
      backgroundColor: const Color(0xFF141518),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: file.isDirectory
                          ? AppTheme.terminalMint.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: file.isDirectory
                            ? AppTheme.terminalMint.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Icon(
                      file.isDirectory ? LucideIcons.folder : LucideIcons.file,
                      color: file.isDirectory
                          ? AppTheme.terminalMint
                          : AppTheme.textSecondary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: GoogleFonts.inter(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          file.formattedSize,
                          style: GoogleFonts.firaCode(
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
            Divider(color: Colors.white.withValues(alpha: 0.08)),
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
            const SizedBox(height: 12),
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
    final effectiveColor = iconColor ?? AppTheme.textSecondary;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: effectiveColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: effectiveColor),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: labelColor ?? AppTheme.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
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

      // Select destination folder via system file picker [LOGIC-003]
      final destDir = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select destination folder',
      );

      if (destDir == null) {
        // User cancelled folder selection
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading ${file.name}...'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${file.name}');

      // Stream download from SFTP socket into temporary file on disk
      final File savedFile = await ref
          .read(fileBrowserStateProvider.notifier)
          .downloadFile(file, destinationPath: tempFile.path);

      try {
        final destPath = '$destDir/${file.name}';
        final destFile = File(destPath);

        // Stream chunked file bytes from temp to destination without buffering in RAM [LOGIC-002]
        final sink = destFile.openWrite();
        await savedFile.openRead().pipe(sink);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved ${file.name} to $destDir'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (await savedFile.exists()) {
          try {
            await savedFile.delete();
          } catch (_) {}
        }
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

      final cacheDir = await _getSharedCacheDir();
      final filePath = '${cacheDir.path}/${file.name}';

      final savedFile = await ref
          .read(fileBrowserStateProvider.notifier)
          .downloadFile(file, destinationPath: filePath);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(savedFile.path)]),
      );
      // Do NOT delete savedFile immediately, as Android handles shares asynchronously!
      // The shared_cache folder will be cleaned up on next screen init or dispose.
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

    try {
      final newName = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF141518),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          title: Text(
            'Rename',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'New name',
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              filled: true,
              fillColor: const Color(0xFF181A20),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.terminalMint),
              ),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text(
                'Rename',
                style: TextStyle(
                  color: AppTheme.terminalMint,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deleteFile(RemoteFile file) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141518),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        title: Text(
          'Delete',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${file.name}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppTheme.critical,
                fontWeight: FontWeight.bold,
              ),
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

  @override
  void dispose() {
    _cleanSharedCache();
    _breadcrumbController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
