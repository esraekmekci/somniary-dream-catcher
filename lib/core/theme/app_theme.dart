import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppPalette.lightPrimary,
      onPrimary: Colors.white,
      secondary: AppPalette.lightSecondary,
      onSecondary: AppPalette.lightTextPrimary,
      error: Color(0xFFB63D3D),
      onError: Colors.white,
      surface: AppPalette.lightSurface,
      onSurface: AppPalette.lightTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.lightSurface.withValues(alpha: 0.92),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.9),
        hintStyle: const TextStyle(color: AppPalette.lightTextSecondary),
        labelStyle: const TextStyle(color: AppPalette.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppPalette.color200.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppPalette.color200.withValues(alpha: 0.75)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppPalette.lightPrimary, width: 1.3),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: AppPalette.lightTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppPalette.lightTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppPalette.lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppPalette.lightTextPrimary,
        ),
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppPalette.darkPrimary,
      onPrimary: AppPalette.darkTextPrimary,
      secondary: AppPalette.darkSecondary,
      onSecondary: AppPalette.darkBackground,
      error: Color(0xFFED6A6A),
      onError: Color(0xFF220E0E),
      surface: AppPalette.darkSurface,
      onSurface: AppPalette.darkTextPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppPalette.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppPalette.darkSurface.withValues(alpha: 0.94),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.darkSurface.withValues(alpha: 0.95),
        hintStyle: const TextStyle(color: AppPalette.darkTextSecondary),
        labelStyle: const TextStyle(color: AppPalette.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppPalette.color700.withValues(alpha: 0.35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: AppPalette.color700.withValues(alpha: 0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.color500, width: 1.3),
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: AppPalette.darkTextPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppPalette.darkTextPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: AppPalette.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          height: 1.45,
          color: AppPalette.darkTextPrimary,
        ),
      ),
    );
  }
}
