# 02 — Theme and Design System

Copy these files verbatim into the vendor app. Do not invent new styles.
Every screen must reference these constants — never hardcode colors or text styles inline.

---

## STEP 11 — app_colors.dart

```dart
// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Base palette (the only 3 real colors) ─────────────────────────────────
  static const Color primary   = Color(0xFFCCFF00); // Neon green
  static const Color black     = Color(0xFF000000); // Pure black
  static const Color white     = Color(0xFFFFFFFF); // Pure white
  static const Color error     = Color(0xFFEF4444); // Red — destructive/error ONLY

  // ── Neon green opacity variants ───────────────────────────────────────────
  static const Color primary70        = Color(0xB2CCFF00); // 70% neon
  static const Color primaryGlow      = Color(0x33CCFF00); // 20% neon — glow bg
  static const Color primarySubtle    = Color(0x1ACCFF00); // 10% neon — light tint

  // ── White opacity variants ────────────────────────────────────────────────
  static const Color white70          = Color(0xB2FFFFFF); // Secondary text
  static const Color white60          = Color(0x99FFFFFF); // Tertiary text / meta
  static const Color white50          = Color(0x7FFFFFFF); // Hint / placeholder
  static const Color white30          = Color(0x4DFFFFFF); // Disabled
  static const Color white20          = Color(0x33FFFFFF); // Borders / dividers
  static const Color white10          = Color(0x1AFFFFFF); // Icon bg / chips

  // ── Black opacity variants ────────────────────────────────────────────────
  static const Color black95          = Color(0xF2000000); // Nav bar bg
  static const Color black80          = Color(0xCC000000); // Image gradient overlay
  static const Color black50          = Color(0x80000000); // Modal scrim

  // ── Surface / structural ──────────────────────────────────────────────────
  static const Color surface          = Color(0xFF111111); // Card / input fill
  static const Color borderDefault    = Color(0xFF333333); // Card borders
  static const Color borderSubtle     = Color(0xFF222222); // Header/footer separators

  // ── Semantic vendor roles ─────────────────────────────────────────────────
  // Active/booked slot → use primary (neon green)
  // Available slot     → use primarySubtle bg + white60 text
  // Blocked slot       → use white10 bg + white30 text
  // Pending            → use white10 bg + white60 text
  // Error / cancelled  → use error (red)
  // Revenue numbers    → use primary (neon green), bold

  // ── ONE exception ─────────────────────────────────────────────────────────
  // Section ALL-CAPS labels inside dark cards use this slate color
  static const Color sectionLabel     = Color(0xFF94A3B8); // slate-400
}
```

---

## STEP 12 — app_typography.dart

```dart
// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get textTheme => GoogleFonts.manropeTextTheme(
    const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5),
      displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.3),
      headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.3),
      titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.3),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
    ),
  );
}
```

---

## STEP 13 — app_theme.dart

```dart
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.black,
    textTheme: AppTypography.textTheme,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.black,
      secondary: AppColors.white,
      onSecondary: AppColors.black,
      surface: AppColors.black,
      onSurface: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.black,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.black,
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
        foregroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.white, width: 2),
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
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderDefault),
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
      hintStyle: const TextStyle(
        color: AppColors.white50,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      labelStyle: const TextStyle(color: AppColors.white70),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.white10,
      thickness: 1,
      space: 1,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderDefault),
      ),
      margin: EdgeInsets.zero,
    ),
  );
}
```

---

## STEP 14 — Reusable Widgets

Create these 5 shared widgets. Every screen uses them — do not rewrite them inline.

### 14a — custom_text_field.dart

```dart
// lib/core/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? errorText;
  final void Function(String)? onChanged;
  final int maxLines;

  const CustomTextField({
    super.key,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.prefixIcon,
    this.errorText,
    this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w500),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        errorText: errorText,
      ),
    );
  }
}
```

### 14b — status_chip.dart

```dart
// lib/core/widgets/status_chip.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ChipVariant { confirmed, available, pending, cancelled, blocked }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipVariant variant;

  const StatusChip({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      ChipVariant.confirmed  => (AppColors.primaryGlow, AppColors.primary),
      ChipVariant.available  => (AppColors.white10,     AppColors.white60),
      ChipVariant.pending    => (AppColors.white10,     AppColors.white60),
      ChipVariant.cancelled  => (const Color(0x1AEF4444), AppColors.error),
      ChipVariant.blocked    => (AppColors.white10,     AppColors.white30),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
```

### 14c — section_label.dart

```dart
// lib/core/widgets/section_label.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.sectionLabel,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
      ),
    );
  }
}
```

### 14d — loading_overlay.dart

```dart
// lib/core/widgets/loading_overlay.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const LoadingOverlay({super.key, required this.child, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          const ColoredBox(
            color: AppColors.black50,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
```

### 14e — vendor_card.dart (base card wrapper)

```dart
// lib/core/widgets/vendor_card.dart

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VendorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool glowing;

  const VendorCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDefault),
          boxShadow: glowing
              ? [const BoxShadow(color: AppColors.primaryGlow, blurRadius: 12)]
              : null,
        ),
        child: child,
      ),
    );
  }
}
```

---

## Component Conventions Reference

### Full-width CTA Button
```dart
SizedBox(
  width: double.infinity,
  height: 56,
  child: ElevatedButton(
    onPressed: onPressed,
    child: const Text('CONFIRM'),
  ),
)
```

### Sticky Bottom Action Bar
```dart
Container(
  decoration: const BoxDecoration(
    color: AppColors.black,
    border: Border(top: BorderSide(color: AppColors.borderSubtle)),
    boxShadow: [BoxShadow(color: AppColors.black80, blurRadius: 30, offset: Offset(0, -10))],
  ),
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
  child: SafeArea(
    top: false,
    child: SizedBox(width: double.infinity, height: 56, child: ElevatedButton(...)),
  ),
)
```

### Screen Header (custom AppBar replacement)
```dart
Container(
  decoration: const BoxDecoration(
    color: AppColors.black95,
    border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
  child: SafeArea(
    bottom: false,
    child: Row(
      children: [
        IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: () => Navigator.pop(context)),
        Expanded(child: Text('Screen Title', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center)),
        const SizedBox(width: 48), // balance the back button
      ],
    ),
  ),
)
```

### Neon Glow Box Shadow (use sparingly)
```dart
boxShadow: [const BoxShadow(color: AppColors.primaryGlow, blurRadius: 12, spreadRadius: 0)]
```

### Slot Cell — Booked
```dart
Container(
  width: 72, height: 40,
  decoration: BoxDecoration(
    color: AppColors.primaryGlow,
    borderRadius: BorderRadius.circular(8),
  ),
  alignment: Alignment.center,
  child: Text('07:00', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
)
```

### Slot Cell — Available
```dart
Container(
  width: 72, height: 40,
  decoration: BoxDecoration(
    color: AppColors.white10,
    borderRadius: BorderRadius.circular(8),
  ),
  alignment: Alignment.center,
  child: Text('08:00', style: const TextStyle(color: AppColors.white60, fontSize: 12)),
)
```

### Slot Cell — Blocked
```dart
Container(
  width: 72, height: 40,
  decoration: BoxDecoration(
    color: AppColors.white10,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: AppColors.white20),
  ),
  alignment: Alignment.center,
  child: Text('09:00', style: TextStyle(color: AppColors.white30, fontSize: 12, decoration: TextDecoration.lineThrough)),
)
```

---

## Key Rules (Never Break)

1. **Never introduce new hex codes** — only the 3 base colors + opacity variants
2. **Never use `.withOpacity()` or `.withAlpha()`** — always `const Color(0xAARRGGBB)`
3. **Always dark mode** — `ThemeMode.dark` in `main.dart`, no toggle
4. **Never hardcode text styles** — always `Theme.of(context).textTheme.*`
5. **Never hardcode colors inline** — always `AppColors.*`
6. **Card border always visible** — `Border.all(color: AppColors.borderDefault)`
7. **Red only for errors/destructive** — `AppColors.error`, nowhere else
8. **Neon glow sparingly** — only the primary interactive element per screen
9. **Button sizing** — `SizedBox(width: double.infinity, height: 56)` always

---

## Checkpoint 2 ✓

At the end of this step you have:
- `app_colors.dart`, `app_theme.dart`, `app_typography.dart` all created
- 5 core shared widgets created
- `main.dart` uses `AppTheme.darkTheme`
- App opens and shows a black screen (correct — no routes yet)
- `flutter analyze` reports zero errors

**Next: [03_auth_flow.md](./03_auth_flow.md)**
