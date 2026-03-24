import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
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
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            // ── Group 1: Server Management ───────────────────────────
            SystemCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: AppSizes.p4,
                ),
                leading: const Icon(
                  LucideIcons.server,
                  color: AppTheme.textSecondary,
                  size: AppSizes.iconNormal,
                ),
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
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                onTap: () => context.push('/manage-servers'),
              ),
            ),

            const SizedBox(height: AppSizes.p16),

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
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                      vertical: AppSizes.p4,
                    ),
                    leading: const Icon(
                      Icons.password_rounded,
                      color: AppTheme.textSecondary,
                      size: AppSizes.iconNormal,
                    ),
                    title: Text(
                      'Change Master PIN',
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Update the PIN used to secure the app',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    onTap: () => context.push('/change-pin'),
                  ),
                  _divider(),
                  const AppIconTile(),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.p16),

            // ── Group 3: App Updates ─────────────────────────────────
            SystemCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                      vertical: AppSizes.p4,
                    ),
                    leading: const Icon(
                      LucideIcons.info,
                      color: AppTheme.textSecondary,
                      size: AppSizes.iconNormal,
                    ),
                    title: Text(
                      'About Orbit',
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(
                      LucideIcons.chevronRight,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                    onTap: () => context.push('/about'),
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppTheme.border,
                    indent: AppSizes.p16,
                    endIndent: AppSizes.p16,
                  ),
                  const _UpdateTile(),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.p32),

            // App version footer
            Center(
              child: Text(
                'Orbit v1.1.0',
                style: GoogleFonts.firaCode(
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.border,
      indent: AppSizes.p16,
      endIndent: AppSizes.p16,
    );
  }
}

class _UpdateTile extends StatefulWidget {
  const _UpdateTile();

  @override
  State<_UpdateTile> createState() => _UpdateTileState();
}

class _UpdateTileState extends State<_UpdateTile> {
  bool _isChecking = false;

  Future<void> _checkForUpdates() async {
    if (_isChecking) return;

    setState(() => _isChecking = true);

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (!mounted) return;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update available', style: GoogleFonts.inter()),
            action: SnackBarAction(
              label: 'Install',
              onPressed: () {
                InAppUpdate.performImmediateUpdate().catchError((e) {
                  return AppUpdateResult.inAppUpdateFailed;
                });
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('App is up to date', style: GoogleFonts.inter()),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to check for updates',
              style: GoogleFonts.inter(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p4,
      ),
      leading: const Icon(
        LucideIcons.refreshCw,
        color: AppTheme.textSecondary,
        size: AppSizes.iconNormal,
      ),
      title: Text(
        'Check for Updates',
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Check Play Store for new versions',
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: _isChecking
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(
              LucideIcons.chevronRight,
              color: AppTheme.textSecondary,
              size: 18,
            ),
      onTap: _checkForUpdates,
    );
  }
}
