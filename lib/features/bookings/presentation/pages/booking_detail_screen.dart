// lib/features/bookings/presentation/pages/booking_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/models/vendor_booking_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final VendorBookingModel booking;
  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  late VendorBookingStatus _status;

  @override
  void initState() {
    super.initState();
    _status = widget.booking.status;
  }

  bool get _isToday {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(
      widget.booking.bookingDate.year,
      widget.booking.bookingDate.month,
      widget.booking.bookingDate.day,
    );
    return d == today;
  }

  bool get _canAct =>
      _status == VendorBookingStatus.confirmed && _isToday;

  Future<void> _callCustomer() async {
    final uri = Uri(scheme: 'tel', path: widget.booking.customerPhone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _confirmAction({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    final tc = AppThemeColors.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tc.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w700)),
        content: Text(message, style: TextStyle(color: tc.onSurface60)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: tc.onSurface50)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel, style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirm();
  }

  ChipVariant _chipVariant(VendorBookingStatus s) => switch (s) {
    VendorBookingStatus.confirmed => ChipVariant.confirmed,
    VendorBookingStatus.completed => ChipVariant.available,
    VendorBookingStatus.cancelled => ChipVariant.cancelled,
    VendorBookingStatus.noShow    => ChipVariant.blocked,
    VendorBookingStatus.pending   => ChipVariant.pending,
  };

  String _statusLabel(VendorBookingStatus s) => switch (s) {
    VendorBookingStatus.confirmed => 'Confirmed',
    VendorBookingStatus.completed => 'Checked In',
    VendorBookingStatus.cancelled => 'Cancelled',
    VendorBookingStatus.noShow    => 'No Show',
    VendorBookingStatus.pending   => 'Pending',
  };

  @override
  Widget build(BuildContext context) {
    final tc      = AppThemeColors.of(context);
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: Column(
        children: [
          // ── Custom header ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: tc.navBg,
              border: Border(bottom: BorderSide(color: tc.borderSubtle)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: tc.onSurface, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Booking Detail',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: tc.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: StatusChip(
                      label: _statusLabel(_status),
                      variant: _chipVariant(_status),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable body ────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Booking reference card ─────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('BOOKING REFERENCE'),
                        const SizedBox(height: 10),
                        Text(
                          '#${booking.id}',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: tc.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (booking.qrCodeData != null) ...[
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: QrImageView(
                                data: booking.qrCodeData!,
                                version: QrVersions.auto,
                                size: 160,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Color(0xFF000000),
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 16),
                          Center(
                            child: Container(
                              width: 160, height: 160,
                              decoration: BoxDecoration(
                                color: tc.onSurface10,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: tc.borderDefault),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.qr_code, size: 48, color: tc.onSurface30),
                                  const SizedBox(height: 8),
                                  Text(
                                    'QR available\nafter backend integration',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: tc.onSurface30, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Customer card ──────────────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('CUSTOMER'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Initials avatar
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGlow,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                booking.customerName
                                    .split(' ')
                                    .map((w) => w.isNotEmpty ? w[0] : '')
                                    .take(2)
                                    .join(),
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  booking.customerName,
                                  style: TextStyle(
                                    color: tc.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking.customerPhone,
                                  style: TextStyle(color: tc.onSurface60, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: OutlinedButton.icon(
                            onPressed: _callCustomer,
                            icon: const Icon(Icons.phone, size: 16),
                            label: const Text('Call Customer'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Booking details card ───────────────────────────
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('BOOKING DETAILS'),
                        const SizedBox(height: 12),
                        _DetailRow(
                          icon: Icons.sports_soccer,
                          text: booking.fieldName,
                          color: tc.onSurface,
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.calendar_today,
                          text: booking.dateLabel,
                          color: tc.onSurface60,
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.access_time,
                          text: '${booking.startTime} – ${booking.endTime}',
                          color: tc.onSurface60,
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.currency_rupee,
                          text: booking.formattedAmount,
                          color: AppColors.primary,
                          bold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Actions ────────────────────────────────────────
                  if (_canAct) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _confirmAction(
                          title: 'Confirm Check-In',
                          message:
                              'Mark ${booking.customerName} as checked in for ${booking.startTime}?',
                          confirmLabel: 'Check In',
                          confirmColor: AppColors.primary,
                          onConfirm: () => setState(
                            () => _status = VendorBookingStatus.completed,
                          ),
                        ),
                        child: const Text('MARK AS CHECKED IN'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () => _confirmAction(
                          title: 'Mark No Show',
                          message:
                              'Mark ${booking.customerName} as a no-show? This cannot be undone.',
                          confirmLabel: 'Mark No Show',
                          confirmColor: AppColors.error,
                          onConfirm: () => setState(
                            () => _status = VendorBookingStatus.noShow,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error, width: 1.5),
                        ),
                        child: const Text('MARK NO SHOW'),
                      ),
                    ),
                  ] else if (_status == VendorBookingStatus.completed) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGlow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Customer checked in',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tc.borderDefault),
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  const _DetailRow({
    required this.icon,
    required this.text,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: tc.onSurface50),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
