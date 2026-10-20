import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsViewModel State Safety Tests [LOGIC-010]', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'Updating settings does not throw StateError on early invocation',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final notifier = container.read(settingsProvider.notifier);

        // Invoke setters immediately before awaiting build or while loading
        await expectLater(notifier.setLanguage('de'), completes);
        await expectLater(notifier.setPollInterval(10), completes);
        await expectLater(notifier.setBiometricsEnabled(true), completes);
        await expectLater(notifier.setGeolocationEnabled(true), completes);

        final state = await container.read(settingsProvider.future);
        expect(state.languageCode, 'de');
        expect(state.pollIntervalSeconds, 10);
        expect(state.isBiometricsEnabled, isTrue);
        expect(state.isGeolocationEnabled, isTrue);
      },
    );
  });
}
