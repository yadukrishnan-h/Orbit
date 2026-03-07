import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

/// Biometric authentication toggle tile.
/// Prompts local_auth before enabling; stores result in settings.
class BiometricsTile extends ConsumerWidget {
  const BiometricsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final isEnabled = settingsAsync.maybeWhen(
      data: (s) => s.isBiometricsEnabled,
      orElse: () => false,
    );

    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: const Icon(LucideIcons.fingerprint,
          color: AppTheme.textSecondary, size: 20),
      title: Text(
        ref.tr('biometric_auth'),
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        isEnabled ? ref.tr('biometric_enabled') : ref.tr('biometric_disabled'),
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
      ),
      value: isEnabled,
      activeThumbColor: AppTheme.primary,
      onChanged: (value) => _handleToggle(context, ref, value),
    );
  }

  Future<void> _handleToggle(
      BuildContext context, WidgetRef ref, bool newValue) async {
    if (newValue) {
      // Enabling: prompt biometric to confirm user intends this
      final biometricService = ref.read(biometricServiceProvider);
      final available = await biometricService.isAvailable();

      if (!available) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.surface,
              content: Text(
                'No biometrics enrolled on this device.',
                style: GoogleFonts.inter(color: AppTheme.textPrimary),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      final authenticated = await biometricService.authenticate(
        reason: 'Authenticate to enable biometric lock for Orbit',
      );

      if (!authenticated) return; // User cancelled — do not enable
    }

    await ref.read(settingsProvider.notifier).setBiometricsEnabled(newValue);
  }
}
