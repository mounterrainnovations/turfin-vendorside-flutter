// lib/features/onboarding/presentation/widgets/onboarding_widgets.dart
//
// Shared UI primitives used across all onboarding step screens.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// ── Field label (13px w600, onSurface70) ─────────────────────────────────────

class OnbFieldLabel extends StatelessWidget {
  final String text;
  final bool optional;
  const OnbFieldLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            color: tc.onSurface70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (optional) ...[
          const SizedBox(width: 6),
          Text(
            'optional',
            style: TextStyle(
              color: tc.onSurface30,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Dropdown tile (mimics CustomTextField height + style) ─────────────────────

class OnbDropdownTile extends StatelessWidget {
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const OnbDropdownTile({
    super.key,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.borderDefault),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? placeholder,
                style: TextStyle(
                  color: value != null ? tc.onSurface : tc.onSurface30,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: tc.onSurface50,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom-sheet option picker ────────────────────────────────────────────────

Future<String?> showOnbOptionPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  String? selected,
}) async {
  final tc = AppThemeColors.of(context);

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: tc.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: tc.onSurface20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: tc.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
            // Options
            ...options.map(
              (o) => InkWell(
                onTap: () => Navigator.pop(ctx, o),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: tc.borderSubtle),
                    ),
                    color: o == selected
                        ? AppColors.primarySubtle
                        : Colors.transparent,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          o,
                          style: TextStyle(
                            color: o == selected
                                ? AppColors.primary
                                : tc.onSurface,
                            fontSize: 15,
                            fontWeight: o == selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (o == selected)
                        const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

// ── Section divider ───────────────────────────────────────────────────────────

class OnbSectionDivider extends StatelessWidget {
  const OnbSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppThemeColors.of(context).borderSubtle,
      height: 32,
      thickness: 1,
    );
  }
}
