// lib/core/widgets/status_chip.dart
//
// {rounded.pill} = 30px per DESIGN.md.
// "confirmed" uses tc.accentSurface + tc.accentText so it adapts between
// light (pale neon mint + dark text) and dark (neon glow + neon text).

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ChipVariant { confirmed, available, pending, cancelled, blocked }

class StatusChip extends StatelessWidget {
  final String label;
  final ChipVariant variant;

  const StatusChip({super.key, required this.label, required this.variant});

  @override
  Widget build(BuildContext context) {
    final tc     = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bg, fg) = switch (variant) {
      ChipVariant.confirmed => isDark
          ? (tc.accentSurface,        tc.accentText)          // neon glow + neon text
          : (const Color(0xFF111111), const Color(0xFFFFFFFF)), // ink chip + white text
      ChipVariant.available => (tc.onSurface10,               tc.onSurface60),
      ChipVariant.pending   => (tc.onSurface10,               tc.onSurface60),
      ChipVariant.cancelled => (const Color(0x1AEF4444),      AppColors.error),
      ChipVariant.blocked   => (tc.onSurface10,               tc.onSurface30),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: fg),
      ),
    );
  }
}
