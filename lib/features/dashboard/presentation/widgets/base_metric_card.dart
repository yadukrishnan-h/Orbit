import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/widgets/glow_border.dart';

class BaseMetricCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? expansionChild;
  final bool isExpanded;
  final VoidCallback? onToggleExpansion;
  final double? height;

  /// Override inner padding for the main content area.
  /// Defaults to EdgeInsets.all(AppSizes.p20) when null.
  final EdgeInsetsGeometry? contentPadding;

  const BaseMetricCard({
    super.key,
    required this.title,
    required this.child,
    this.expansionChild,
    this.isExpanded = false,
    this.onToggleExpansion,
    this.height,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            title.toUpperCase(),
            style: AppTheme.sectionHeaderStyle.copyWith(
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.p12),
        GlowBorder(
          borderRadius: AppSizes.radiusMedium,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main Content Area
              SizedBox(
                height: height ?? AppSizes.chartDefaultHeight,
                child: Padding(
                  padding: contentPadding ?? const EdgeInsets.all(AppSizes.p20),
                  child: child,
                ),
              ),

              // Bottom Toggle (if expansion is supported)
              if (expansionChild != null) ...[
                InkWell(
                  onTap: onToggleExpansion,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppSizes.radiusMedium),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? 'Show less' : 'Show more',
                          style: AppTheme.infoLabelStyle.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          size: 14,
                          color: AppTheme.textSecondary.withValues(alpha: 0.8),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expansion Content
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.p20,
                      0,
                      AppSizes.p20,
                      AppSizes.p20,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.transparent, // Seamless background
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 8,
                        ), // Gap before expansion content
                        expansionChild!,
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 300),
                  sizeCurve: Curves.fastOutSlowIn,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
