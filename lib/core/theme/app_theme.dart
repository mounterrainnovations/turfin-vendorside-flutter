// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => _build(
    brightness: Brightness.dark,
    cs: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Color(0xFF000000),
      secondary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF000000),
      surface: Color(0xFF000000),
      onSurface: Color(0xFFFFFFFF),
      error: AppColors.error,
      onError: Color(0xFFFFFFFF),
    ),
    ext: AppThemeColors.fromPalette(AppColors.dark),
    statusBarBrightness: Brightness.light,
  );

  // Uncomment and fill in when light theme is needed:
  // static ThemeData get lightTheme => _build(
  //   brightness: Brightness.light,
  //   cs: const ColorScheme.light(
  //     primary: AppColors.primary,
  //     onPrimary: Color(0xFF000000),
  //     secondary: Color(0xFF0A0A0A),
  //     onSecondary: Color(0xFFFFFFFF),
  //     surface: Color(0xFFF5F5F5),
  //     onSurface: Color(0xFF0A0A0A),
  //     error: AppColors.error,
  //     onError: Color(0xFFFFFFFF),
  //   ),
  //   ext: AppThemeColors.fromLightPalette(AppColors.light),
  //   statusBarBrightness: Brightness.dark,
  // );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme cs,
    required AppThemeColors ext,
    required Brightness statusBarBrightness,
  }) {
    final p = ext; // shorthand
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: p.scaffoldBg,
      textTheme: AppTypography.textTheme,
      colorScheme: cs,
      extensions: [ext],
      appBarTheme: AppBarTheme(
        backgroundColor: p.scaffoldBg,
        foregroundColor: p.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF000000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.onSurface,
          side: BorderSide(color: p.onSurface, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: p.onSurface50,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: TextStyle(color: p.onSurface70),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
      ),
      dividerTheme: DividerThemeData(
        color: p.onSurface10,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.borderDefault),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
