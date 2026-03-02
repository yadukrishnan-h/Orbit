import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/settings/models/app_settings.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

/// Auto-refresh (poll interval) selection tile
class PollIntervalTile extends ConsumerWidget {
  const PollIntervalTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    final currentInterval = settingsAsync.maybeWhen(
      data: (s) => s.pollIntervalSeconds,
      orElse: () => 3,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const Icon(LucideIcons.refreshCw,
          color: AppTheme.textSecondary, size: 20),
      title: Text(
        ref.tr('auto_refresh'),
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Every ${currentInterval}s',
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(LucideIcons.chevronRight,
          color: AppTheme.textSecondary, size: 18),
      onTap: () => _showIntervalDialog(context, ref, currentInterval),
    );
  }

  Future<void> _showIntervalDialog(
      BuildContext context, WidgetRef ref, int currentInterval) async {
    int selected = currentInterval;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTheme.border),
            ),
            title: Text(
              ref.tr('auto_refresh_interval'),
              style: GoogleFonts.inter(
                  color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
            content: RadioGroup<int>(
              groupValue: selected,
              onChanged: (val) {
                if (val != null) setState(() => selected = val);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: AppSettings.pollIntervals.map((secs) {
                  return RadioListTile<int>(
                    value: secs,
                    title: Text(
                      secs == 1
                          ? ref.tr('1_second')
                          : '$secs ${ref.tr('n_seconds').replaceFirst('%d', '')}',
                      style: GoogleFonts.inter(color: AppTheme.textPrimary),
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(ref.tr('cancel'),
                    style: GoogleFonts.inter(color: AppTheme.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  ref.read(settingsProvider.notifier).setPollInterval(selected);
                  Navigator.pop(ctx);
                },
                child: Text(ref.tr('apply'),
                    style: GoogleFonts.inter(color: AppTheme.primary)),
              ),
            ],
          );
        });
      },
    );
  }
}
