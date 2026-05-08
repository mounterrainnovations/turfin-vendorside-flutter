// lib/core/widgets/section_label.dart
//
// {typography.utilityXS}: 9px w700 ls 1.5 — always ALL CAPS.
// Color: {colors.sectionLabel} (#94A3B8).

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppThemeColors.of(context).sectionLabel,
      ),
    );
  }
}
