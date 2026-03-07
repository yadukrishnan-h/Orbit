import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Beszel Palette (Zinc & Emerald)
  static const Color background = Color(0xFF09090B); // Zinc 950
  static const Color surface = Color(0xFF18181B); // Zinc 900
  static const Color border = Color(0xFF27272A); // Zinc 800
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color disabled = Color(0xFF71717A); // Zinc 500
  static const Color zinc800 = Color(0xFF27272A);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color critical = Color(0xFFEF4444); // Red

  // Area Chart Gradient Colors
  static const Color cpuColor = Color(0xFF6366F1); // Indigo
  static const Color ramColor = Color(0xFFF59E0B); // Amber
  static const Color diskColor = Color(0xFF10B981); // Emerald

  // --- Shared Text Styles (Extracted from System Monitor) ---

  /// Uppercase section header (e.g., 'CPU USAGE')
  static const TextStyle sectionHeaderStyle = TextStyle(
    color: textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  /// Standard card title
  static const TextStyle cardTitleStyle = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  /// Prominent card value (FiraCode)
  static TextStyle get cardValueStyle => GoogleFonts.firaCode(
        color: textPrimary,
        fontWeight: FontWeight.bold,
      );

  /// Small label inside cards
  static const TextStyle infoLabelStyle = TextStyle(
    color: textSecondary,
    fontSize: 12,
  );

  /// Monospace value inside cards
  static TextStyle get infoValueStyle => GoogleFonts.firaCode(
        color: textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF09090B), // Zinc 950 (Void)

      // The "Zinc" Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10B981), // Emerald 500 (Brand)
        onPrimary: Colors.white,
        surface: Color(0xFF18181B), // Zinc 900 (Card)
        onSurface: Color(0xFFFAFAFA), // Zinc 50 (Text)
        surfaceContainer: Color(0xFF18181B), // Zinc 900
        outline: Color(0xFF27272A), // Zinc 800 (Borders)
        error: Color(0xFFEF4444), // Red 500
      ),

      // Card Theme Override
      cardTheme: CardThemeData(
        color: const Color(0xFF18181B),
        elevation: 0, // FLATTEN EVERYTHING
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Tighter corners
          side: const BorderSide(
              color: Color(0xFF27272A), width: 1), // The Beszel Border
        ),
      ),

      // AppBar Theme Override
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF09090B), // Match background
        elevation: 0,
        scrolledUnderElevation: 0, // No color change on scroll
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: const Color(0xFFFAFAFA),
      ),

      // Bottom Navigation Bar Theme (Material 3 NavigationBar)
      navigationBarTheme: NavigationBarThemeData(
        height: 65,
        backgroundColor: const Color(0xFF09090B), // Zinc 950
        indicatorColor:
            const Color(0xFF10B981).withValues(alpha: 0.1), // Emerald Pill
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        // Icon Colors
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
                color: Color(0xFF10B981)); // Emerald Selected
          }
          return const IconThemeData(
              color: Color(0xFFA1A1AA)); // Zinc 400 Unselected
        }),

        // Text Colors
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600);
          }
          return GoogleFonts.inter(
              color: const Color(0xFFA1A1AA), // Zinc 400 Unselected
              fontSize: 12,
              fontWeight: FontWeight.w500);
        }),
      ),
    );
  }
}
