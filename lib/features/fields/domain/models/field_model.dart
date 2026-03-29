// lib/features/fields/domain/models/field_model.dart

enum FieldStatus { active, inactive, pending, maintenance, suspended }

class FieldModel {
  final String id;
  final String name;
  final List<String> sports;
  final List<String> amenities;
  final String surfaceType;
  final int capacity;
  final int standardPricePaise;
  final String weekdayOpen;
  final String weekdayClose;
  final String weekendOpen;
  final String weekendClose;
  final FieldStatus status;

  const FieldModel({
    required this.id,
    required this.name,
    required this.sports,
    required this.amenities,
    required this.surfaceType,
    required this.capacity,
    required this.standardPricePaise,
    required this.weekdayOpen,
    required this.weekdayClose,
    required this.weekendOpen,
    required this.weekendClose,
    required this.status,
  });

  String get formattedPrice =>
      '₹${(standardPricePaise / 100).toStringAsFixed(0)}/hr';
}
