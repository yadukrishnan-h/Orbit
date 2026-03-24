import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:orbit/core/theme/app_theme.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  Future<String> _loadDocument() async {
    return await rootBundle.loadString(assetPath);
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
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<String>(
        future: _loadDocument(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading document',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            );
          }

          final data = snapshot.data ?? '';

          if (data.isEmpty) {
            return Center(
              child: Text(
                'Document is empty',
                style: GoogleFonts.inter(color: AppTheme.textSecondary),
              ),
            );
          }

          return Markdown(
            data: data,
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[400],
                height: 1.6,
              ),
              h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              listBullet: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
              code: GoogleFonts.firaCode(
                backgroundColor: AppTheme.surface,
                color: Colors.grey[300],
                fontSize: 13,
              ),
              codeblockDecoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              blockquoteDecoration: BoxDecoration(
                color: AppTheme.surface,
                border: const Border(
                  left: BorderSide(color: AppTheme.primary, width: 4),
                ),
              ),
              blockquote: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              a: GoogleFonts.inter(color: AppTheme.primary),
            ),
          );
        },
      ),
    );
  }
}
