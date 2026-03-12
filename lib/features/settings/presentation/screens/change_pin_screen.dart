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

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  // Phase 1: verify current. Phase 2: enter new. Phase 3: confirm new.
  int _phase = 1;

  String _enteredPin = '';
  String? _newPin;
  String? _errorText;
  static const int _pinLength = 4;

  void _handlePinComplete() async {
    if (_enteredPin.length != _pinLength) return;

    if (_phase == 1) {
      // Verify current PIN
      final storage = ref.read(secureStorageServiceProvider);
      final masterPin = await storage.readMasterPin();

      if (_enteredPin == masterPin) {
        setState(() {
          _phase = 2;
          _enteredPin = '';
          _errorText = null;
        });
      } else {
        setState(() {
          _errorText = 'Incorrect current PIN. Try again.';
          _enteredPin = '';
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
      titleText = 'Verify Current PIN';
      subtitleText = 'Enter your current Master PIN';
    } else if (_phase == 2) {
      titleText = 'Create New PIN';
      subtitleText = 'Enter your new 4-digit Master PIN';
    } else if (_phase == 3) {
      titleText = 'Confirm New PIN';
      subtitleText = 'Re-enter your new PIN to confirm';
    }

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
                Icon(
                  _phase == 1 ? Icons.lock_outline : Icons.security, 
                  size: 64, 
                  color: AppTheme.primary
                ),
                const SizedBox(height: 24),
                Text(
                  titleText,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitleText,
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
