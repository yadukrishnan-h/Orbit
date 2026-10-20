import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/features/auth/presentation/widgets/pin_pad_widget.dart';

class PinUnlockScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const PinUnlockScreen({super.key, required this.onSuccess});

  @override
  ConsumerState<PinUnlockScreen> createState() => _PinUnlockScreenState();
}

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen>
    with WidgetsBindingObserver {
  String _enteredPin = '';
  String? _errorText;
  static const int _pinLength = 4;

  // ── Security Constants ────────────────────────────────────────────────
  static const int _penaltyLockoutSeconds = 300; // 5m anti-tamper penalty

  int _failedAttempts = 0;
  int _remainingLockoutSeconds = 0;
  int _initialLockoutSeconds = 0;
  final Stopwatch _lockoutStopwatch = Stopwatch();
  Timer? _lockoutTimer;
  bool _isTimeTampered = false;
  late SecureStorageService _storageService;

  bool get _isLockedOut => _remainingLockoutSeconds > 0;

  @override
  void initState() {
    super.initState();
    _storageService = ref.read(secureStorageServiceProvider);
    WidgetsBinding.instance.addObserver(this);
    _loadLockoutState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockoutTimer?.cancel();
    _lockoutStopwatch.stop();
    _persistCurrentLockoutRemaining();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.inactive) {
      _persistCurrentLockoutRemaining();
    }
  }

  void _persistCurrentLockoutRemaining() {
    if (_remainingLockoutSeconds > 0) {
      _storageService.saveRemainingLockoutSeconds(_remainingLockoutSeconds);
    }
  }

  Future<void> _loadLockoutState() async {
    final storage = _storageService;
    final results = await Future.wait([
      storage.readFailedAttempts(),
      storage.readRemainingLockoutSeconds(),
      storage.readLockoutTime(),
      storage.readLastFailedAttempt(),
    ]);
    final attempts = results[0] as int;
    final remaining = results[1] as int;
    final lockoutEnd = results[2] as DateTime?;
    final lastFailed = results[3] as DateTime?;
    final now = DateTime.now();

    int calculatedRemaining = 0;
    bool isTampered = false;

    // Check backward clock tamper [SEC-011]
    if (lastFailed != null && now.isBefore(lastFailed)) {
      isTampered = true;
      calculatedRemaining = _penaltyLockoutSeconds;
      await storage.saveRemainingLockoutSeconds(_penaltyLockoutSeconds);
      await storage.saveLockoutTime(
        now.add(const Duration(seconds: _penaltyLockoutSeconds)),
      );
    } else if (lockoutEnd != null) {
      // If lockout expiration timestamp exists, compare with now [SEC-003]
      if (now.isAfter(lockoutEnd)) {
        calculatedRemaining = 0;
        await storage.clearLockoutTimer();
      } else {
        calculatedRemaining = lockoutEnd.difference(now).inSeconds;
      }
    } else if (remaining > 0 && lastFailed != null) {
      final elapsedWallSeconds = now.difference(lastFailed).inSeconds;
      calculatedRemaining = remaining - elapsedWallSeconds;
      if (calculatedRemaining <= 0) {
        calculatedRemaining = 0;
        await storage.clearLockoutTimer();
      }
    } else {
      calculatedRemaining = remaining;
      if (calculatedRemaining <= 0) {
        calculatedRemaining = 0;
      }
    }

    if (mounted) {
      setState(() {
        _failedAttempts = attempts;
        _remainingLockoutSeconds = calculatedRemaining;
        _isTimeTampered = isTampered;
        if (isTampered) {
          _errorText = 'System time manipulation detected. 5m lockout.';
        } else if (calculatedRemaining > 0) {
          _errorText = 'Locked due to previous failed attempts.';
        } else {
          _errorText = null;
        }
      });

      if (calculatedRemaining > 0) {
        _startLockoutTimer(calculatedRemaining);
      }
    }
  }

  void _startLockoutTimer(int initialRemaining) {
    _lockoutTimer?.cancel();
    _initialLockoutSeconds = initialRemaining;
    _lockoutStopwatch
      ..reset()
      ..start();

    if (mounted) {
      setState(() {
        _remainingLockoutSeconds = initialRemaining;
      });
    }

    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final elapsed = _lockoutStopwatch.elapsed.inSeconds;
      final currentRemaining = _initialLockoutSeconds - elapsed;

      if (currentRemaining <= 0) {
        timer.cancel();
        _lockoutStopwatch.stop();
        _storageService.clearLockoutTimer();
        if (mounted) {
          setState(() {
            _remainingLockoutSeconds = 0;
            _errorText = null;
            _isTimeTampered = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _remainingLockoutSeconds = currentRemaining;
          });
        }
      }
    });
  }

  Future<void> _verifyPin() async {
    if (_enteredPin.length != _pinLength || _isLockedOut) return;

    final storage = _storageService;
    final now = DateTime.now();

    // ── Anti-Tamper Check (Clock Moving Backward) ────────────────────────
    final lastAttempt = await storage.readLastFailedAttempt();
    if (lastAttempt != null && now.isBefore(lastAttempt)) {
      debugPrint('Security: Backward system time manipulation detected!');
      await storage.saveRemainingLockoutSeconds(_penaltyLockoutSeconds);
      await storage.saveLockoutTime(
        now.add(const Duration(seconds: _penaltyLockoutSeconds)),
      );

      setState(() {
        _remainingLockoutSeconds = _penaltyLockoutSeconds;
        _isTimeTampered = true;
        _errorText = 'System time manipulation detected. 5m lockout.';
        _enteredPin = '';
      });
      _startLockoutTimer(_penaltyLockoutSeconds);
      return;
    }

    final pinCorrect = await storage.verifyMasterPin(_enteredPin);

    if (pinCorrect) {
      _failedAttempts = 0;
      _remainingLockoutSeconds = 0;
      _lockoutTimer?.cancel();
      _lockoutStopwatch.stop();
      await storage.recordSuccessfulAuth();
      widget.onSuccess();
    } else {
      final lockoutDuration = await storage.recordFailedAttempt();
      final newAttempts = await storage.readFailedAttempts();

      setState(() {
        _failedAttempts = newAttempts;
        _enteredPin = '';
        if (lockoutDuration > 0) {
          _remainingLockoutSeconds = lockoutDuration;
          _errorText =
              'Too many failed attempts. Try again in ${_remainingLockoutSeconds}s.';
          _startLockoutTimer(lockoutDuration);
        } else {
          _errorText =
              'Incorrect PIN. Try again. (${5 - _failedAttempts} attempts left)';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingLockout = _remainingLockoutSeconds;
    final isLocked = _isLockedOut;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Builder(
                  builder: (context) {
                    final accent = isLocked
                        ? AppTheme.critical
                        : AppTheme.terminalMint;
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.25),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.15),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        isLocked
                            ? Icons.lock_clock_rounded
                            : Icons.lock_outline_rounded,
                        size: 38,
                        color: accent,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSizes.p24),
                Text(
                  isLocked ? 'Temporarily Locked' : 'Enter Master PIN',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isLocked && _isTimeTampered
                        ? AppTheme.critical
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  isLocked
                      ? (_isTimeTampered
                            ? 'System time manipulation detected'
                            : 'Please wait $remainingLockout seconds')
                      : 'Secure your app and credentials',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: isLocked
                        ? AppTheme.critical
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.p48),
                AbsorbPointer(
                  absorbing: isLocked,
                  child: Opacity(
                    opacity: isLocked ? 0.5 : 1.0,
                    child: PinPadWidget(
                      pinLength: _pinLength,
                      currentPin: _enteredPin,
                      errorText: _errorText,
                      onPinChanged: (val) {
                        setState(() {
                          _enteredPin = val;
                          _errorText = null;
                        });
                      },
                      onMaxLenReached: _verifyPin,
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
