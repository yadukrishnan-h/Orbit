import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orbit/core/theme/app_sizes.dart';

class AppTheme {
  // Beszel Palette (Zinc & Emerald)
  static const Color background = Color(0xFF0A0A0C); // Pitch Black
  static const Color surface = Color(0xFF141518); // Inactive secondary card
  static const Color border = Color(0xFF27272A); // Zinc 800
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color textSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color disabled = Color(0xFF71717A); // Zinc 500
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);

  // Minimal Surface Colors
  static const Color cardBackground = Color(
    0xFF141518,
  ); // Inactive secondary card
  static const Color formInputBackground = Color(
    0xFF15181E,
  ); // Recessed dark input

  static LinearGradient chartGradient(Color baseColor) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      baseColor.withValues(alpha: 0.15),
      baseColor.withValues(alpha: 0.0),
    ],
  );

  static LinearGradient get heroGreenGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
  );

  static List<BoxShadow> get heroGlowShadow => [
    BoxShadow(
      color: const Color(0xFF00E676).withValues(alpha: 0.20),
      blurRadius: 24.0,
      offset: const Offset(0, 4),
    ),
  ];

  // Minimal Shadows
  static List<BoxShadow> get cardShadow =>
      []; // Removed shadows for minimal look

  // Status Colors
  static const Color success = Color(0xFF00E599); // Terminal Mint / Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color critical = Color(0xFFEF4444); // Red

  // Chart Colors (Terminal Mint & Muted Axis)
  static const Color terminalMint = Color(0xFF00E599); // Terminal Mint
  static const Color chartMutedAxis = Color(0xFF52525B); // Muted Axis & Grid

  // Area Chart Gradient Colors
  static const Color cpuColor = Color(0xFF00E599); // Terminal Mint
  static const Color ramColor = Color(0xFF00E599); // Terminal Mint
  static const Color diskColor = Color(0xFF00E599); // Terminal Mint

  // --- Shared Text Styles (Extracted from System Monitor) ---

  /// Uppercase section header (e.g., 'CPU USAGE')
  static const TextStyle sectionHeaderStyle = TextStyle(
    color: textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  /// Phase 3 Unified Uppercase section title
  static const TextStyle sectionTitleStyle = TextStyle(
    color: Color(0xFF6C7280),
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  /// Primary metric display numbers
  static TextStyle get displayValueStyle => GoogleFonts.inter(
    color: textPrimary,
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
  );

  /// Standard card title
  static const TextStyle cardTitleStyle = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  /// Prominent card value (FiraCode)
  static TextStyle get cardValueStyle =>
      GoogleFonts.firaCode(color: textPrimary, fontWeight: FontWeight.bold);

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

  /// Unified technical/monospaced values
  static TextStyle get technicalValueStyle => GoogleFonts.firaCode(
    color: textPrimary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0C), // Pitch Black
      // The "Zinc" Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10B981), // Emerald 500 (Brand)
        onPrimary: Colors.white,
        surface: Color(0xFF141518), // Inactive secondary card
        onSurface: Color(0xFFFAFAFA), // Zinc 50 (Text)
        surfaceContainer: Color(0xFF141518), // Inactive secondary card
        outline: Color(0xFF27272A), // Zinc 800 (Borders)
        error: Color(0xFFEF4444), // Red 500
      ),

      // Card Theme Override
      cardTheme: CardThemeData(
        color: const Color(0xFF141518),
        elevation: AppSizes.cardElevation, // FLATTEN EVERYTHING
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppSizes.radiusMedium,
          ), // Tighter corners
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 0.5,
          ), // Ultra-thin minimal border
        ),
      ),

      // AppBar Theme Override
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0A0C), // Match background
        elevation: 0,
        scrolledUnderElevation: 0, // No color change on scroll
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),

      // Text Theme
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: const Color(0xFFFAFAFA)),

      // Bottom Navigation Bar Theme (Material 3 NavigationBar)
      navigationBarTheme: NavigationBarThemeData(
        height: AppSizes.bottomNavBarHeight,
        backgroundColor: const Color(0xFF0A0A0C), // Match background
        indicatorColor: const Color(
          0xFF10B981,
        ).withValues(alpha: 0.1), // Emerald Pill
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        // Icon Colors
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: Color(0xFF10B981),
            ); // Emerald Selected
          }
          return const IconThemeData(
            color: Color(0xFFA1A1AA),
          ); // Zinc 400 Unselected
        }),

        // Text Colors
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return GoogleFonts.inter(
            color: const Color(0xFFA1A1AA), // Zinc 400 Unselected
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
      ),
    );
  }
}
