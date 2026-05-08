// lib/core/theme/app_typography.dart
//
// TYPE SCALE — see DESIGN.md › Typography for full token documentation.
//
// Slot mapping to Material TextTheme:
//   displayLarge   → {typography.displayCampaign}  48px w800  — hero revenue metric
//   displayMedium  → {typography.displayXL}         32px w800  — secondary stat numbers
//   displaySmall   → {typography.headingXL}         24px w700  — screen title, dialog headline
//   headlineMedium → {typography.headingLG}         20px w700  — card section title
//   titleLarge     → {typography.headingMD}         18px w600  — subsection, tab header
//   bodyLarge      → {typography.bodyStrong}         16px w500  — nav links, field names, card names
//   bodyMedium     → {typography.bodyMD}             15px w400  — body copy, form values
//   labelLarge     → {typography.buttonMD}           16px w700  — pill CTA labels
//   labelMedium    → {typography.captionMD}          13px w600  — card metadata, time labels
//   bodySmall      → {typography.captionSM}          11px w600  — status chip labels (CAPS)
//   labelSmall     → {typography.utilityXS}           9px w700  — section headers in CAPS

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.manropeTextTheme(
    const TextTheme(
      displayLarge:   TextStyle(fontSize: 48, fontWeight: FontWeight.w800, height: 0.95, letterSpacing: -1.0),
      displayMedium:  TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.0,  letterSpacing: -0.5),
      displaySmall:   TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2,  letterSpacing: -0.3),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.2,  letterSpacing: -0.2),
      titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3,  letterSpacing:  0),
      bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4,  letterSpacing:  0),
      bodyMedium:     TextStyle(fontSize: 15, fontWeight: FontWeight.w400, height: 1.5,  letterSpacing:  0),
      labelLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.0,  letterSpacing:  0),
      labelMedium:    TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4,  letterSpacing:  0),
      bodySmall:      TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.4,  letterSpacing:  1.0),
      labelSmall:     TextStyle(fontSize: 9,  fontWeight: FontWeight.w700, height: 1.5,  letterSpacing:  1.5),
    ),
  );
}
