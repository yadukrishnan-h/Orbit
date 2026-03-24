import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';
import 'package:orbit/core/theme/app_sizes.dart';
import 'package:orbit/core/widgets/system_card.dart';

class LicensesScreen extends StatefulWidget {
  const LicensesScreen({super.key});

  @override
  State<LicensesScreen> createState() => _LicensesScreenState();
}

class _LicensesScreenState extends State<LicensesScreen> {
  late Future<List<LicenseEntry>> _licensesFuture;

  @override
  void initState() {
    super.initState();
    _licensesFuture = _loadLicenses();
  }

  Future<List<LicenseEntry>> _loadLicenses() async {
    return LicenseRegistry.licenses.toList();
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
          'Open Source Licenses',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<List<LicenseEntry>>(
        future: _licensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading licenses',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            );
          }

          final licenses = snapshot.data ?? [];

          if (licenses.isEmpty) {
            return Center(
              child: Text(
                'No licenses found.',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSizes.p16),
            itemCount: licenses.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSizes.p16),
            itemBuilder: (context, index) {
              final license = licenses[index];
              final packages = license.packages.toList();
              final packageName = packages.isNotEmpty
                  ? packages.join(', ')
                  : 'Unknown Package';

              final paragraphs = license.paragraphs
                  .map((p) => p.text)
                  .join('\n\n');

              return SystemCard(
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: AppSizes.p8),
                    title: Text(
                      packageName,
                      style: GoogleFonts.inter(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    children: [
                      Text(
                        paragraphs,
                        style: GoogleFonts.firaCode(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
