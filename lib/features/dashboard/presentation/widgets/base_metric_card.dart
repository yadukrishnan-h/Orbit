import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';

class BaseMetricCard extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;
  final WidgetRef? ref; // Optional for localization if needed, but standardizing on strings

  const BaseMetricCard({
    super.key,
    required this.title,
    required this.child,
    this.height,
    this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTheme.sectionHeaderStyle,
        ),
        const SizedBox(height: AppSizes.p8),
        SizedBox(
          height: height ?? AppSizes.chartDefaultHeight,
          child: Card(
            color: AppTheme.surface,
            elevation: AppSizes.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
              side: const BorderSide(color: AppTheme.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
