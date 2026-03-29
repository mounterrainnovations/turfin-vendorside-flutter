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
    final tc = AppThemeColors.of(context);
    final (bg, fg) = switch (variant) {
      ChipVariant.confirmed => (AppColors.primaryGlow,        AppColors.primary),
      ChipVariant.available => (tc.onSurface10,               tc.onSurface60),
      ChipVariant.pending   => (tc.onSurface10,               tc.onSurface60),
      ChipVariant.cancelled => (const Color(0x1AEF4444),      AppColors.error),
      ChipVariant.blocked   => (tc.onSurface10,               tc.onSurface30),
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
