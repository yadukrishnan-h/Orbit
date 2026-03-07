import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class GeolocationService {
  /// Fetches geolocation data for a given IP address using ip-api.com.
  /// Returns a formatted string: "Country (CountryCode) - City"
  /// Fallbacks to "Local Network" or "Unknown" appropriately.
  static Future<String> getLocationFromIp(String ip) async {
    if (ip.isEmpty) return 'Unknown';

    // Simple check for local/private IPs
    if (ip.startsWith('192.168.') ||
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
        ip.startsWith('172.31.')) {
      return 'Local Network';
    }

    try {
      final request =
          await HttpClient().getUrl(Uri.parse('http://ip-api.com/json/$ip'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);

        if (data['status'] == 'success') {
          final country = data['country'] ?? 'Unknown Country';
          final countryCode = data['countryCode'] ?? '';
          final city = data['city'] ?? 'Unknown City';

          if (countryCode.isNotEmpty) {
            return '$country ($countryCode) - $city';
          }
          return '$country - $city';
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
}
