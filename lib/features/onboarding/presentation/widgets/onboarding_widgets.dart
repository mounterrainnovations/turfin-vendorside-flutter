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

// ── Section header (section letter + title) ───────────────────────────────────

class OnbSectionHeader extends StatelessWidget {
  final String section;
  final String title;
  const OnbSectionHeader({super.key, required this.section, required this.title});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section,
          style: TextStyle(
            color: tc.sectionLabel,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: tc.onSurface,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
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

// ── Multi-select tile ─────────────────────────────────────────────────────────

class OnbMultiSelectTile extends StatelessWidget {
  final List<String> selected;
  final String placeholder;
  final VoidCallback onTap;

  const OnbMultiSelectTile({
    super.key,
    required this.selected,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final hasSelected = selected.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasSelected ? AppColors.primary70 : tc.borderDefault,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasSelected ? '${selected.length} selected' : placeholder,
                style: TextStyle(
                  color: hasSelected ? tc.onSurface : tc.onSurface30,
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

// ── Selected items chips row ──────────────────────────────────────────────────

class OnbSelectedChips extends StatelessWidget {
  final List<String> items;
  const OnbSelectedChips({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: items
          .map(
            (item) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Time picker tile ──────────────────────────────────────────────────────────

class OnbTimePickerTile extends StatelessWidget {
  final String? value;
  final String placeholder;
  final VoidCallback onTap;

  const OnbTimePickerTile({
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
            Icon(Icons.access_time_rounded, color: tc.onSurface50, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null && value!.isNotEmpty ? value! : placeholder,
                style: TextStyle(
                  color: (value != null && value!.isNotEmpty)
                      ? tc.onSurface
                      : tc.onSurface30,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                color: tc.onSurface50, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Day picker chips ──────────────────────────────────────────────────────────

class OnbDayPicker extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const OnbDayPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _days.map((day) {
        final isSelected = selected.contains(day);
        return GestureDetector(
          onTap: () {
            final newList = List<String>.from(selected);
            if (isSelected) {
              newList.remove(day);
            } else {
              newList.add(day);
            }
            onChanged(newList);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : tc.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected ? AppColors.primary : tc.borderDefault,
              ),
            ),
            child: Text(
              day,
              style: TextStyle(
                color: isSelected ? Colors.black : tc.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Bottom-sheet single-select option picker ──────────────────────────────────

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
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: tc.onSurface20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
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
            Divider(height: 1, color: tc.borderSubtle),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final o = options[i];
                  final isSelected = o == selected;
                  return InkWell(
                    onTap: () => Navigator.pop(ctx, o),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: tc.borderSubtle),
                        ),
                        color: isSelected
                            ? tc.onSurface10
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              o,
                              style: TextStyle(
                                color: tc.onSurface,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_rounded,
                                color: tc.onSurface, size: 18),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ── Bottom-sheet multi-select picker ─────────────────────────────────────────

Future<List<String>?> showOnbMultiSelectPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  required List<String> selected,
}) async {
  final tc = AppThemeColors.of(context);
  List<String> temp = List.from(selected);

  return showModalBottomSheet<List<String>>(
    context: context,
    backgroundColor: tc.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModalState) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollCtrl) => Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: tc.onSurface20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style:
                          Theme.of(ctx).textTheme.titleLarge?.copyWith(
                                color: tc.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, temp),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: AppThemeColors.of(ctx).accentText,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: tc.borderSubtle),
            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final o = options[i];
                  final isSelected = temp.contains(o);
                  return InkWell(
                    onTap: () => setModalState(() {
                      if (isSelected) {
                        temp.remove(o);
                      } else {
                        temp.add(o);
                      }
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: tc.borderSubtle)),
                        color: isSelected
                            ? tc.onSurface10
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              o,
                              style: TextStyle(
                                color: tc.onSurface,
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : tc.borderDefault,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    size: 14, color: Colors.black)
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
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
