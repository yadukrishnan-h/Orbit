import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';

class PinPadWidget extends StatelessWidget {
  final int pinLength;
  final String currentPin;
  final Function(String) onPinChanged;
  final VoidCallback onMaxLenReached;
  final String? errorText;

  const PinPadWidget({
    super.key,
    required this.pinLength,
    required this.currentPin,
    required this.onPinChanged,
    required this.onMaxLenReached,
    this.errorText,
  });

  void _handleKeyPress(String value) {
    HapticFeedback.lightImpact();
    if (value == '<') {
      if (currentPin.isNotEmpty) {
        onPinChanged(currentPin.substring(0, currentPin.length - 1));
      }
    } else {
      if (currentPin.length < pinLength) {
        final newPin = currentPin + value;
        onPinChanged(newPin);
        if (newPin.length == pinLength) {
          onMaxLenReached();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Error Text
        SizedBox(
          height: 24,
          child: AnimatedOpacity(
            opacity: errorText != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Text(
              errorText ?? '',
              style: GoogleFonts.inter(color: Colors.red, fontSize: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Dots with glowing terminal mint animation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pinLength, (index) {
            final isFilled = index < currentPin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? AppTheme.terminalMint
                    : const Color(0xFF141518),
                border: Border.all(
                  color: isFilled
                      ? AppTheme.terminalMint
                      : Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: AppTheme.terminalMint.withValues(alpha: 0.6),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        // Keypad
        SizedBox(
          width: 280,
          child: Column(
            children: [
              _buildRow(['1', '2', '3']),
              const SizedBox(height: 16),
              _buildRow(['4', '5', '6']),
              const SizedBox(height: 16),
              _buildRow(['7', '8', '9']),
              const SizedBox(height: 16),
              _buildRow(['', '0', '<']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) {
        if (key.isEmpty) {
          return const SizedBox(width: 72, height: 72);
        }
        final isBackspace = key == '<';
        return InkWell(
          onTap: () => _handleKeyPress(key),
          customBorder: const CircleBorder(),
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBackspace ? Colors.transparent : const Color(0xFF141518),
              border: isBackspace
                  ? null
                  : Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
            ),
            child: Center(
              child: isBackspace
                  ? const Icon(
                      LucideIcons.delete,
                      color: AppTheme.textSecondary,
                      size: 22,
                    )
                  : Text(
                      key,
                      style: GoogleFonts.inter(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
