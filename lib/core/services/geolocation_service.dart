import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/utils/app_logger.dart';

class GeolocationService {
  final SecureStorageService _secureStorage;

  GeolocationService([SecureStorageService? secureStorage])
    : _secureStorage =
          secureStorage ?? _defaultStorage ?? SecureStorageService();

  static SecureStorageService? _defaultStorage;

  @visibleForTesting
  static void setDefaultStorage(SecureStorageService? storage) {
    _defaultStorage = storage;
  }

  static const String _kGeolocationSetting = 'settings_geolocation';
  static const String _kCacheBoxName = 'geolocation_cache';

  // In-memory cache for fast lookups during the app session
  static final Map<String, String> _memoryCache = {};
  static Box<String>? _cacheBox;

  // Reusable HttpClient with strict timeouts to prevent socket descriptor leaks
  static HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 5);

  @visibleForTesting
  static set client(HttpClient client) => _client = client;

  @visibleForTesting
  static void resetForTesting() {
    _memoryCache.clear();
    _cacheBox = null;
    _defaultStorage = null;
  }

  static Future<Box<String>> _getCacheBox([
    SecureStorageService? storageOverride,
  ]) async {
    if (_cacheBox != null && _cacheBox!.isOpen) {
      return _cacheBox!;
    }

    final storage =
        storageOverride ?? _defaultStorage ?? SecureStorageService();
    var encryptionKey = await storage.readHiveKey();
    if (encryptionKey == null) {
      encryptionKey = Hive.generateSecureKey();
      await storage.saveHiveKey(encryptionKey);
    }

    try {
      _cacheBox = await Hive.openBox<String>(
        _kCacheBoxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      return _cacheBox!;
    } catch (e) {
      AppLogger.warning(
        'Geolocation: Encrypted box open failed, migrating legacy cache: $e',
      );
      try {
        // [SEC-008]: Safe to delete only geolocation_cache as it is a transient IP lookup cache
        await Hive.deleteBoxFromDisk(_kCacheBoxName);
        _cacheBox = await Hive.openBox<String>(
          _kCacheBoxName,
          encryptionCipher: HiveAesCipher(encryptionKey),
        );
        return _cacheBox!;
      } catch (e2) {
        AppLogger.error('Geolocation: Failed to recreate cache box', e2);
        rethrow;
      }
    }
  }

  /// Fetches geolocation data for [ip] using the injected [SecureStorageService].
  Future<String> getLocation(String ip, {bool? isUserOptedIn}) {
    return getLocationFromIp(
      ip,
      isUserOptedIn: isUserOptedIn,
      storage: _secureStorage,
    );
  }

  /// Fetches geolocation data for a given IP address using https://ipwho.is.
  ///
  /// Respects user privacy:
  /// - Only executes if the user has explicitly opted in via Settings.
  /// - External lookups occur at most once per IP; responses are cached permanently in encrypted Hive.
  /// - Sockets are strictly pooled or cleaned up.
  ///
  /// Returns a formatted string: "Country (CountryCode) - City"
  /// Fallbacks to "Local Network", "", or "Unknown" appropriately.
  static Future<String> getLocationFromIp(
    String ip, {
    bool? isUserOptedIn,
    SecureStorageService? storage,
  }) async {
    if (ip.isEmpty) return 'Unknown';

    // Fast-path: local / RFC 1918 private IP detection
    if (_isPrivateOrLocalIp(ip)) {
      return 'Local Network';
    }

    // Check user consent (Privacy / GDPR)
    final optedIn = isUserOptedIn ?? await _checkUserConsent();
    if (!optedIn) {
      return '';
    }

    // 1. Check in-memory cache
    if (_memoryCache.containsKey(ip)) {
      return _memoryCache[ip]!;
    }

    // 2. Check encrypted Hive cache
    try {
      final box = await _getCacheBox(storage);
      final cached = box.get(ip);
      if (cached != null && cached.isNotEmpty) {
        _memoryCache[ip] = cached;
        return cached;
      }
    } catch (e) {
      AppLogger.warning('Geolocation: Cache lookup error: $e');
    }

    // 3. Make external network call over secure HTTPS (ipwho.is) [SEC-018]
    try {
      final uri = Uri.parse('https://ipwho.is/$ip');
      final request = await _client
          .getUrl(uri)
          .timeout(const Duration(seconds: 5));
      final response = await request.close().timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);

        if (data is Map &&
            (data['success'] == true || data['status'] == 'success')) {
          final country = data['country']?.toString() ?? 'Unknown Country';
          final countryCode =
              (data['country_code'] ?? data['countryCode'] ?? '').toString();
          final city = data['city']?.toString() ?? 'Unknown City';

          final result = countryCode.isNotEmpty
              ? '$country ($countryCode) - $city'
              : '$country - $city';

          _memoryCache[ip] = result;
          try {
            final box = await _getCacheBox(storage);
            await box.put(ip, result);
          } catch (e) {
            AppLogger.warning('Geolocation: Cache write error: $e');
          }

          return result;
        } else {
          debugPrint('Geolocation API returned failed status: $data');
        }
      } else {
        debugPrint('Geolocation HTTP Code Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Geolocation Error: $e');
    }

    return 'Unknown';
  }

  static bool _isPrivateOrLocalIp(String ip) {
    return ip.startsWith('192.168.') ||
        ip.startsWith('10.') ||
        ip.startsWith('127.') ||
        ip.startsWith('172.16.') ||
        ip.startsWith('172.17.') ||
        ip.startsWith('172.18.') ||
        ip.startsWith('172.19.') ||
        ip.startsWith('172.20.') ||
        ip.startsWith('172.21.') ||
        ip.startsWith('172.22.') ||
        ip.startsWith('172.23.') ||
        ip.startsWith('172.24.') ||
        ip.startsWith('172.25.') ||
        ip.startsWith('172.26.') ||
        ip.startsWith('172.27.') ||
        ip.startsWith('172.28.') ||
        ip.startsWith('172.29.') ||
        ip.startsWith('172.30.') ||
        ip.startsWith('172.31.') ||
        ip == 'localhost' ||
        ip == '::1';
  }

  static Future<bool> _checkUserConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kGeolocationSetting) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Closes the shared HttpClient (call during app teardown if needed)
  static void dispose() {
    _client.close(force: true);
  }
}

/// Global provider for [GeolocationService] with injected [SecureStorageService] [SEC-009].
final geolocationServiceProvider = Provider<GeolocationService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  return GeolocationService(secureStorage);
});
