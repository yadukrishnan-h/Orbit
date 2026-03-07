import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbit/features/settings/models/app_settings.dart';

// Keys for shared_preferences
const _keyLanguage = 'settings_language';
const _keyPollInterval = 'settings_poll_interval';
const _keyBiometrics = 'settings_biometrics';

/// AsyncNotifier that loads and persists AppSettings via SharedPreferences.
class SettingsViewModel extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    return _load();
  }

  AppSettings _load() {
    return AppSettings(
      languageCode: _prefs.getString(_keyLanguage) ?? 'en',
      pollIntervalSeconds: _prefs.getInt(_keyPollInterval) ?? 3,
      isBiometricsEnabled: _prefs.getBool(_keyBiometrics) ?? false,
    );
  }

  Future<void> setLanguage(String code) async {
    await _prefs.setString(_keyLanguage, code);
    state = AsyncData(state.requireValue.copyWith(languageCode: code));
  }

  Future<void> setPollInterval(int seconds) async {
    await _prefs.setInt(_keyPollInterval, seconds);
    state =
        AsyncData(state.requireValue.copyWith(pollIntervalSeconds: seconds));
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometrics, enabled);
    state =
        AsyncData(state.requireValue.copyWith(isBiometricsEnabled: enabled));
  }
}
