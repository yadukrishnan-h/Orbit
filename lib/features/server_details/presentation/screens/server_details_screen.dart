import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/providers.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/utils/error_mapper.dart';
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
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getStatusColor().withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getStatusColor().withValues(alpha: 0.2),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        LucideIcons.server,
                        size: 38,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor().withValues(alpha: 0.25),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _getStatusColor(),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _getStatusColor().withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.server.status.name.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
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
                    LucideIcons.globe,
                    'Hostname',
                    widget.server.hostname,
                  ),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 24,
                  ),
                  _buildDetailRow(
                    LucideIcons.hash,
                    'Port',
                    widget.server.port.toString(),
                  ),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 24,
                  ),
                  _buildDetailRow(
                    LucideIcons.user,
                    'Username',
                    widget.server.username,
                  ),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 24,
                  ),
                  _buildDetailRow(
                    LucideIcons.shield,
                    'Auth Type',
                    widget.server.authType.name,
                  ),
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
                    LucideIcons.fingerprint,
                    'Server ID',
                    widget.server.id,
                  ),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.05),
                    height: 24,
                  ),
                  _buildDetailRow(
                    LucideIcons.calendar,
                    'Added On',
                    widget.server.lastSeen?.toLocal().toString().split(
                          '.',
                        )[0] ??
                        'Unknown',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

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
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.heroGreenGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.terminalMint.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: const Color(0xFF0A0A0C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF0A0A0C),
                              ),
                            )
                          : Text(
                              'Run Test Connection',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF0A0A0C),
                              ),
                            ),
                    ),
                  ),
                  if (_connectionResult != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _connectionResult!.startsWith('Success')
                              ? AppTheme.terminalMint.withValues(alpha: 0.3)
                              : AppTheme.critical.withValues(alpha: 0.3),
                          width: 1,
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
                                ? AppTheme.terminalMint
                                : AppTheme.critical,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _connectionResult!,
                              style: GoogleFonts.firaCode(
                                fontSize: 12,
                                color: _connectionResult!.startsWith('Success')
                                    ? AppTheme.terminalMint
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
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Icon(icon, size: 15, color: Colors.white70),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.firaCode(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
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
        widget.server.id,
        'whoami',
      );
      setState(() {
        _connectionResult = 'Success: Connection verified as $result';
      });
    } catch (e) {
      setState(() {
        _connectionResult = 'Failure: ${ErrorMapper.userFriendlyMessage(e)}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
