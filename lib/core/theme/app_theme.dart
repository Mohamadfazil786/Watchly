import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Cinema theme accents
  static const Color primaryDark = Color(0xFFE50914);
  static const Color primaryLight = Color(0xFFE50914);
  
  static const Color secondaryDark = Color(0xFFFF9233);
  static const Color secondaryLight = Color(0xFFFF9233);

  // New design tokens matching home_screen and profile_screen
  static const Color bgDark        = Color(0xFF000000);
  static const Color surfaceDark   = Color(0xFF15181C);
  static const Color surfaceDark2  = Color(0xFF202327);
  static const Color borderDark    = Color(0xFF2F3336);
  static const Color textDark      = Color(0xFFF7F9F9);
  static const Color subtextDark   = Color(0xFF71767B);
  static const Color mutedDark     = Color(0xFF71767B);

  static const Color bgLight       = Color(0xFFF5F0E8);
  static const Color surfaceLight  = Color(0xFFFFFFFF);
  static const Color borderLight   = Color(0xFFE8E2D8);
  static const Color textLight     = Color(0xFF1A1A2E);
  static const Color subtextLight  = Color(0xFF6B6878);

  static const Color red           = Color(0xFFE50914);
  static const Color redDim        = Color(0xFF8B0000);
  static const Color gold          = Color(0xFFC8A96E);
  static const Color goldDim       = Color(0xFF7A6340);
  static const Color green         = Color(0xFF1DB954);
  static const Color amber         = Color(0xFFFF9500);
  static const Color purple        = Color(0xFF7B5EA7);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: secondaryDark,
        surface: surfaceDark,
        error: Color(0xFFFF3333),
      ),
      scaffoldBackgroundColor: bgDark,
      cardColor: surfaceDark,
      dividerColor: borderDark,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: subtextDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: subtextDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: primaryDark,
        unselectedItemColor: subtextDark,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark2,
        hintStyle: const TextStyle(color: subtextDark),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: secondaryLight,
        surface: surfaceLight,
        error: Color(0xFFD32F2F),
      ),
      scaffoldBackgroundColor: bgLight,
      cardColor: surfaceLight,
      dividerColor: borderLight,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textLight,
        ),
        titleMedium: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: subtextLight,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: textLight,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: subtextLight,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textLight),
        titleTextStyle: TextStyle(color: textLight, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceLight,
        selectedItemColor: primaryLight,
        unselectedItemColor: subtextLight,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: subtextLight),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 1.5),
        ),
      ),
    );
  }
}

extension ThemeX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg            => isDark ? AppTheme.bgDark        : AppTheme.bgLight;
  Color get surface       => isDark ? AppTheme.surfaceDark   : AppTheme.surfaceLight;
  Color get surface2      => isDark ? AppTheme.surfaceDark2  : const Color(0xFFF0EBE0);
  Color get border        => isDark ? AppTheme.borderDark    : AppTheme.borderLight;
  Color get textPrimary   => isDark ? AppTheme.textDark      : AppTheme.textLight;
  Color get textSecondary => isDark ? AppTheme.subtextDark   : AppTheme.subtextLight;
  Color get textSub       => isDark ? AppTheme.subtextDark   : AppTheme.subtextLight;
  Color get muted         => isDark ? AppTheme.mutedDark     : const Color(0xFFBBB5A8);
}
