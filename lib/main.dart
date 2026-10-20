import 'package:flutter/foundation.dart';
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
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:orbit/core/localization/app_translations.dart';
import 'package:orbit/features/terminal/providers/terminal_provider.dart';
import 'package:orbit/features/files/providers/file_browser_provider.dart';

Future<void> openServersBox([SecureStorageService? storageService]) async {
  if (Hive.isBoxOpen('servers')) return;

  final storage = storageService ?? SecureStorageService();
  List<int>? encryptionKey = await storage.readHiveKey();

  if (encryptionKey == null) {
    debugPrint('Hive: Generating new secure encryption key');
    encryptionKey = Hive.generateSecureKey();
    await storage.saveHiveKey(encryptionKey);
  }

  await Hive.openBox<HiveServer>(
    'servers',
    encryptionCipher: HiveAesCipher(encryptionKey),
  );
  debugPrint('Hive: Encrypted box "servers" opened successfully');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // [SEC-007]: Override debugPrint in release mode so zero logs leak to logcat
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveServerAdapter());
    }

    try {
      await openServersBox();
    } catch (e) {
      // [SEC-002]: Never auto-delete 'servers' box on transient Keystore / decryption errors!
      debugPrint(
        'Hive: Error opening encrypted "servers" box during startup: $e',
      );
    }
  } catch (e) {
    debugPrint('Hive initialization error: $e');
  }

  runApp(const ProviderScope(child: MyApp()));
}

enum AuthState {
  loading,
  pinSetup,
  biometricPrompt,
  pinUnlock,
  passed,
  storageError,
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.backgroundStopwatchFactory});

  final Stopwatch Function()? backgroundStopwatchFactory;

  @visibleForTesting
  static Stopwatch Function() createStopwatch = Stopwatch.new;

  @visibleForTesting
  static DateTime Function() lifecycleClock = DateTime.now;

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  AuthState _authState = AuthState.loading;
  bool _isChecking = false;
  DateTime? _backgroundTimestamp;
  Stopwatch? _backgroundStopwatch;
  String? _storageErrorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _determineAuthState());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // [SEC-012, SEC-004]: Track backgrounding with monotonic Stopwatch and lock after >= 15 seconds
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_authState == AuthState.passed) {
        _backgroundStopwatch =
            (widget.backgroundStopwatchFactory ?? MyApp.createStopwatch)();
        _backgroundStopwatch!.start();
        _backgroundTimestamp = MyApp.lifecycleClock();
      }
    } else if (state == AppLifecycleState.resumed) {
      bool shouldLock = false;

      // 1. Primary monotonic check: immune to wall clock backward rollbacks [SEC-004]
      if (_backgroundStopwatch != null) {
        _backgroundStopwatch!.stop();
        if (_backgroundStopwatch!.elapsed.inSeconds >= 15) {
          shouldLock = true;
        }
        _backgroundStopwatch = null;
      }

      // 2. Lifecycle clock fallback / unit-testing hook
      if (_backgroundTimestamp != null) {
        final elapsed = MyApp.lifecycleClock().difference(
          _backgroundTimestamp!,
        );
        _backgroundTimestamp = null;
        if (elapsed.inSeconds >= 15) {
          shouldLock = true;
        }
      }

      if (shouldLock) {
        // Disconnect active terminal SSH and SFTP file sessions when app locks [LOGIC-008]
        ref.read(terminalProvider.notifier).disconnect();
        ref.read(fileBrowserStateProvider.notifier).disconnect();
        if (mounted) {
          setState(() {
            _authState = AuthState.pinUnlock;
          });
          _determineAuthState();
        }
      }
    }
  }

  Future<void> _determineAuthState() async {
    if (_isChecking || _authState == AuthState.passed) return;
    setState(() => _isChecking = true);

    try {
      final storage = ref.read(secureStorageServiceProvider);

      // 1. Ensure servers Hive box is open [SEC-002]
      if (!Hive.isBoxOpen('servers')) {
        try {
          await openServersBox(storage);
        } catch (e) {
          debugPrint('Storage error: Failed to open servers box: $e');
          if (mounted) {
            setState(() {
              _authState = AuthState.storageError;
              _storageErrorMessage =
                  'Android Keystore failed to decrypt the database: $e';
            });
          }
          return;
        }
      }

      // 2. Check if master PIN is configured
      bool pinIsSet;
      try {
        pinIsSet = await storage.hasMasterPin();
      } catch (e) {
        debugPrint(
          'Storage error: Failed to read master PIN from keystore: $e',
        );
        if (mounted) {
          setState(() {
            _authState = AuthState.storageError;
            _storageErrorMessage =
                'Secure Keystore error reading master PIN: $e';
          });
        }
        return;
      }

      // [SEC-003]: Only enter AuthState.pinSetup when hasMasterPin() explicitly completes and returns false!
      if (!pinIsSet) {
        if (mounted) {
          setState(() {
            _authState = AuthState.pinSetup;
          });
        }
        return;
      }

      // 3. Biometric / PIN unlock verification
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
      // [SEC-003]: NEVER fall back to pinSetup! Fail closed to pinUnlock.
      if (mounted) {
        setState(() {
          _authState = AuthState.pinUnlock;
        });
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _retryUnlock() async {
    setState(() {
      _authState = AuthState.loading;
      _storageErrorMessage = null;
    });
    await _determineAuthState();
  }

  Future<void> _resetDatabase() async {
    try {
      if (Hive.isBoxOpen('servers')) {
        await Hive.box<HiveServer>('servers').close();
      }
      await Hive.deleteBoxFromDisk('servers');
      final storage = ref.read(secureStorageServiceProvider);
      final newKey = Hive.generateSecureKey();
      await storage.saveHiveKey(newKey);
      await Hive.openBox<HiveServer>(
        'servers',
        encryptionCipher: HiveAesCipher(newKey),
      );
      if (mounted) {
        setState(() {
          _authState = AuthState.loading;
          _storageErrorMessage = null;
        });
        await _determineAuthState();
      }
    } catch (e) {
      debugPrint('Error resetting database: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset database: $e'),
            backgroundColor: AppTheme.critical,
          ),
        );
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
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
      locale: Locale(languageCode),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: AppTranslations.supportedLocales,
      builder: (context, child) {
        // Wait for settings to load before rendering anything
        if (isSettingsLoading || _authState == AuthState.loading) {
          return const _SplashScreen();
        }

        // Storage Error Recovery Screen [SEC-002]
        if (_authState == AuthState.storageError) {
          return _StorageErrorRecoveryScreen(
            errorMessage: _storageErrorMessage,
            onRetry: _retryUnlock,
            onReset: _resetDatabase,
          );
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

/// Recovery screen rendered when encrypted Hive storage or Keystore fails [SEC-002]
class _StorageErrorRecoveryScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onReset;

  const _StorageErrorRecoveryScreen({
    this.errorMessage,
    required this.onRetry,
    required this.onReset,
  });

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTheme.critical.withValues(alpha: 0.3)),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.critical),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Reset Database?',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'This will permanently delete all saved server profiles and configurations from this device. Your data cannot be recovered.\n\nAre you sure you want to proceed?',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.critical,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onReset();
              },
              child: const Text('Delete & Reset'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (_) =>
          MaterialPageRoute(builder: (navContext) => _buildContent(navContext)),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.critical.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.critical.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.critical.withValues(alpha: 0.2),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 38,
                    color: AppTheme.critical,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Secure Storage Error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Android Keystore failed to unlock the encrypted database. This can happen due to a transient system lock or keystore desynchronization.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (errorMessage != null && errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.critical.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.terminalMint,
                      foregroundColor: AppTheme.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'Retry Unlock',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.critical,
                      side: BorderSide(
                        color: AppTheme.critical.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => _showResetConfirmation(context),
                    icon: const Icon(Icons.delete_forever_rounded),
                    label: const Text(
                      'Reset Database (Deletes Saved Servers)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
