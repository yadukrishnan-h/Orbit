import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/settings/models/app_settings.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

/// Language selection tile
class LanguageTile extends ConsumerWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    final currentLang = settingsAsync.maybeWhen(
      data: (s) => s.languageDisplayName,
      orElse: () => 'English',
    );
    final currentCode = settingsAsync.maybeWhen(
      data: (s) => s.languageCode,
      orElse: () => 'en',
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.globe, color: Colors.white, size: 18),
      ),
      title: Text(
        ref.tr('language'),
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        currentLang,
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(
        LucideIcons.chevronRight,
        color: AppTheme.textSecondary,
        size: 18,
      ),
      onTap: () => _showLanguageDialog(context, ref, currentCode),
    );
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentCode,
  ) async {
    String selected = currentCode;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF141518),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 0.5,
                ),
              ),
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.sizeOf(ctx).width * 0.075,
                vertical: 24.0,
              ),
              title: Text(
                ref.tr('select_language'),
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.sizeOf(ctx).width * 0.85,
                child: RadioGroup<String>(
                  groupValue: selected,
                  onChanged: (val) {
                    if (val != null) setState(() => selected = val);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: AppSettings.supportedLanguages.map((lang) {
                      return RadioListTile<String>(
                        value: lang['code']!,
                        activeColor: AppTheme.terminalMint,
                        title: Text(
                          lang['name']!,
                          style: GoogleFonts.inter(color: AppTheme.textPrimary),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    ref.tr('cancel'),
                    style: GoogleFonts.inter(color: AppTheme.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(settingsProvider.notifier).setLanguage(selected);
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    ref.tr('apply'),
                    style: GoogleFonts.inter(
                      color: AppTheme.terminalMint,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
