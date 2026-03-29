// lib/features/fields/domain/models/slot_model.dart

enum VendorSlotStatus { available, booked, blocked, maintenance }

class VendorSlotModel {
  final String id;
  final String fieldId;
  final DateTime slotDate;
  final String startTime;
  final String endTime;
  final int pricePaise;
  final VendorSlotStatus status;
  final String? blockReason;

  const VendorSlotModel({
    required this.id,
    required this.fieldId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.pricePaise,
    required this.status,
    this.blockReason,
  });

  String get formattedPrice => '₹${(pricePaise / 100).toStringAsFixed(0)}';
}
