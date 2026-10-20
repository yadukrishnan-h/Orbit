import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

/// Biometric authentication toggle tile [SEC-005].
/// Requires biometric authentication (or Master PIN verification fallback)
/// both when enabling AND when disabling biometric lock.
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
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          LucideIcons.fingerprint,
          color: Colors.white,
          size: 18,
        ),
      ),
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
      activeThumbColor: AppTheme.terminalMint,
      activeTrackColor: AppTheme.terminalMint.withValues(alpha: 0.25),
      onChanged: (value) => _handleToggle(context, ref, value),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    WidgetRef ref,
    bool newValue,
  ) async {
    final biometricService = ref.read(biometricServiceProvider);
    final available = await biometricService.isAvailable();

    bool authenticated = false;

    if (available) {
      final reason = newValue
          ? 'Authenticate to enable biometric lock for Orbit'
          : 'Authenticate to disable biometric lock for Orbit';
      authenticated = await biometricService.authenticate(reason: reason);
    }

    if (!context.mounted) return;

    if (!authenticated) {
      // Prompt Master PIN verification fallback [SEC-005]
      final pinVerified = await _promptMasterPinFallback(
        context,
        ref,
        newValue,
      );
      if (!pinVerified) return; // User cancelled or entered incorrect PIN
    }

    await ref.read(settingsProvider.notifier).setBiometricsEnabled(newValue);
  }

  Future<bool> _promptMasterPinFallback(
    BuildContext context,
    WidgetRef ref,
    bool enabling,
  ) async {
    final pinController = TextEditingController();
    String? errorMessage;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF18181B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF27272A)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  LucideIcons.lock,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  enabling ? 'Enable Biometric Lock' : 'Disable Biometric Lock',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter your Master PIN to confirm changing biometric security settings.',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pinController,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: GoogleFonts.firaCode(
                  color: Colors.white,
                  fontSize: 20,
                  letterSpacing: 8,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: GoogleFonts.firaCode(
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: AppTheme.formInputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF27272A)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primary),
                  ),
                ),
                onSubmitted: (_) async {
                  final pin = pinController.text.trim();
                  if (pin.length != 4) return;
                  final verified = await ref
                      .read(secureStorageServiceProvider)
                      .verifyMasterPin(pin);
                  if (verified) {
                    if (ctx.mounted) Navigator.of(ctx).pop(true);
                  } else {
                    setDialogState(() {
                      errorMessage = 'Incorrect Master PIN';
                      pinController.clear();
                    });
                  }
                },
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage!,
                  style: GoogleFonts.inter(
                    color: AppTheme.critical,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFA1A1AA),
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                final pin = pinController.text.trim();
                if (pin.length != 4) {
                  setDialogState(() {
                    errorMessage = 'Please enter your 4-digit PIN';
                  });
                  return;
                }
                final verified = await ref
                    .read(secureStorageServiceProvider)
                    .verifyMasterPin(pin);
                if (verified) {
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                } else {
                  setDialogState(() {
                    errorMessage = 'Incorrect Master PIN';
                    pinController.clear();
                  });
                }
              },
              child: const Text(
                'Verify PIN',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );

    return result ?? false;
  }
}
