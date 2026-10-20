import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/features/auth/presentation/widgets/pin_pad_widget.dart';

class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends ConsumerState<ChangePinScreen>
    with WidgetsBindingObserver {
  // Phase 1: verify current. Phase 2: enter new. Phase 3: confirm new.
  int _phase = 1;

  String _enteredPin = '';
  String? _newPin;
  String? _errorText;
  static const int _pinLength = 4;

  int _failedAttempts = 0;
  int _remainingLockoutSeconds = 0;
  int _initialLockoutSeconds = 0;
  final Stopwatch _lockoutStopwatch = Stopwatch();
  Timer? _lockoutTimer;
  late SecureStorageService _storageService;

  bool get _isLockedOut => _phase == 1 && _remainingLockoutSeconds > 0;

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

    if (lockoutEnd != null) {
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
      });

      if (_remainingLockoutSeconds > 0) {
        _errorText = 'Locked due to previous failed attempts.';
        _startLockoutTimer(_remainingLockoutSeconds);
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

  void _handlePinComplete() async {
    if (_enteredPin.length != _pinLength) return;

    if (_phase == 1) {
      if (_isLockedOut) return;

      final storage = _storageService;
      final pinCorrect = await storage.verifyMasterPin(_enteredPin);

      if (pinCorrect) {
        _lockoutTimer?.cancel();
        _lockoutStopwatch.stop();
        await storage.recordSuccessfulAuth();
        setState(() {
          _phase = 2;
          _enteredPin = '';
          _errorText = null;
          _failedAttempts = 0;
          _remainingLockoutSeconds = 0;
        });
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
                'Incorrect current PIN. Try again. (${5 - _failedAttempts} attempts left)';
          }
        });
      }
    } else if (_phase == 2) {
      // Enter new PIN
      setState(() {
        _newPin = _enteredPin;
        _enteredPin = '';
        _phase = 3;
        _errorText = null;
      });
    } else if (_phase == 3) {
      // Confirm new PIN
      if (_enteredPin == _newPin) {
        final storage = ref.read(secureStorageServiceProvider);
        await storage.saveMasterPin(_enteredPin);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Master PIN updated successfully')),
          );
          context.pop();
        }
      } else {
        setState(() {
          _errorText = 'PINs do not match. Try again.';
          _enteredPin = '';
          _newPin = null;
          _phase = 2; // back to enter new pin
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleText = '';
    String subtitleText = '';

    if (_phase == 1) {
      titleText = _isLockedOut ? 'Temporarily Locked' : 'Verify Current PIN';
      subtitleText = _isLockedOut
          ? 'Please wait $_remainingLockoutSeconds seconds'
          : 'Enter your current Master PIN';
    } else if (_phase == 2) {
      titleText = 'Create New PIN';
      subtitleText = 'Enter your new 4-digit Master PIN';
    } else if (_phase == 3) {
      titleText = 'Confirm New PIN';
      subtitleText = 'Re-enter your new PIN to confirm';
    }

    final accent = _isLockedOut ? AppTheme.critical : AppTheme.terminalMint;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Change Master PIN',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.background,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
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
                    _isLockedOut
                        ? Icons.lock_clock_rounded
                        : (_phase == 1
                              ? Icons.lock_outline_rounded
                              : Icons.security_rounded),
                    size: 38,
                    color: accent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  titleText,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isLockedOut
                        ? AppTheme.critical
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitleText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _isLockedOut
                        ? AppTheme.critical
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                AbsorbPointer(
                  absorbing: _isLockedOut,
                  child: Opacity(
                    opacity: _isLockedOut ? 0.5 : 1.0,
                    child: PinPadWidget(
                      pinLength: _pinLength,
                      currentPin: _enteredPin,
                      errorText: _errorText,
                      onPinChanged: (val) {
                        if (_isLockedOut) return;
                        setState(() {
                          _enteredPin = val;
                          _errorText = null;
                        });
                      },
                      onMaxLenReached: _handlePinComplete,
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
