// lib/features/home/presentation/widgets/fields_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/vendor_card.dart';
import '../../../fields/data/mock_fields_repository.dart';
import '../../../fields/domain/models/field_model.dart';
import '../../../fields/presentation/pages/add_field_screen.dart';
import '../../../fields/presentation/pages/slot_management_screen.dart';
import '../../../fields/presentation/pages/edit_field_screen.dart';

class FieldsTab extends ConsumerWidget {
  const FieldsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc     = AppThemeColors.of(context);
    final fields = ref.watch(mockFieldsProvider);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Fields',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: tc.onSurface,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: AppColors.primary, size: 26),
                    tooltip: 'Add Field',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddFieldScreen()),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Field list ──────────────────────────────────────────
            Expanded(
              child: fields.isEmpty
                  ? _EmptyState(onAdd: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddFieldScreen()),
                    ))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: fields.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _FieldCard(field: fields[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field Card ────────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  final FieldModel field;
  const _FieldCard({required this.field});

  ChipVariant _chipVariant(FieldStatus s) => switch (s) {
    FieldStatus.active      => ChipVariant.confirmed,
    FieldStatus.pending     => ChipVariant.pending,
    FieldStatus.inactive    => ChipVariant.blocked,
    FieldStatus.maintenance => ChipVariant.pending,
    FieldStatus.suspended   => ChipVariant.cancelled,
  };

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return VendorCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: tc.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      field.sports.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tc.onSurface60,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: field.status.name,
                variant: _chipVariant(field.status),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Info pills
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoPill(icon: Icons.currency_rupee, label: field.formattedPrice),
              _InfoPill(icon: Icons.group, label: '${field.capacity} players'),
              _InfoPill(icon: Icons.grass, label: field.surfaceType),
            ],
          ),

          Divider(height: 24, color: tc.onSurface10),

          // Actions
          Row(
            children: [
              TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SlotManagementScreen(field: field),
                  ),
                ),
                icon: Icon(Icons.grid_view, size: 16, color: AppColors.primary),
                label: const Text(
                  'Manage Slots',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: tc.onSurface50, size: 20),
                tooltip: 'Edit field',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditFieldScreen(field: field),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info Pill ────────────────────────────────────────────────────────────

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: tc.onSurface10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: tc.onSurface50),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: tc.onSurface60, fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, size: 56, color: tc.onSurface20),
          const SizedBox(height: 16),
          Text(
            'No fields yet',
            style: TextStyle(color: tc.onSurface, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first turf field to start\nmanaging bookings.',
            textAlign: TextAlign.center,
            style: TextStyle(color: tc.onSurface50, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180, height: 48,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Field'),
            ),
          ),
        ],
      ),
    );
  }
}
