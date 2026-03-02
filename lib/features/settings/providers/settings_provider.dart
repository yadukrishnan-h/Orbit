import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/services/biometric_service.dart';
import 'package:orbit/features/settings/models/app_settings.dart';
import 'package:orbit/features/settings/viewmodels/settings_viewmodel.dart';

/// Primary settings provider — exposes AsyncValue of AppSettings.
final settingsProvider =
    AsyncNotifierProvider<SettingsViewModel, AppSettings>(() {
  return SettingsViewModel();
});

/// Convenience provider for the current poll interval (seconds).
/// Defaults to 3 while loading.
final pollIntervalProvider = Provider<int>((ref) {
  return ref.watch(settingsProvider).maybeWhen(
        data: (settings) => settings.pollIntervalSeconds,
        orElse: () => 3,
      );
});

/// Convenience provider for the biometrics enabled flag.
final biometricsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).maybeWhen(
        data: (settings) => settings.isBiometricsEnabled,
        orElse: () => false,
      );
});

/// Singleton biometric service provider.
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});
