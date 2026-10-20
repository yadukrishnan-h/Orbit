import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbit/features/settings/models/app_settings.dart';

// Keys for shared_preferences
const _keyLanguage = 'settings_language';
const _keyPollInterval = 'settings_poll_interval';
const _keyBiometrics = 'settings_biometrics';
const _keyGeolocation = 'settings_geolocation';

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
      isGeolocationEnabled: _prefs.getBool(_keyGeolocation) ?? false,
    );
  }

  Future<void> setLanguage(String code) async {
    final current = state.asData?.value ?? await future;
    await _prefs.setString(_keyLanguage, code);
    state = AsyncData(current.copyWith(languageCode: code));
  }

  Future<void> setPollInterval(int seconds) async {
    final current = state.asData?.value ?? await future;
    await _prefs.setInt(_keyPollInterval, seconds);
    state = AsyncData(current.copyWith(pollIntervalSeconds: seconds));
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    final current = state.asData?.value ?? await future;
    await _prefs.setBool(_keyBiometrics, enabled);
    state = AsyncData(current.copyWith(isBiometricsEnabled: enabled));
  }

  Future<void> setGeolocationEnabled(bool enabled) async {
    final current = state.asData?.value ?? await future;
    await _prefs.setBool(_keyGeolocation, enabled);
    state = AsyncData(current.copyWith(isGeolocationEnabled: enabled));
  }
}
