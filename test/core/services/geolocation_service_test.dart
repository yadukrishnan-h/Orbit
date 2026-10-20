import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:orbit/core/services/geolocation_service.dart';

class MockHttpClient extends Fake implements HttpClient {
  Uri? lastRequestedUri;
  int statusCode = 200;
  String responseBody =
      '{"success": true, "country": "United States", "country_code": "US", "city": "Mountain View"}';

  @override
  Duration? connectionTimeout;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    lastRequestedUri = url;
    return MockHttpClientRequest(statusCode, responseBody);
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  final int statusCode;
  final String body;

  MockHttpClientRequest(this.statusCode, this.body);

  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse(statusCode, body);
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  final int statusCode;
  final String body;

  MockHttpClientResponse(this.statusCode, this.body);

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return Stream<List<int>>.value(
      utf8.encode(body),
    ).transform(streamTransformer);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GeolocationService Tests', () {
    late MockHttpClient mockClient;
    late Directory tempDir;

    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      tempDir = await Directory.systemTemp.createTemp('hive_geo_test_');
      Hive.init(tempDir.path);
      mockClient = MockHttpClient();
      GeolocationService.client = mockClient;
      GeolocationService.resetForTesting();
    });

    tearDown(() async {
      GeolocationService.resetForTesting();
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'Local/private IPs return Local Network without network calls',
      () async {
        expect(
          await GeolocationService.getLocationFromIp('192.168.1.1'),
          'Local Network',
        );
        expect(
          await GeolocationService.getLocationFromIp('10.0.0.1'),
          'Local Network',
        );
        expect(
          await GeolocationService.getLocationFromIp('127.0.0.1'),
          'Local Network',
        );
        expect(
          await GeolocationService.getLocationFromIp('localhost'),
          'Local Network',
        );
        expect(mockClient.lastRequestedUri, isNull);
      },
    );

    test('Returns empty string when user is not opted in', () async {
      final result = await GeolocationService.getLocationFromIp(
        '8.8.8.8',
        isUserOptedIn: false,
      );
      expect(result, '');
      expect(mockClient.lastRequestedUri, isNull);
    });

    test('Empty IP returns Unknown', () async {
      final result = await GeolocationService.getLocationFromIp('');
      expect(result, 'Unknown');
      expect(mockClient.lastRequestedUri, isNull);
    });

    test(
      'Uses secure HTTPS ipwho.is endpoint and parses country, country_code, city',
      () async {
        mockClient.statusCode = 200;
        mockClient.responseBody = jsonEncode({
          'success': true,
          'country': 'Germany',
          'country_code': 'DE',
          'city': 'Frankfurt',
        });

        final result = await GeolocationService.getLocationFromIp(
          '1.2.3.4',
          isUserOptedIn: true,
        );

        // Verify HTTPS URL [SEC-018]
        expect(mockClient.lastRequestedUri, isNotNull);
        expect(mockClient.lastRequestedUri!.scheme, 'https');
        expect(mockClient.lastRequestedUri!.host, 'ipwho.is');
        expect(mockClient.lastRequestedUri!.path, '/1.2.3.4');

        // Verify formatted result
        expect(result, 'Germany (DE) - Frankfurt');
      },
    );

    test('Handles ipwho.is failed status safely without crashing', () async {
      mockClient.statusCode = 200;
      mockClient.responseBody = jsonEncode({
        'success': false,
        'message': 'Reserved IP range',
      });

      final result = await GeolocationService.getLocationFromIp(
        '240.0.0.1',
        isUserOptedIn: true,
      );

      expect(result, 'Unknown');
    });

    test('Handles HTTP non-200 status code safely', () async {
      mockClient.statusCode = 500;
      mockClient.responseBody = 'Server error';

      final result = await GeolocationService.getLocationFromIp(
        '9.9.9.9',
        isUserOptedIn: true,
      );

      expect(result, 'Unknown');
    });
  });
}
