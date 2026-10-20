import 'package:flutter/material.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';

class GlowBorder extends StatelessWidget {
  final Widget child;
  final double? borderRadius;
  final Color? color;
  final double borderWidth;
  final bool showGlow;

  const GlowBorder({
    super.key,
    required this.child,
    this.borderRadius,
    this.color,
    this.borderWidth = 1.0,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppSizes.radiusMedium;
    final effectiveColor = color ?? AppTheme.primary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(effectiveRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            effectiveColor.withValues(alpha: 0.5),
            effectiveColor.withValues(alpha: 0.05),
            effectiveColor.withValues(alpha: 0.02),
            effectiveColor.withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.4, 0.6, 1.0],
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: effectiveColor.withValues(alpha: 0.05),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(effectiveRadius - borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );
  }
}
