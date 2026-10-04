import 'package:flutter/material.dart';

/// Complete Color Palette matching user's requested palette:
/// #1B262C (Charcoal Midnight Navy)
/// #0F4C75 (Deep Oceanic Blue)
/// #3282B8 (Vibrant Cerulean / Electric Azure)
/// #BBE1FA (Soft Ice Blue Glow / Frosted Sky)
class AppColors {
  // Exact 4 Core Swatches from image:
  static const Color darkNavy = Color(0xFF1B262C);
  static const Color oceanBlue = Color(0xFF0F4C75);
  static const Color azureBlue = Color(0xFF3282B8);
  static const Color iceBlue = Color(0xFFBBE1FA);

  // Exact 4 Core Swatch Aliases for existing screen references:
  static const Color cream = Color(0xFFFFFFFF);     // Pure White for buttons & high-contrast text
  static const Color sand = oceanBlue;              // #0F4C75 Deep Ocean Navy
  static const Color camel = azureBlue;             // #3282B8 Vibrant Cerulean Blue
  static const Color deepTeal = darkNavy;           // #1B262C Midnight Charcoal Navy

  // Background & Surface Hierarchy (Dark Oceanic Theme with Pure Black Canvas)
  static const Color bg = Color(0xFF000000);         // Solid Pure Black Canvas
  static const Color cardBg = Color(0xFF1B262C);     // Exact #1B262C for Primary Card Surfaces
  static const Color cardBgElevated = Color(0xFF22313A); // Elevated modal / popover surface
  static const Color cardBorder = Color(0xFF2B3F4D); // Subtle slate blue border
  static const Color cardBorderSubtle = Color(0xFF202E38);

  // Primary Accent (Vibrant Cerulean #3282B8)
  static const Color primary = azureBlue;
  static const Color primaryLight = Color(0xFF4FA5DF);
  static const Color primaryMuted = Color(0xFF256691);
  static const Color primaryDark = oceanBlue;        // #0F4C75

  // Secondary Accent (Camel -> Azure/Ice)
  static const Color accentCamel = azureBlue;
  static const Color camelDark = Color(0xFF4FA5DF);
  static const Color camelLight = iceBlue;

  // Tertiary Accent (Sand -> Ocean Blue / Ice Blue)
  static const Color accentSand = oceanBlue;
  static const Color sandDark = Color(0xFF0A3452);
  static const Color sandLight = Color(0xFF183244);  // Subtle chip container fill

  // Form & Inputs
  static const Color inputFill = Color(0xFF141E24);   // Sunken dark slate input
  static const Color inputBorder = Color(0xFF293E4C);
  static const Color inputBorderFocused = azureBlue;

  // Typography
  static const Color textDark = Color(0xFFFFFFFF);   // Pure white for crisp titles & values
  static const Color textMuted = Color(0xFF94B5CB);  // Ice-slate blue for subtitles & descriptions
  static const Color textSubtle = Color(0xFF5F7C90); // Muted slate captions & hints
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSand = iceBlue;

  // Status Colors (Vibrant, high-contrast on dark theme)
  static const Color success = Color(0xFF2DD4BF);    // Vibrant teal-mint
  static const Color successBg = Color(0xFF0F312B);
  static const Color successBorder = Color(0xFF1A5E53);

  static const Color warning = Color(0xFFFBBF24);    // Warm amber
  static const Color warningBg = Color(0xFF332A12);
  static const Color warningBorder = Color(0xFF6B5318);

  static const Color danger = Color(0xFFFF6B6B);     // Coral crimson
  static const Color dangerBg = Color(0xFF38181C);
  static const Color dangerBorder = Color(0xFF70262E);

  static const Color info = iceBlue;                 // #BBE1FA
  static const Color infoBg = Color(0xFF102D42);
  static const Color infoBorder = Color(0xFF1A5378);
}

class AppTheme {
  static ThemeData get darkTheme => lightTheme;
  static ThemeData get theme => lightTheme;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.azureBlue,
        onSecondary: Colors.white,
        surface: AppColors.cardBg,
        onSurface: AppColors.textDark,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBg,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.iceBlue,
          side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }
}
