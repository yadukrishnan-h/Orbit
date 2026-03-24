import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/router/app_router.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/providers/connection_status_provider.dart';
import 'package:orbit/core/widgets/loading_overlay.dart';
import 'package:orbit/core/localization/app_localization.dart';
import 'package:orbit/features/settings/providers/settings_provider.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/features/auth/presentation/screens/pin_setup_screen.dart';
import 'package:orbit/features/auth/presentation/screens/pin_unlock_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:orbit/core/data/entities/hive_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveServerAdapter());
    }

    // ── Hive Encryption [Task 2] ─────────────────────────────────────────
    final storage = SecureStorageService();
    List<int>? encryptionKey = await storage.readHiveKey();

    if (encryptionKey == null) {
      debugPrint('Hive: Generating new secure encryption key');
      encryptionKey = Hive.generateSecureKey();
      await storage.saveHiveKey(encryptionKey);
    }

    try {
      await Hive.openBox<HiveServer>(
        'servers',
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      debugPrint('Hive: Encrypted box "servers" opened successfully');
    } catch (e) {
      debugPrint('Hive: Encryption error (likely migration needed): $e');
      // If we can't open it (e.g. it's unencrypted), delete and start fresh
      await Hive.deleteBoxFromDisk('servers');
      await Hive.openBox<HiveServer>(
        'servers',
        encryptionCipher: HiveAesCipher(encryptionKey),
      );
      debugPrint('Hive: Box recreated with encryption');
    }
  } catch (e) {
    debugPrint('Hive initialization error: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

enum AuthState { loading, pinSetup, biometricPrompt, pinUnlock, passed }

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  AuthState _authState = AuthState.loading;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _determineAuthState());
  }

  Future<void> _determineAuthState() async {
    if (_isChecking || _authState == AuthState.passed) return;
    setState(() => _isChecking = true);

    try {
      final storage = ref.read(secureStorageServiceProvider);
      final masterPin = await storage.readMasterPin();

      if (masterPin == null || masterPin.isEmpty || masterPin == 'null') {
        if (mounted) {
          setState(() {
            _authState = AuthState.pinSetup;
            _isChecking = false;
          });
        }
        return;
      }

      final settings = await ref.read(settingsProvider.future);

      if (settings.isBiometricsEnabled) {
        if (mounted) setState(() => _authState = AuthState.biometricPrompt);

        final biometricService = ref.read(biometricServiceProvider);
        final passed = await biometricService.authenticate(
          reason: 'Authenticate to access Orbit',
        );

        if (mounted) {
          if (passed) {
            setState(() => _authState = AuthState.passed);
          } else {
            // Fallback to PIN
            setState(() => _authState = AuthState.pinUnlock);
          }
        }
      } else {
        if (mounted) setState(() => _authState = AuthState.pinUnlock);
      }
    } catch (e) {
      debugPrint('Error determining auth state: $e');
      if (mounted) {
        setState(() {
          _authState = AuthState.pinSetup;
        });
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
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
        if (isSettingsLoading || _authState == AuthState.loading) {
          return const _SplashScreen();
        }

        // Authentication Gates
        if (_authState == AuthState.pinSetup) {
          return PinSetupScreen(
            onSuccess: () => setState(() => _authState = AuthState.passed),
          );
        }

        if (_authState == AuthState.pinUnlock) {
          return PinUnlockScreen(
            onSuccess: () => setState(() => _authState = AuthState.passed),
          );
        }

        if (_authState == AuthState.biometricPrompt) {
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
      body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
    );
  }
}

/// Shown when biometrics are running
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
