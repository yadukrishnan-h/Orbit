import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/dashboard/repositories/server_repository.dart';
import 'package:orbit/features/dashboard/providers/dashboard_providers.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';
import 'package:orbit/core/services/isar_service.dart';

class ManageServersScreen extends ConsumerStatefulWidget {
  const ManageServersScreen({super.key});

  @override
  ConsumerState<ManageServersScreen> createState() =>
      _ManageServersScreenState();
}

class _ManageServersScreenState extends ConsumerState<ManageServersScreen> {
  bool _selectMode = false;
  final Set<String> _selectedIds = {};

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _bulkDelete(List<Server> servers) async {
    if (_selectedIds.isEmpty) return;

    // Biometric gate before delete
    final biometricsEnabled = ref.read(biometricsEnabledProvider);
    if (biometricsEnabled) {
      final biometricService = ref.read(biometricServiceProvider);
      final authenticated = await biometricService.authenticate(
        reason: 'Authenticate to delete selected servers',
      );
      if (!authenticated) return;
    }

    // Check mounted after async biometric gap
    if (!mounted) return;

    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Text(
          'Delete ${_selectedIds.length} Server${_selectedIds.length > 1 ? 's' : ''}?',
          style: GoogleFonts.inter(
              color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This action cannot be undone. All data for the selected servers will be permanently removed.',
          style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: GoogleFonts.inter(color: AppTheme.critical)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Stop monitoring for deleted servers
    final vm = ref.read(serverMonitorViewModelProvider.notifier);
    for (final id in _selectedIds) {
      await vm.stopMonitoring(id);
    }

    // Perform bulk delete via repository
    final isar = await ref.read(isarProvider.future);
    final repository = ServerRepository(isar);
    await repository.bulkDelete(_selectedIds.toList());

    if (mounted) {
      setState(() {
        _selectMode = false;
        _selectedIds.clear();
      });
    }
  }

  Future<void> _onReorder(
      List<Server> currentServers, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;

    final reordered = List<Server>.from(currentServers);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);

    final orderedIds = reordered.map((s) => s.id).toList();

    final isar = await ref.read(isarProvider.future);
    final repository = ServerRepository(isar);
    await repository.reorderServers(orderedIds);
  }

  @override
  Widget build(BuildContext context) {
    final serverListAsync = ref.watch(serverListStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text(
          _selectMode ? '${_selectedIds.length} Selected' : 'Manage Servers',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        elevation: 0,
        actions: [
          if (_selectMode && _selectedIds.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2, color: AppTheme.critical),
              tooltip: 'Delete selected',
              onPressed: () => serverListAsync.whenData(
                (servers) => _bulkDelete(servers),
              ),
            ),
          TextButton(
            onPressed: _toggleSelectMode,
            child: Text(
              _selectMode ? 'Cancel' : 'Select',
              style: GoogleFonts.inter(
                color: _selectMode ? AppTheme.textSecondary : AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: serverListAsync.when(
        data: (servers) {
          if (servers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.server,
                      size: 64, color: AppTheme.border),
                  const SizedBox(height: 16),
                  Text(
                    'No Servers',
                    style: GoogleFonts.inter(
                        color: AppTheme.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            buildDefaultDragHandles: !_selectMode,
            itemCount: servers.length,
            onReorder: (oldIndex, newIndex) =>
                _onReorder(servers, oldIndex, newIndex),
            proxyDecorator: (child, index, animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (ctx, _) => Material(
                  color: Colors.transparent,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primary),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              );
            },
            itemBuilder: (context, index) {
              final server = servers[index];
              final isSelected = _selectedIds.contains(server.id);

              return Padding(
                key: ValueKey(server.id),
                padding: const EdgeInsets.only(bottom: 10),
                child: _ServerRow(
                  server: server,
                  isSelectMode: _selectMode,
                  isSelected: isSelected,
                  onTap: _selectMode ? () => _toggleSelection(server.id) : null,
                  onCheckChanged:
                      _selectMode ? (_) => _toggleSelection(server.id) : null,
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: AppTheme.critical),
          ),
        ),
      ),
    );
  }
}

class _ServerRow extends StatelessWidget {
  final Server server;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckChanged;

  const _ServerRow({
    required this.server,
    required this.isSelectMode,
    required this.isSelected,
    this.onTap,
    this.onCheckChanged,
  });

  Color _statusColor() {
    switch (server.status) {
      case ServerStatus.online:
        return AppTheme.success;
      case ServerStatus.offline:
        return AppTheme.disabled;
      case ServerStatus.error:
        return AppTheme.critical;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _statusLabel() {
    switch (server.status) {
      case ServerStatus.online:
        return 'Online';
      case ServerStatus.offline:
        return 'Offline';
      case ServerStatus.error:
        return 'Error';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          leading: isSelectMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: onCheckChanged,
                  activeColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.textSecondary),
                )
              : Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(LucideIcons.server,
                      size: 18, color: AppTheme.primary),
                ),
          title: Text(
            server.name,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${server.username}@${server.hostname}:${server.port}',
            style: GoogleFonts.firaCode(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _statusLabel(),
                  style: GoogleFonts.inter(
                    color: _statusColor(),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isSelectMode) ...[
                const SizedBox(width: 8),
                ReorderableDragStartListener(
                  index: 0,
                  child: const Icon(LucideIcons.gripVertical,
                      color: AppTheme.textSecondary, size: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
