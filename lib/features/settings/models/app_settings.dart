/// Global app settings model.
/// Persisted via SharedPreferences; loaded at startup.
class AppSettings {
  final String languageCode;
  final int pollIntervalSeconds;
  final bool isBiometricsEnabled;

  const AppSettings({
    this.languageCode = 'en',
    this.pollIntervalSeconds = 3,
    this.isBiometricsEnabled = false,
  });

  AppSettings copyWith({
    String? languageCode,
    int? pollIntervalSeconds,
    bool? isBiometricsEnabled,
  }) {
    return AppSettings(
      languageCode: languageCode ?? this.languageCode,
      pollIntervalSeconds: pollIntervalSeconds ?? this.pollIntervalSeconds,
      isBiometricsEnabled: isBiometricsEnabled ?? this.isBiometricsEnabled,
    );
  }

  /// Human-readable language name for UI display
  String get languageDisplayName {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'zh':
        return '中文 (Mandarin)';
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  /// Supported languages list
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'zh', 'name': '中文 (Mandarin)'},
    {'code': 'hi', 'name': 'हिन्दी (Hindi)'},
    {'code': 'fr', 'name': 'Français'},
  ];

  /// Supported poll intervals in seconds
  static const List<int> pollIntervals = [1, 3, 5, 10, 30];
}
