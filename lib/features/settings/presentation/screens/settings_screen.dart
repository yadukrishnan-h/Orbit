import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/widgets/system_card.dart';
import 'package:orbit/features/settings/presentation/widgets/language_tile.dart';
import 'package:orbit/features/settings/presentation/widgets/poll_interval_tile.dart';
import 'package:orbit/features/settings/presentation/widgets/biometrics_tile.dart';
import 'package:orbit/features/settings/presentation/widgets/app_icon_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: Text(
          ref.tr('settings'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Group 1: Server Management ───────────────────────────
          SystemCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const Icon(LucideIcons.server,
                  color: AppTheme.textSecondary, size: 20),
              title: Text(
                ref.tr('manage_servers'),
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                ref.tr('manage_servers_subtitle'),
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(LucideIcons.chevronRight,
                  color: AppTheme.textSecondary, size: 18),
              onTap: () => context.push('/manage-servers'),
            ),
          ),

          const SizedBox(height: 16),

          // ── Group 2: App Preferences ──────────────────────────────
          SystemCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const LanguageTile(),
                _divider(),
                const PollIntervalTile(),
                _divider(),
                const BiometricsTile(),
                _divider(),
                const AppIconTile(),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // App version footer
          Center(
            child: Text(
              'Orbit v0.1.0',
              style: GoogleFonts.firaCode(
                color: AppTheme.textSecondary.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.border,
      indent: 16,
      endIndent: 16,
    );
  }
}
