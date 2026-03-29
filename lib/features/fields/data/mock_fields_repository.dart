// lib/features/fields/data/mock_fields_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/field_model.dart';

final mockFieldsProvider = Provider<List<FieldModel>>((ref) => const [
  FieldModel(
    id: 'F001',
    name: 'Field A',
    sports: ['Football', 'Cricket'],
    amenities: ['parking', 'flood_lights', 'changing_room'],
    surfaceType: 'Artificial Turf',
    capacity: 22,
    standardPricePaise: 60000,
    weekdayOpen: '06:00 AM',
    weekdayClose: '11:00 PM',
    weekendOpen: '06:00 AM',
    weekendClose: '11:00 PM',
    status: FieldStatus.active,
  ),
  FieldModel(
    id: 'F002',
    name: 'Field B',
    sports: ['Cricket'],
    amenities: ['parking', 'cafeteria'],
    surfaceType: 'Natural Grass',
    capacity: 22,
    standardPricePaise: 40000,
    weekdayOpen: '06:00 AM',
    weekdayClose: '10:00 PM',
    weekendOpen: '06:00 AM',
    weekendClose: '10:00 PM',
    status: FieldStatus.active,
  ),
]);
