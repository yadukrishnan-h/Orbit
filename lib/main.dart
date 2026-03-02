import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/router/app_router.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/providers/connection_status_provider.dart';
import 'package:orbit/core/widgets/loading_overlay.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  /// Whether the biometric challenge has been passed this session.
  bool _biometricPassed = false;

  /// Whether we're currently showing the biometric prompt.
  bool _challenging = false;

  @override
  void initState() {
    super.initState();
    // Trigger a biometric check shortly after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkBiometrics());
  }

  Future<void> _checkBiometrics() async {
    if (_biometricPassed || _challenging) return;

    // Wait until settings have loaded
    final settings = await ref.read(settingsProvider.future);

    if (!settings.isBiometricsEnabled) {
      if (mounted) setState(() => _biometricPassed = true);
      return;
    }

    setState(() => _challenging = true);

    final biometricService = ref.read(biometricServiceProvider);
    final passed = await biometricService.authenticate(
      reason: 'Authenticate to access Orbit',
    );

    if (mounted) {
      setState(() {
        _biometricPassed = passed;
        _challenging = false;
      });

      // Retry if failed (prevent app use without authentication)
      if (!passed) {
        await Future.delayed(const Duration(milliseconds: 500));
        _checkBiometrics();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionStatusProvider);
    final isSettingsLoading = ref.watch(settingsProvider).isLoading;
    final languageCode = ref.watch(currentLanguageProvider);

    return MaterialApp.router(
      title: 'Orbit',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      locale: Locale(languageCode),
      builder: (context, child) {
        // Wait for settings to load before rendering anything
        if (isSettingsLoading) {
          return const _SplashScreen();
        }

        // Show biometric gate
        if (!_biometricPassed) {
          return const _BiometricGateScreen();
        }

        // Show loading overlay while connecting
        if (connectionState.isConnecting) {
          return LoadingOverlay(
            title: 'Establishing Connection',
            subtitle: 'Connecting to server and loading data...',
            progress: connectionState.progress,
          );
        }

        // Show error state if connection failed
        if (connectionState.hasError) {
          return LoadingOverlay(
            title: 'Connection Failed',
            subtitle: 'Unable to establish connection with the server',
            errorMessage: connectionState.errorMessage,
            showError: true,
            onRetry: () {
              ref.read(connectionStatusProvider.notifier).retryConnection();
            },
          );
        }

        // Return the normal app content
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// Minimal loading screen shown while SharedPreferences hydrates
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      ),
    );
  }
}

/// Shown when biometrics are enabled but not yet passed
class _BiometricGateScreen extends StatelessWidget {
  const _BiometricGateScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 72, color: AppTheme.primary),
            SizedBox(height: 20),
            Text(
              'Authentication Required',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Waiting for biometric confirmation...',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
