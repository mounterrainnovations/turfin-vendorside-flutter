// lib/features/onboarding/data/arena_options_provider.dart
//
// Fetches sports and amenities lists from the backend.
// Falls back to hardcoded defaults if the API is unreachable.

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';

const _defaultSports = [
  'Football',
  'Cricket',
  'Badminton',
  'Box Cricket',
  'Pickleball',
  'Tennis',
  'Others',
];

const _defaultAmenities = [
  'Parking',
  'Washroom',
  'Drinking Water',
  'Flood Lights',
  'Seating Area',
  'Changing Room',
  'Cafeteria',
  'Shower',
  'Equipment Rental',
  'WiFi',
  'Other Amenities',
];

List<String> _parseList(dynamic data) {
  if (data is List) return data.map((e) => e.toString()).toList();
  if (data is Map && data['data'] is List) {
    return (data['data'] as List).map((e) => e.toString()).toList();
  }
  return [];
}

final sportsOptionsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final res = await DioClient.dio.get(
      ApiConfig.kSports,
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    if (res.statusCode == 200) {
      final list = _parseList(res.data);
      if (list.isNotEmpty) return list;
    }
  } catch (_) {}
  return _defaultSports;
});

final amenitiesOptionsProvider = FutureProvider<List<String>>((ref) async {
  try {
    final res = await DioClient.dio.get(
      ApiConfig.kAmenities,
      options: Options(
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    if (res.statusCode == 200) {
      final list = _parseList(res.data);
      if (list.isNotEmpty) return list;
    }
  } catch (_) {}
  return _defaultAmenities;
});
