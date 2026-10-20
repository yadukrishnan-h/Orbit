import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/features/home/widgets/server_summary_card.dart';
import 'package:orbit/features/dashboard/providers/dashboard_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _isSearchOpen = false;
  String _searchQuery = '';
  final ServerStatusFilter _statusFilter = ServerStatusFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchListener);
    Future.microtask(() {
      ref.read(serverMonitorViewModelProvider);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchListener);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchListener() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  List<Server> _filterServers(List<Server> servers) {
    return servers.where((server) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          server.name.toLowerCase().contains(_searchQuery) ||
          server.hostname.toLowerCase().contains(_searchQuery);

      final matchesStatus = switch (_statusFilter) {
        ServerStatusFilter.all => true,
        ServerStatusFilter.online => server.status == ServerStatus.online,
        ServerStatusFilter.offline => server.status == ServerStatus.offline,
        ServerStatusFilter.error => server.status == ServerStatus.error,
      };

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final serverListAsync = ref.watch(serverListStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Orbit',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => context.push('/add-server'),
            icon: const Icon(LucideIcons.plus, color: AppTheme.textPrimary),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Server list sits flush below AppBar ──────────────────
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(serverMonitorViewModelProvider.notifier)
                    .refreshAll();
              },
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: serverListAsync.when(
                data: (servers) {
                  final filteredServers = _filterServers(servers);

                  if (filteredServers.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSizes.p32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppTheme.terminalMint.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.terminalMint.withValues(
                                    alpha: 0.25,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.terminalMint.withValues(
                                      alpha: 0.1,
                                    ),
                                    blurRadius: 32,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                LucideIcons.server,
                                size: 44,
                                color: AppTheme.terminalMint,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? ref.tr('no_systems_match')
                                  : ref.tr('no_systems_found'),
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Add a remote server to begin monitoring telemetry, running SSH commands, and managing files.',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.heroGreenGradient,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.terminalMint.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () => context.push('/add-server'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    foregroundColor: const Color(0xFF0A0A0C),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  icon: const Icon(LucideIcons.plus, size: 18),
                                  label: Text(
                                    ref.tr('add_first_server'),
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  final onlineCount = filteredServers
                      .where((s) => s.status == ServerStatus.online)
                      .length;

                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.of(context).padding.bottom + 16,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SYSTEMS & SERVERS',
                              style: AppTheme.sectionTitleStyle,
                            ),
                            Text(
                              '$onlineCount/${filteredServers.length} ONLINE',
                              style: AppTheme.sectionTitleStyle,
                            ),
                          ],
                        ),
                      ),
                      ...List.generate(filteredServers.length, (index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < filteredServers.length - 1 ? 12 : 0,
                          ),
                          child: ServerSummaryCard(
                            key: ValueKey(filteredServers[index].id),
                            server: filteredServers[index],
                          ),
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.alertCircle,
                        size: 48,
                        color: AppTheme.critical,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading servers',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$err',
                        style: const TextStyle(
                          color: AppTheme.critical,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () {
                          ref.invalidate(serverListStreamProvider);
                        },
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: Text(ref.tr('retry')),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Floating Animated Search Bar ─────────────────────────
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom,
            right: 20.0,
            child: _buildFloatingSearchBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingSearchBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final targetWidth = _isSearchOpen ? screenWidth - 40.0 : 52.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: targetWidth,
      height: 52.0,
      decoration: BoxDecoration(
        color: _isSearchOpen
            ? const Color(0xFF141518).withValues(alpha: 0.95)
            : const Color(0xFF181A20),
        borderRadius: BorderRadius.circular(26),
        border: _isSearchOpen
            ? Border.all(
                color: AppTheme.terminalMint.withValues(alpha: 0.35),
                width: 1,
              )
            : Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.40),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _isSearchOpen ? 16 : 0,
            sigmaY: _isSearchOpen ? 16 : 0,
          ),
          child: Material(
            color: Colors.transparent,
            child: _isSearchOpen
                ? OverflowBox(
                    minWidth: 0,
                    maxWidth: screenWidth - 40.0,
                    minHeight: 52,
                    maxHeight: 52,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: screenWidth - 40.0,
                      height: 52,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(
                            LucideIcons.search,
                            color: Color(0xFF7E8492),
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              cursorColor: const Color(0xFFFFFFFF),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                hintText: 'Search servers...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF7E8492),
                                  fontSize: 14,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              LucideIcons.x,
                              color: Colors.white,
                              size: 18,
                            ),
                            splashRadius: 20,
                            onPressed: () {
                              _searchController.clear();
                              _searchFocusNode.unfocus();
                              setState(() {
                                _isSearchOpen = false;
                              });
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  )
                : InkWell(
                    borderRadius: BorderRadius.circular(26),
                    onTap: () {
                      setState(() {
                        _isSearchOpen = true;
                      });
                      Future.delayed(const Duration(milliseconds: 320), () {
                        if (mounted) {
                          _searchFocusNode.requestFocus();
                        }
                      });
                    },
                    child: const Center(
                      child: Icon(Icons.search, color: Colors.white, size: 22),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

enum ServerStatusFilter { all, online, offline, error }
