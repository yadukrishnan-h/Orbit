import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';

/// Model for an available app icon option.
/// Extend this list in the future to add alternate icons.
class AppIconOption {
  final String label;
  final String assetPath;
  final bool isActive;

  const AppIconOption({
    required this.label,
    required this.assetPath,
    this.isActive = false,
  });
}

/// App Icon selection tile.
/// Opens a bottom sheet GridView — easily extensible with more icon options.
class AppIconTile extends ConsumerWidget {
  const AppIconTile({super.key});

  static const List<AppIconOption> _iconOptions = [
    AppIconOption(
      label: 'Default',
      assetPath: 'assets/images/orbit-logo.PNG',
      isActive: true,
    ),
    // Add future icon variants here, e.g.:
    // AppIconOption(label: 'Dark', assetPath: 'assets/images/orbit-logo-dark.PNG'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const Icon(LucideIcons.layoutGrid,
          color: AppTheme.textSecondary, size: 20),
      title: Text(
        'App Icon',
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        'Default',
        style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: const Icon(LucideIcons.chevronRight,
          color: AppTheme.textSecondary, size: 18),
      onTap: () => _showIconSheet(context),
    );
  }

  void _showIconSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: AppTheme.border),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'App Icon',
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'More icon options coming soon.',
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 20),
              // GridView — add more AppIconOptions to extend this
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: _iconOptions.length,
                itemBuilder: (ctx, index) {
                  final option = _iconOptions[index];
                  return _IconOptionCard(option: option);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _IconOptionCard extends StatelessWidget {
  final AppIconOption option;

  const _IconOptionCard({required this.option});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: option.isActive ? AppTheme.primary : AppTheme.border,
          width: option.isActive ? 2 : 1,
        ),
        color: AppTheme.background,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              option.assetPath,
              width: 64,
              height: 64,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.image_not_supported_outlined,
                color: AppTheme.textSecondary,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            option.label,
            style: GoogleFonts.inter(
              color:
                  option.isActive ? AppTheme.primary : AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: option.isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          if (option.isActive) ...[
            const SizedBox(height: 4),
            const Icon(LucideIcons.checkCircle,
                size: 14, color: AppTheme.primary),
          ],
        ],
      ),
    );
  }
}
