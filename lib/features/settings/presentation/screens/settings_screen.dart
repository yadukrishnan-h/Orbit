import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/widgets/system_card.dart';
import 'package:orbit/features/settings/presentation/widgets/language_tile.dart';
import 'package:orbit/features/settings/presentation/widgets/poll_interval_tile.dart';
import 'package:orbit/features/settings/presentation/widgets/biometrics_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

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
        padding: EdgeInsets.fromLTRB(
          AppSizes.p16,
          AppSizes.p16,
          AppSizes.p16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        children: [
          // ── Group 1: Server Management ───────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('SERVERS', style: AppTheme.sectionTitleStyle),
          ),
          SystemCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.p16,
                vertical: AppSizes.p6,
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.server,
                  color: Colors.white,
                  size: 18,
                ),
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

          const SizedBox(height: AppSizes.p24),

          // ── Group 2: App Preferences ──────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('PREFERENCES', style: AppTheme.sectionTitleStyle),
          ),
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
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.lock,
                      color: Colors.white,
                      size: 18,
                    ),
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
                Consumer(
                  builder: (context, ref, _) {
                    final settingsAsync = ref.watch(settingsProvider);
                    final isGeoEnabled = settingsAsync.maybeWhen(
                      data: (s) => s.isGeolocationEnabled,
                      orElse: () => false,
                    );
                    return SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p4,
                      ),
                      secondary: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          LucideIcons.mapPin,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        'Server Geolocation',
                        style: GoogleFonts.inter(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Look up server country & city via ipwho.is (HTTPS)',
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      value: isGeoEnabled,
                      activeThumbColor: AppTheme.terminalMint,
                      activeTrackColor: AppTheme.terminalMint.withValues(
                        alpha: 0.3,
                      ),
                      onChanged: (val) {
                        ref
                            .read(settingsProvider.notifier)
                            .setGeolocationEnabled(val);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.p24),

          // ── Group 3: App Updates ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text('SYSTEM & ABOUT', style: AppTheme.sectionTitleStyle),
          ),
          SystemCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.p16,
                    vertical: AppSizes.p4,
                  ),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.info,
                      color: Colors.white,
                      size: 18,
                    ),
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
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.white.withValues(alpha: 0.05),
                  indent: AppSizes.p16,
                  endIndent: AppSizes.p16,
                ),
                const _UpdateTile(),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.p32),

          // App version footer
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.data?.version ?? '1.2.0';
              final buildNumber = snapshot.data?.buildNumber;
              final versionText =
                  (buildNumber != null && buildNumber.isNotEmpty)
                  ? 'Orbit v$version+$buildNumber'
                  : 'Orbit v$version';
              return Center(
                child: Text(
                  versionText,
                  style: GoogleFonts.firaCode(
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.white.withValues(alpha: 0.05),
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
