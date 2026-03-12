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

class _PinUnlockScreenState extends ConsumerState<PinUnlockScreen> {
  String _enteredPin = '';
  String? _errorText;
  static const int _pinLength = 4;
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  Timer? _lockoutTimer;

  bool get _isLockedOut =>
      _lockoutEndTime != null && DateTime.now().isBefore(_lockoutEndTime!);

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadLockoutState();
  }

  Future<void> _loadLockoutState() async {
    final storage = ref.read(secureStorageServiceProvider);
    final attempts = await storage.readFailedAttempts();
    final lockoutTime = await storage.readLockoutTime();

    if (mounted) {
      setState(() {
        _failedAttempts = attempts;
        _lockoutEndTime = lockoutTime;
      });

      if (_isLockedOut) {
        _errorText = 'Locked due to previous attempts.';
        _startLockoutTimer();
      }
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isLockedOut) {
        timer.cancel();
        // Clear lockout in storage when it expires naturally
        _clearLockout();
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _clearLockout() async {
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveFailedAttempts(0);
    await storage.saveLockoutTime(null);
  }

  Future<void> _verifyPin() async {
    if (_enteredPin.length != _pinLength || _isLockedOut) return;

    final storage = ref.read(secureStorageServiceProvider);
    final masterPin = await storage.readMasterPin();

    if (_enteredPin == masterPin) {
      _failedAttempts = 0;
      await _clearLockout();
      widget.onSuccess();
    } else {
      final newAttempts = _failedAttempts + 1;
      DateTime? newLockout;

      if (newAttempts >= 5) {
        newLockout = DateTime.now().add(const Duration(seconds: 30));
      }

      await storage.saveFailedAttempts(newAttempts);
      await storage.saveLockoutTime(newLockout);

      setState(() {
        _failedAttempts = newAttempts;
        _enteredPin = '';
        if (newLockout != null) {
          _lockoutEndTime = newLockout;
          _errorText = 'Too many failed attempts. Try again in 30s.';
          _startLockoutTimer();
        } else {
          _errorText =
              'Incorrect PIN. Try again. (${5 - _failedAttempts} attempts left)';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final remainingLockout =
        _lockoutEndTime?.difference(DateTime.now()).inSeconds ?? 0;
    final isLocked = _isLockedOut;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLocked ? Icons.lock_clock : Icons.lock_outline,
                  size: AppSizes.iconGiant,
                  color: isLocked ? AppTheme.critical : AppTheme.primary,
                ),
                const SizedBox(height: AppSizes.p24),
                Text(
                  isLocked ? 'Temporarily Locked' : 'Enter Master PIN',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  isLocked
                      ? 'Please wait $remainingLockout seconds'
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
