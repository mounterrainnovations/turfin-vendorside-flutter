// lib/features/bookings/domain/models/vendor_booking_model.dart

enum VendorBookingStatus { confirmed, cancelled, completed, noShow, pending }

class VendorBookingModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String fieldName;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final int totalAmountPaise;
  final VendorBookingStatus status;
  final String? qrCodeData;

  const VendorBookingModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.fieldName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmountPaise,
    required this.status,
    this.qrCodeData,
  });

  String get formattedAmount => '₹${(totalAmountPaise / 100).toStringAsFixed(0)}';

  String get dateLabel {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d     = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    if (d == today) return 'Today';
    if (d == today.add(const Duration(days: 1))) return 'Tomorrow';
    return '${bookingDate.day} ${_month(bookingDate.month)}';
  }

  static String _month(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ][m];
}
