import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/widgets/system_card.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = 'v${info.version}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = 'v1.1.1'; // Fallback
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'About',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.p16),
          children: [
            const SizedBox(height: AppSizes.p32),
            // Header: Logo, App Name, Version
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.border, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/orbit-logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p24),
                  Text(
                    'Orbit',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.p4),
                  Text(
                    _version,
                    style: GoogleFonts.firaCode(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.p48),

            // Links List
            SystemCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(
                    title: 'Developer',
                    subtitle: 'Yadu Krishnan',
                    icon: LucideIcons.user,
                  ),
                  _divider(),
                  _buildListTile(
                    title: 'Privacy Policy',
                    icon: LucideIcons.shield,
                    onTap: () {
                      context.push(
                        '/legal',
                        extra: {
                          'title': 'Privacy Policy',
                          'assetPath': 'PRIVACY_POLICY.md',
                        },
                      );
                    },
                  ),
                  _divider(),
                  _buildListTile(
                    title: 'Terms of Service',
                    icon: LucideIcons.fileText,
                    onTap: () {
                      context.push(
                        '/legal',
                        extra: {
                          'title': 'Terms of Service',
                          'assetPath': 'TERMS_OF_SERVICE.md',
                        },
                      );
                    },
                  ),
                  _divider(),
                  _buildListTile(
                    title: 'Open Source Licenses',
                    icon: LucideIcons.bookOpen,
                    onTap: () {
                      context.push('/licenses');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    String? subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSizes.p16,
        vertical: AppSizes.p4,
      ),
      leading: Icon(
        icon,
        color: AppTheme.textSecondary,
        size: AppSizes.iconNormal,
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            )
          : null,
      trailing: onTap != null
          ? const Icon(
              LucideIcons.chevronRight,
              color: AppTheme.textSecondary,
              size: 18,
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.border,
      indent: AppSizes.p16,
      endIndent: AppSizes.p16,
    );
  }
}
