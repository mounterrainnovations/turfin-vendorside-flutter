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

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc       = AppThemeColors.of(context);
    final tt       = Theme.of(context).textTheme;
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              Text(
                '$greeting, ${_mockSummary.vendorName}',
                style: tt.titleLarge?.copyWith(color: tc.onSurface),
              ),
              const SizedBox(height: 3),
              Text(
                _mockSummary.businessName,
                style: tt.labelMedium?.copyWith(color: tc.onSurface60),
              ),

              const SizedBox(height: 28),

              // ── Revenue hero card — ONE editorial lockup per screen ──
              _HeroMetricCard(
                label: "TODAY'S REVENUE",
                value: '₹${(_mockSummary.todayRevenuePaise / 100).toStringAsFixed(0)}',
              ),

              const SizedBox(height: 10),

              // ── Secondary stats — 2-column ──────────────────────────
              IntrinsicHeight(
                child: Row(
                  children: [
                    _SecondaryMetricCard(label: 'BOOKINGS',  value: '${_mockSummary.todayBookings}'),
                    const SizedBox(width: 10),
                    _SecondaryMetricCard(label: 'OCCUPANCY', value: '${_mockSummary.occupancyPct}%'),
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
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Coming soon')),
                      ),
                      icon: const Icon(Icons.list_alt, size: 16),
                      label: const Text('All Bookings'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              const SectionLabel('NEXT CHECK-INS'),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                const _EmptyState(message: 'No upcoming check-ins today.')
              else
                ...upcoming.take(3).map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _BookingMiniCard(booking: b, showScan: true),
                )),

              const SizedBox(height: 32),

              const SectionLabel('RECENT BOOKINGS'),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                const _EmptyState(message: 'No bookings yet.')
              else
                ...recent.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
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

// ── Hero Metric Card ──────────────────────────────────────────────────────────
// Dark:  carbon card (#111111) + neon value text (#CCFF00) + neon glow
// Light: neon card (#CCFF00)  + black value text (#000000) — neon IS the surface

class _HeroMetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _HeroMetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tc     = AppThemeColors.of(context);
    final tt     = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: tc.heroCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? tc.borderDefault : AppColors.primary,
        ),
        boxShadow: isDark
            ? [const BoxShadow(color: AppColors.primaryGlow, blurRadius: 18, spreadRadius: 2)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: 10),
          Text(
            value,
            // Dark: neon text on carbon. Light: black text on neon card.
            style: tt.displayLarge?.copyWith(
              color: isDark ? AppColors.primary : const Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Secondary Metric Card ─────────────────────────────────────────────────────

class _SecondaryMetricCard extends StatelessWidget {
  final String label;
  final String value;
  const _SecondaryMetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final tt = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: tc.borderDefault),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(label),
            const SizedBox(height: 8),
            Text(
              value,
              style: tt.displayMedium?.copyWith(color: tc.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booking Mini Card ─────────────────────────────────────────────────────────

class _BookingMiniCard extends StatelessWidget {
  final VendorBookingModel booking;
  final bool showScan;
  const _BookingMiniCard({required this.booking, required this.showScan});

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
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.borderDefault),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.customerName,
                    style: tt.bodyLarge?.copyWith(color: tc.onSurface)),
                const SizedBox(height: 3),
                Text(booking.fieldName,
                    style: tt.labelMedium?.copyWith(color: tc.onSurface60)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Time chip — uses accentSurface + accentText
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tc.accentSurface,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        booking.startTime,
                        style: tt.bodySmall?.copyWith(color: tc.accentText),
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
          if (showScan)
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              ),
              icon: Icon(Icons.qr_code_scanner, color: tc.accentText, size: 22),
              tooltip: 'Scan QR',
            )
          else
            Text(
              booking.formattedAmount,
              style: tt.labelMedium?.copyWith(color: tc.accentText),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppThemeColors.of(context).onSurface50,
          ),
        ),
      ),
    );
  }
}
