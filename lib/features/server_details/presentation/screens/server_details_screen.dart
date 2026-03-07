import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/widgets/system_card.dart';

class ServerDetailsScreen extends ConsumerStatefulWidget {
  final Server server;

  const ServerDetailsScreen({super.key, required this.server});

  @override
  ConsumerState<ServerDetailsScreen> createState() =>
      _ServerDetailsScreenState();
}

class _ServerDetailsScreenState extends ConsumerState<ServerDetailsScreen> {
  String? _connectionResult;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          widget.server.name,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.server,
                      size: 40,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.server.status.name.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: _getStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Connection Details Section
            Text('CONNECTION DETAILS', style: AppTheme.sectionHeaderStyle),
            const SizedBox(height: 12),
            SystemCard(
              child: Column(
                children: [
                  _buildDetailRow(
                      LucideIcons.globe, 'Hostname', widget.server.hostname),
                  const Divider(color: AppTheme.border, height: 24),
                  _buildDetailRow(
                      LucideIcons.hash, 'Port', widget.server.port.toString()),
                  const Divider(color: AppTheme.border, height: 24),
                  _buildDetailRow(
                      LucideIcons.user, 'Username', widget.server.username),
                  const Divider(color: AppTheme.border, height: 24),
                  _buildDetailRow(LucideIcons.shield, 'Auth Type',
                      widget.server.authType.name),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Technical Information
            Text('TECHNICAL INFO', style: AppTheme.sectionHeaderStyle),
            const SizedBox(height: 12),
            SystemCard(
              child: Column(
                children: [
                  _buildDetailRow(
                      LucideIcons.fingerprint, 'Server ID', widget.server.id),
                  const Divider(color: AppTheme.border, height: 24),
                  _buildDetailRow(
                    LucideIcons.calendar,
                    'Added On',
                    widget.server.lastSeen
                            ?.toLocal()
                            .toString()
                            .split('.')[0] ??
                        'Unknown',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Connection Test Section
            Text('TOOLS', style: AppTheme.sectionHeaderStyle),
            const SizedBox(height: 12),
            SystemCard(
              title: 'Connection Test',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Test your SSH credentials by performing a simple "whoami" command.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surface,
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.border),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primary),
                          )
                        : const Text('Run Test Connection'),
                  ),
                  if (_connectionResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _connectionResult!.startsWith('Success')
                            ? AppTheme.success.withValues(alpha: 0.1)
                            : AppTheme.critical.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _connectionResult!.startsWith('Success')
                              ? AppTheme.success.withValues(alpha: 0.2)
                              : AppTheme.critical.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _connectionResult!.startsWith('Success')
                                ? LucideIcons.checkCircle2
                                : LucideIcons.alertCircle,
                            size: 16,
                            color: _connectionResult!.startsWith('Success')
                                ? AppTheme.success
                                : AppTheme.critical,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _connectionResult!,
                              style: GoogleFonts.firaCode(
                                fontSize: 12,
                                color: _connectionResult!.startsWith('Success')
                                    ? AppTheme.success
                                    : AppTheme.critical,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTheme.infoValueStyle.copyWith(fontSize: 13),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    return switch (widget.server.status) {
      ServerStatus.online => AppTheme.success,
      ServerStatus.offline => AppTheme.disabled,
      ServerStatus.error => AppTheme.critical,
      ServerStatus.unknown => AppTheme.textSecondary,
    };
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionResult = null;
    });

    final sshService = ref.read(sshServiceProvider);
    try {
      final result = await sshService.connectAndExecute(
        widget.server.hostname,
        widget.server.port,
        widget.server.username,
        widget.server.password,
        'whoami',
      );
      setState(() {
        _connectionResult = 'Success: Connection verified as $result';
      });
    } catch (e) {
      setState(() {
        _connectionResult = 'Failure: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
