import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/models/server.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/theme/app_theme.dart';

import 'package:orbit/core/widgets/glow_border.dart';
import 'package:orbit/core/providers/server_loading_provider.dart';

class ServerSummaryCard extends ConsumerWidget {
  final Server server;
  final VoidCallback? onTap;

  const ServerSummaryCard({super.key, required this.server, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loadingState =
        ref.watch(serverLoadingProvider)[server.id] ??
        const ServerLoadingState(isLoading: true);
    final isLoading = loadingState.isLoading && !loadingState.hasLoadedOnce;

    final isStale =
        server.lastSeen != null &&
        DateTime.now().difference(server.lastSeen!).inMinutes > 5;
    final isOnline = server.status == ServerStatus.online && !isStale;

    final latencyText = isOnline && server.lastLatency > 0
        ? '${server.lastLatency}ms'
        : '--';

    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isLoading
            ? null
            : (onTap ??
                  () => context.push('/dashboard/${server.id}', extra: server)),
        child: GlowBorder(
          borderRadius: AppSizes.radiusMedium,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        server.name,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Latency : ',
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: latencyText,
                            style: GoogleFonts.firaCode(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Micro-Bars
                Row(
                  children: [
                    Expanded(
                      child: _buildMicroBar(
                        'CPU',
                        server.lastCpu ?? 0,
                        isOnline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMicroBar(
                        'RAM',
                        server.lastRam ?? 0,
                        isOnline,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMicroBar(
                        'DISK',
                        server.lastDisk ?? 0,
                        isOnline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicroBar(String label, double value, bool isOnline) {
    final displayValue = isOnline ? value : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: const Color(0xFF7E8492), // Muted grey
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              isOnline ? '${displayValue.toStringAsFixed(0)}%' : '--',
              style: GoogleFonts.firaCode(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 3px progress line
        Container(
          height: 3,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(1.5),
          ),
          child: isOnline
              ? FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (displayValue / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
                      ),
                      borderRadius: BorderRadius.circular(1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.terminalMint.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}
