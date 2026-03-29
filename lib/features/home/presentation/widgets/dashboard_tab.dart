// lib/features/home/presentation/widgets/dashboard_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../bookings/data/mock_bookings_repository.dart';
import '../../../bookings/domain/models/vendor_booking_model.dart';
import '../../../scanner/presentation/pages/scanner_screen.dart';
import '../../../earnings/presentation/pages/earnings_screen.dart';

// ── Inline mock summary data ───────────────────────────────────────────────

class _DashboardSummary {
  final String vendorName;
  final String businessName;
  final int todayRevenuePaise;
  final int todayBookings;
  final int occupancyPct;

  const _DashboardSummary({
    required this.vendorName,
    required this.businessName,
    required this.todayRevenuePaise,
    required this.todayBookings,
    required this.occupancyPct,
  });
}

const _mockSummary = _DashboardSummary(
  vendorName: 'Rajesh',
  businessName: 'Champions Arena',
  todayRevenuePaise: 420000,
  todayBookings: 7,
  occupancyPct: 82,
);

// ─────────────────────────────────────────────────────────────────────────────

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc       = AppThemeColors.of(context);
    final bookings = ref.watch(mockVendorBookingsProvider);
    final upcoming = bookings
        .where((b) => b.status == VendorBookingStatus.confirmed)
        .toList()
      ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
    final recent = bookings.reversed.take(5).toList();

    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // ── Header ──────────────────────────────────────────────
              Text(
                '$greeting, ${_mockSummary.vendorName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: tc.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _mockSummary.businessName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tc.onSurface60,
                ),
              ),

              const SizedBox(height: 24),

              // ── Stat cards ──────────────────────────────────────────
              IntrinsicHeight(
                child: Row(
                  children: [
                    _StatCard(
                      label: "TODAY'S REVENUE",
                      value: '₹${(_mockSummary.todayRevenuePaise / 100).toStringAsFixed(0)}',
                      neon: true,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(label: 'BOOKINGS', value: '${_mockSummary.todayBookings}'),
                    const SizedBox(width: 8),
                    _StatCard(label: 'OCCUPANCY', value: '${_mockSummary.occupancyPct}%'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Quick actions ────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EarningsScreen()),
                      ),
                      icon: const Icon(Icons.account_balance_wallet_outlined, size: 16),
                      label: const Text('Earnings'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        foregroundColor: tc.onSurface,
                        side: BorderSide(color: tc.borderDefault),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Coming soon')),
                        );
                      },
                      icon: const Icon(Icons.list_alt, size: 16),
                      label: const Text('All Bookings'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        foregroundColor: tc.onSurface,
                        side: BorderSide(color: tc.borderDefault),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Upcoming check-ins ───────────────────────────────────
              const SectionLabel('NEXT CHECK-INS'),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                const _EmptyState(message: 'No upcoming check-ins today.')
              else
                ...upcoming.take(3).map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BookingMiniCard(booking: b, showScan: true),
                )),

              const SizedBox(height: 28),

              // ── Recent bookings ──────────────────────────────────────
              const SectionLabel('RECENT BOOKINGS'),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                const _EmptyState(message: 'No bookings yet.')
              else
                ...recent.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _BookingMiniCard(booking: b, showScan: false),
                )),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool neon;

  const _StatCard({required this.label, required this.value, this.neon = false});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.borderDefault),
          boxShadow: neon
              ? [const BoxShadow(color: AppColors.primaryGlow, blurRadius: 12)]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: tc.sectionLabel,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: neon ? AppColors.primary : tc.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booking Mini Card ──────────────────────────────────────────────────────

class _BookingMiniCard extends StatelessWidget {
  final VendorBookingModel booking;
  final bool showScan;

  const _BookingMiniCard({required this.booking, required this.showScan});

  ChipVariant _chipVariant(VendorBookingStatus s) => switch (s) {
    VendorBookingStatus.confirmed  => ChipVariant.confirmed,
    VendorBookingStatus.completed  => ChipVariant.available,
    VendorBookingStatus.cancelled  => ChipVariant.cancelled,
    VendorBookingStatus.noShow     => ChipVariant.blocked,
    VendorBookingStatus.pending    => ChipVariant.pending,
  };

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tc.borderDefault),
      ),
      child: Row(
        children: [
          // Left: info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.customerName,
                  style: TextStyle(
                    color: tc.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  booking.fieldName,
                  style: TextStyle(color: tc.onSurface60, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Time chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGlow,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.startTime,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusChip(
                      label: booking.status.name,
                      variant: _chipVariant(booking.status),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Right: scan button or amount
          if (showScan)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
              icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
              tooltip: 'Scan QR',
            )
          else
            Text(
              booking.formattedAmount,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(message, style: TextStyle(color: tc.onSurface50, fontSize: 13)),
      ),
    );
  }
}
