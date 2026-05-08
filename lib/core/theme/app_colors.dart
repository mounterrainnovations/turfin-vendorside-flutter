// lib/core/theme/app_colors.dart
//
// COLOR ARCHITECTURE — READ BEFORE USING
// ─────────────────────────────────────────────────────────────────────────────
// There are two kinds of colors in this file:
//
//  1. BRAND colors — always the same regardless of theme.
//     Use directly: AppColors.primary, AppColors.error
//
//  2. SEMANTIC / STRUCTURAL colors — MUST come from AppThemeColors so they
//     flip correctly between light and dark themes.
//     Access via: AppThemeColors.of(context)
//
// LIGHT vs DARK key inversion:
//   Dark  — neon (#CCFF00) is TEXT on a black card  → high contrast ✓
//   Light — neon (#CCFF00) is BACKGROUND of the hero card, black text on top
//           (neon text on white = ~1.1:1 contrast — never use as text in light)
//
// RULE: Never hardcode AppColors.black / AppColors.white in widget files.
//       Use AppThemeColors.of(context).* instead.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand colors (theme-invariant) ────────────────────────────────────────
  static const Color primary      = Color(0xFFCCFF00); // Neon green — always
  static const Color error        = Color(0xFFEF4444); // Red — always

  // ── Neon green opacity variants (theme-invariant) ─────────────────────────
  static const Color primary70     = Color(0xB2CCFF00);
  static const Color primaryGlow   = Color(0x33CCFF00); // 20% neon — glow bg
  static const Color primarySubtle = Color(0x1ACCFF00); // 10% neon — light tint

  // ── Palettes ──────────────────────────────────────────────────────────────
  static const DarkPalette  dark  = DarkPalette();
  static const LightPalette light = LightPalette();
}

// ─────────────────────────────────────────────────────────────────────────────
// DARK PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class DarkPalette {
  const DarkPalette();

  Color get scaffoldBg    => const Color(0xFF000000);
  Color get surface       => const Color(0xFF111111);
  Color get navBg         => const Color(0xF2000000); // black 95%
  Color get onSurface     => const Color(0xFFFFFFFF);
  Color get onSurface70   => const Color(0xB2FFFFFF);
  Color get onSurface60   => const Color(0x99FFFFFF);
  Color get onSurface50   => const Color(0x7FFFFFFF);
  Color get onSurface30   => const Color(0x4DFFFFFF);
  Color get onSurface20   => const Color(0x33FFFFFF);
  Color get onSurface10   => const Color(0x1AFFFFFF);
  Color get borderDefault => const Color(0xFF3A3A3A);
  Color get borderSubtle  => const Color(0xFF2A2A2A);
  Color get sectionLabel  => const Color(0xFF94A3B8); // slate-400
  Color get scrim         => const Color(0x80000000);
  Color get imgOverlay    => const Color(0xCC000000);

  // ── Adaptive accent tokens ────────────────────────────────────────────────
  // Dark: neon is used as TEXT on dark surfaces.
  Color get accentText    => const Color(0xFFCCFF00); // neon green text
  Color get accentSurface => const Color(0x33CCFF00); // 20% neon tint bg
  Color get heroCardBg    => const Color(0xFF111111); // carbon — neon text sits on it
}

// ─────────────────────────────────────────────────────────────────────────────
// LIGHT PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class LightPalette {
  const LightPalette();

  Color get scaffoldBg    => const Color(0xFFF5F5F5); // soft-cloud page bg
  Color get surface       => const Color(0xFFFFFFFF); // white cards
  Color get navBg         => const Color(0xFFFFFFFF); // white nav bar
  Color get onSurface     => const Color(0xFF0A0A0A); // near-black text
  Color get onSurface70   => const Color(0xB20A0A0A);
  Color get onSurface60   => const Color(0x990A0A0A);
  Color get onSurface50   => const Color(0x7F0A0A0A);
  Color get onSurface30   => const Color(0x4D0A0A0A);
  Color get onSurface20   => const Color(0x330A0A0A);
  Color get onSurface10   => const Color(0x1A0A0A0A);
  Color get borderDefault => const Color(0xFFDDDDDD);
  Color get borderSubtle  => const Color(0xFFEEEEEE);
  Color get sectionLabel  => const Color(0xFF64748B); // slate-500
  Color get scrim         => const Color(0x40000000);
  Color get imgOverlay    => const Color(0x80000000);

  // ── Adaptive accent tokens ────────────────────────────────────────────────
  // Light: ink (#111111) does all assertive work — no neon in the chrome.
  Color get accentText    => const Color(0xFF111111); // near-black — active text/icons
  Color get accentSurface => const Color(0xFFF5F5F5); // soft-cloud — subtle chip/time bg
  Color get heroCardBg    => const Color(0xFFFFFFFF); // white card, black display text
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeExtension — bridge between palettes and widgets
// ─────────────────────────────────────────────────────────────────────────────
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color scaffoldBg;
  final Color surface;
  final Color navBg;
  final Color onSurface;
  final Color onSurface70;
  final Color onSurface60;
  final Color onSurface50;
  final Color onSurface30;
  final Color onSurface20;
  final Color onSurface10;
  final Color borderDefault;
  final Color borderSubtle;
  final Color sectionLabel;
  final Color scrim;
  final Color imgOverlay;
  // Adaptive accent tokens
  final Color accentText;    // neon in dark, near-black in light
  final Color accentSurface; // neon tint bg in dark, pale mint in light
  final Color heroCardBg;    // carbon in dark, neon in light

  const AppThemeColors({
    required this.scaffoldBg,
    required this.surface,
    required this.navBg,
    required this.onSurface,
    required this.onSurface70,
    required this.onSurface60,
    required this.onSurface50,
    required this.onSurface30,
    required this.onSurface20,
    required this.onSurface10,
    required this.borderDefault,
    required this.borderSubtle,
    required this.sectionLabel,
    required this.scrim,
    required this.imgOverlay,
    required this.accentText,
    required this.accentSurface,
    required this.heroCardBg,
  });

  static AppThemeColors of(BuildContext context) =>
      Theme.of(context).extension<AppThemeColors>()!;

  static AppThemeColors fromPalette(DarkPalette p) => AppThemeColors(
    scaffoldBg:    p.scaffoldBg,
    surface:       p.surface,
    navBg:         p.navBg,
    onSurface:     p.onSurface,
    onSurface70:   p.onSurface70,
    onSurface60:   p.onSurface60,
    onSurface50:   p.onSurface50,
    onSurface30:   p.onSurface30,
    onSurface20:   p.onSurface20,
    onSurface10:   p.onSurface10,
    borderDefault: p.borderDefault,
    borderSubtle:  p.borderSubtle,
    sectionLabel:  p.sectionLabel,
    scrim:         p.scrim,
    imgOverlay:    p.imgOverlay,
    accentText:    p.accentText,
    accentSurface: p.accentSurface,
    heroCardBg:    p.heroCardBg,
  );

  static AppThemeColors fromLightPalette(LightPalette p) => AppThemeColors(
    scaffoldBg:    p.scaffoldBg,
    surface:       p.surface,
    navBg:         p.navBg,
    onSurface:     p.onSurface,
    onSurface70:   p.onSurface70,
    onSurface60:   p.onSurface60,
    onSurface50:   p.onSurface50,
    onSurface30:   p.onSurface30,
    onSurface20:   p.onSurface20,
    onSurface10:   p.onSurface10,
    borderDefault: p.borderDefault,
    borderSubtle:  p.borderSubtle,
    sectionLabel:  p.sectionLabel,
    scrim:         p.scrim,
    imgOverlay:    p.imgOverlay,
    accentText:    p.accentText,
    accentSurface: p.accentSurface,
    heroCardBg:    p.heroCardBg,
  );

  @override
  AppThemeColors copyWith({
    Color? scaffoldBg, Color? surface, Color? navBg,
    Color? onSurface, Color? onSurface70, Color? onSurface60,
    Color? onSurface50, Color? onSurface30, Color? onSurface20,
    Color? onSurface10, Color? borderDefault, Color? borderSubtle,
    Color? sectionLabel, Color? scrim, Color? imgOverlay,
    Color? accentText, Color? accentSurface, Color? heroCardBg,
  }) => AppThemeColors(
    scaffoldBg:    scaffoldBg    ?? this.scaffoldBg,
    surface:       surface       ?? this.surface,
    navBg:         navBg         ?? this.navBg,
    onSurface:     onSurface     ?? this.onSurface,
    onSurface70:   onSurface70   ?? this.onSurface70,
    onSurface60:   onSurface60   ?? this.onSurface60,
    onSurface50:   onSurface50   ?? this.onSurface50,
    onSurface30:   onSurface30   ?? this.onSurface30,
    onSurface20:   onSurface20   ?? this.onSurface20,
    onSurface10:   onSurface10   ?? this.onSurface10,
    borderDefault: borderDefault ?? this.borderDefault,
    borderSubtle:  borderSubtle  ?? this.borderSubtle,
    sectionLabel:  sectionLabel  ?? this.sectionLabel,
    scrim:         scrim         ?? this.scrim,
    imgOverlay:    imgOverlay    ?? this.imgOverlay,
    accentText:    accentText    ?? this.accentText,
    accentSurface: accentSurface ?? this.accentSurface,
    heroCardBg:    heroCardBg    ?? this.heroCardBg,
  );

  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      scaffoldBg:    Color.lerp(scaffoldBg,    other.scaffoldBg,    t)!,
      surface:       Color.lerp(surface,       other.surface,       t)!,
      navBg:         Color.lerp(navBg,         other.navBg,         t)!,
      onSurface:     Color.lerp(onSurface,     other.onSurface,     t)!,
      onSurface70:   Color.lerp(onSurface70,   other.onSurface70,   t)!,
      onSurface60:   Color.lerp(onSurface60,   other.onSurface60,   t)!,
      onSurface50:   Color.lerp(onSurface50,   other.onSurface50,   t)!,
      onSurface30:   Color.lerp(onSurface30,   other.onSurface30,   t)!,
      onSurface20:   Color.lerp(onSurface20,   other.onSurface20,   t)!,
      onSurface10:   Color.lerp(onSurface10,   other.onSurface10,   t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderSubtle:  Color.lerp(borderSubtle,  other.borderSubtle,  t)!,
      sectionLabel:  Color.lerp(sectionLabel,  other.sectionLabel,  t)!,
      scrim:         Color.lerp(scrim,         other.scrim,         t)!,
      imgOverlay:    Color.lerp(imgOverlay,    other.imgOverlay,    t)!,
      accentText:    Color.lerp(accentText,    other.accentText,    t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      heroCardBg:    Color.lerp(heroCardBg,    other.heroCardBg,    t)!,
    );
  }
}
