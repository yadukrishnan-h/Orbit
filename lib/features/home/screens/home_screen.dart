import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
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
  String _searchQuery = '';
  ServerStatusFilter _statusFilter = ServerStatusFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(serverMonitorViewModelProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  void _setFilter(ServerStatusFilter filter) {
    setState(() {
      _statusFilter = filter;
    });
  }

  List<Server> _filterServers(List<Server> servers) {
    return servers.where((server) {
      final matchesSearch = _searchQuery.isEmpty ||
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
        centerTitle: true,
        title: Text(
          'Orbit',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppTheme.primary,
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
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: ref.tr('filter_systems'),
                hintStyle: const TextStyle(color: AppTheme.textSecondary),
                prefixIcon: const Icon(LucideIcons.search,
                    color: AppTheme.textSecondary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x,
                            size: 18, color: AppTheme.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),

          // Status Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'All',
                    selected: _statusFilter == ServerStatusFilter.all,
                    onTap: () => _setFilter(ServerStatusFilter.all),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: ref.tr('online'),
                    selected: _statusFilter == ServerStatusFilter.online,
                    onTap: () => _setFilter(ServerStatusFilter.online),
                    icon: LucideIcons.checkCircle,
                    iconColor: AppTheme.success,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: ref.tr('offline'),
                    selected: _statusFilter == ServerStatusFilter.offline,
                    onTap: () => _setFilter(ServerStatusFilter.offline),
                    icon: LucideIcons.xCircle,
                    iconColor: AppTheme.disabled,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: ref.tr('error'),
                    selected: _statusFilter == ServerStatusFilter.error,
                    onTap: () => _setFilter(ServerStatusFilter.error),
                    icon: LucideIcons.alertTriangle,
                    iconColor: AppTheme.critical,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(serverMonitorViewModelProvider);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppTheme.primary,
              backgroundColor: AppTheme.surface,
              child: serverListAsync.when(
                data: (servers) {
                  final filteredServers = _filterServers(servers);

                  if (filteredServers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.server,
                              size: 64, color: AppTheme.border),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty
                                ? ref.tr('no_systems_match')
                                : ref.tr('no_systems_found'),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.push('/add-server'),
                              child: Text(ref.tr('add_first_server')),
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredServers.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < filteredServers.length - 1 ? 12 : 0,
                        ),
                        child: ServerSummaryCard(
                          key: ValueKey(filteredServers[index].id),
                          server: filteredServers[index],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.alertCircle,
                          size: 48, color: AppTheme.critical),
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
        ],
      ),
    );
  }

  // Helper to push with context safely (go_router)
  void push(String path, {required BuildContext context}) {
    Navigator.of(context).pushNamed(path);
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withValues(alpha: 0.15)
              : AppTheme.surface,
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected
                    ? (iconColor ?? AppTheme.primary)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum ServerStatusFilter { all, online, offline, error }
