// lib/features/home/presentation/widgets/bookings_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/vendor_card.dart';
import '../../../bookings/data/mock_bookings_repository.dart';
import '../../../bookings/domain/models/vendor_booking_model.dart';
import '../../../bookings/presentation/pages/booking_detail_screen.dart';

// ── Filter state ────────────────────────────────────────────────────────────

final _bookingFilterProvider = StateProvider<VendorBookingStatus?>((ref) => null);

// ─────────────────────────────────────────────────────────────────────────────

class BookingsTab extends ConsumerWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc         = AppThemeColors.of(context);
    final allBookings = ref.watch(mockVendorBookingsProvider);
    final filter     = ref.watch(_bookingFilterProvider);

    final filtered = filter == null
        ? allBookings
        : allBookings.where((b) => b.status == filter).toList();

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Text(
                'Bookings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: tc.onSurface,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Filter pills ────────────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterPill(label: 'All',       status: null,                         current: filter),
                  _FilterPill(label: 'Confirmed', status: VendorBookingStatus.confirmed, current: filter),
                  _FilterPill(label: 'Completed', status: VendorBookingStatus.completed, current: filter),
                  _FilterPill(label: 'Cancelled', status: VendorBookingStatus.cancelled, current: filter),
                  _FilterPill(label: 'No Show',   status: VendorBookingStatus.noShow,   current: filter),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Booking list ────────────────────────────────────────
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No bookings found.',
                        style: TextStyle(color: tc.onSurface50, fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _BookingCard(booking: filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Pill ─────────────────────────────────────────────────────────────

class _FilterPill extends ConsumerWidget {
  final String label;
  final VendorBookingStatus? status;
  final VendorBookingStatus? current;

  const _FilterPill({
    required this.label,
    required this.status,
    required this.current,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc       = AppThemeColors.of(context);
    final isActive = status == current;

    return GestureDetector(
      onTap: () => ref.read(_bookingFilterProvider.notifier).state = status,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : tc.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : tc.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF000000) : tc.onSurface60,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Booking Card ─────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final VendorBookingModel booking;
  const _BookingCard({required this.booking});

  ChipVariant _chipVariant(VendorBookingStatus s) => switch (s) {
    VendorBookingStatus.confirmed => ChipVariant.confirmed,
    VendorBookingStatus.completed => ChipVariant.available,
    VendorBookingStatus.cancelled => ChipVariant.cancelled,
    VendorBookingStatus.noShow    => ChipVariant.blocked,
    VendorBookingStatus.pending   => ChipVariant.pending,
  };

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return VendorCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingDetailScreen(booking: booking),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: tc.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  booking.fieldName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tc.onSurface60,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${booking.dateLabel} · ${booking.startTime} – ${booking.endTime}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: tc.onSurface50,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Right: chip + amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusChip(
                label: booking.status.name,
                variant: _chipVariant(booking.status),
              ),
              const SizedBox(height: 8),
              Text(
                booking.formattedAmount,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
