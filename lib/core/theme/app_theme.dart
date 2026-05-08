// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _build(
    brightness: Brightness.light,
    cs: const ColorScheme.light(
      primary: Color(0xFF111111),        // ink — ElevatedButton bg in light
      onPrimary: Color(0xFFFFFFFF),      // white text on ink button
      secondary: Color(0xFF111111),
      onSecondary: Color(0xFFFFFFFF),
      surface: Color(0xFFFFFFFF),        // white cards
      onSurface: Color(0xFF0A0A0A),      // near-black text
      error: AppColors.error,
      onError: Color(0xFFFFFFFF),
    ),
    ext: AppThemeColors.fromLightPalette(AppColors.light),
    ctaBg: const Color(0xFF111111),      // black pill CTA
    ctaFg: const Color(0xFFFFFFFF),
    statusBarBrightness: Brightness.dark,
  );

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
    ctaBg: AppColors.primary,            // neon pill in dark
    ctaFg: const Color(0xFF000000),
    statusBarBrightness: Brightness.light,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme cs,
    required AppThemeColors ext,
    required Color ctaBg,
    required Color ctaFg,
    required Brightness statusBarBrightness,
  }) {
    final p = ext;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: p.scaffoldBg,
      textTheme: AppTypography.textTheme,
      colorScheme: cs,
      extensions: [ext],
      appBarTheme: AppBarTheme(
        backgroundColor: p.surface,
        foregroundColor: p.onSurface,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarBrightness,
        ),
      ),
      // Primary CTA — pill. Dark: neon bg + black text. Light: ink bg + white text.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ctaBg,
          foregroundColor: ctaFg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
          elevation: 0,
        ),
      ),
      // Secondary CTA — pill with hairline border.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.onSurface,
          side: BorderSide(color: p.borderDefault),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      // Text buttons use accentText so they're readable in both modes.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accentText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Inputs — {rounded.md} = 16px
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: p.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: TextStyle(
          color: p.onSurface30,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(color: p.onSurface70),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
      ),
      dividerTheme: DividerThemeData(
        color: p.onSurface10,
        thickness: 1,
        space: 1,
      ),
      // Cards — {rounded.md} = 16px, flat, hairline border.
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
