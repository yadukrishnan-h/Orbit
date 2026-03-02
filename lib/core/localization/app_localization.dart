import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/localization/app_translations.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

/// Provider exposing the current language code.
/// Reads from settingsProvider; defaults to 'en' while loading.
final currentLanguageProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).maybeWhen(
        data: (s) => s.languageCode,
        orElse: () => 'en',
      );
});

/// Extension on [BuildContext] for easy in-widget translation.
///
/// Usage (inside a ConsumerWidget or ConsumerState):
///   ref.tr(context, 'key')
///
/// Or via helper widget method using BuildContext + WidgetRef together.
extension AppLocalization on WidgetRef {
  /// Translate [key] using the currently selected language.
  /// Falls back to English for missing keys.
  String tr(String key) {
    final lang = watch(currentLanguageProvider);
    return AppTranslations.translate(key, lang);
  }

  /// Translate [key] without watching (for one-shot reads, e.g. in callbacks).
  String trRead(String key) {
    final lang = read(currentLanguageProvider);
    return AppTranslations.translate(key, lang);
  }
}

/// Standalone helper for non-Riverpod contexts (pass languageCode explicitly).
String trDirect(String key, String languageCode) {
  return AppTranslations.translate(key, languageCode);
}
