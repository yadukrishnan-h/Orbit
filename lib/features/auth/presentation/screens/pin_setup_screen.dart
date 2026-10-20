import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/services/secure_storage_service.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/features/auth/presentation/widgets/pin_pad_widget.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;

  const PinSetupScreen({super.key, required this.onSuccess});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  String _enteredPin = '';
  String? _firstPin;
  String? _errorText;
  static const int _pinLength = 4;
  bool _isConfirming = false;

  void _handlePinComplete() async {
    if (_enteredPin.length != _pinLength) return;

    if (!_isConfirming) {
      // Move to confirm state
      setState(() {
        _firstPin = _enteredPin;
        _enteredPin = '';
        _isConfirming = true;
        _errorText = null;
      });
    } else {
      // Check if match
      if (_enteredPin == _firstPin) {
        // Save and proceed
        final storage = ref.read(secureStorageServiceProvider);
        await storage.saveMasterPin(_enteredPin);
        widget.onSuccess();
      } else {
        // Mismatch
        setState(() {
          _errorText = 'PINs do not match. Try again.';
          _enteredPin = '';
          _firstPin = null;
          _isConfirming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                    color: AppTheme.terminalMint.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.terminalMint.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.terminalMint.withValues(alpha: 0.15),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 38,
                    color: AppTheme.terminalMint,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isConfirming ? 'Confirm PIN' : 'Create Master PIN',
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isConfirming
                      ? 'Re-enter your PIN to confirm'
                      : 'Used to unlock Orbit securely',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                PinPadWidget(
                  pinLength: _pinLength,
                  currentPin: _enteredPin,
                  errorText: _errorText,
                  onPinChanged: (val) {
                    setState(() {
                      _enteredPin = val;
                      _errorText = null;
                    });
                  },
                  onMaxLenReached: _handlePinComplete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
