// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.manropeTextTheme(
    const TextTheme(
      displayLarge:   TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5),
      displayMedium:  TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5),
      displaySmall:   TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.3),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.3),
      titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
    ),
  );
}
