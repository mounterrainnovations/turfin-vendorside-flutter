// lib/features/onboarding/data/arena_onboarding_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';

// ── TurfGroupData ─────────────────────────────────────────────────────────────

class TurfGroupData {
  final String sport;       // SportType enum value e.g. 'CRICKET'
  final String surfaceType; // SurfaceType enum value e.g. 'ARTIFICIAL_TURF'
  final String sizeFormat;  // optional, e.g. '7v7'
  final int priceRupees;    // stored in ₹, sent as ×100 paise
  final int count;          // 1–10

  const TurfGroupData({
    required this.sport,
    required this.surfaceType,
    this.sizeFormat = '',
    required this.priceRupees,
    this.count = 1,
  });

  TurfGroupData copyWith({
    String? sport,
    String? surfaceType,
    String? sizeFormat,
    int? priceRupees,
    int? count,
  }) =>
      TurfGroupData(
        sport: sport ?? this.sport,
        surfaceType: surfaceType ?? this.surfaceType,
        sizeFormat: sizeFormat ?? this.sizeFormat,
        priceRupees: priceRupees ?? this.priceRupees,
        count: count ?? this.count,
      );
}

// ── ArenaOnboardingState ──────────────────────────────────────────────────────

class ArenaOnboardingState {
  // Page 1 — Arena Details
  final String arenaName;
  final String weekdayOpen;
  final String weekdayClose;
  final String weekendOpen;
  final String weekendClose;
  final List<TurfGroupData> turfGroups;

  // Page 2 — Location
  final String fullAddress;
  final String houseNumber;
  final String city;
  final String state;
  final String pinCode;
  final String landmark;
  final String googleMapsLink;
  final double? latitude;
  final double? longitude;

  // Page 3 — Amenities
  final List<String> amenities;

  const ArenaOnboardingState({
    this.arenaName = '',
    this.weekdayOpen = '',
    this.weekdayClose = '',
    this.weekendOpen = '',
    this.weekendClose = '',
    this.turfGroups = const [],
    this.fullAddress = '',
    this.houseNumber = '',
    this.city = '',
    this.state = '',
    this.pinCode = '',
    this.landmark = '',
    this.googleMapsLink = '',
    this.latitude,
    this.longitude,
    this.amenities = const [],
  });

  ArenaOnboardingState copyWith({
    String? arenaName,
    String? weekdayOpen,
    String? weekdayClose,
    String? weekendOpen,
    String? weekendClose,
    List<TurfGroupData>? turfGroups,
    String? fullAddress,
    String? houseNumber,
    String? city,
    String? state,
    String? pinCode,
    String? landmark,
    String? googleMapsLink,
    double? latitude,
    double? longitude,
    List<String>? amenities,
  }) =>
      ArenaOnboardingState(
        arenaName: arenaName ?? this.arenaName,
        weekdayOpen: weekdayOpen ?? this.weekdayOpen,
        weekdayClose: weekdayClose ?? this.weekdayClose,
        weekendOpen: weekendOpen ?? this.weekendOpen,
        weekendClose: weekendClose ?? this.weekendClose,
        turfGroups: turfGroups ?? this.turfGroups,
        fullAddress: fullAddress ?? this.fullAddress,
        houseNumber: houseNumber ?? this.houseNumber,
        city: city ?? this.city,
        state: state ?? this.state,
        pinCode: pinCode ?? this.pinCode,
        landmark: landmark ?? this.landmark,
        googleMapsLink: googleMapsLink ?? this.googleMapsLink,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        amenities: amenities ?? this.amenities,
      );
}

// ── ArenaOnboardingNotifier ───────────────────────────────────────────────────

class ArenaOnboardingNotifier extends Notifier<ArenaOnboardingState> {
  @override
  ArenaOnboardingState build() => const ArenaOnboardingState(
        turfGroups: [
          TurfGroupData(sport: '', surfaceType: '', priceRupees: 0),
        ],
      );

  void update(ArenaOnboardingState s) => state = s;

  void setArenaName(String v) => state = state.copyWith(arenaName: v);
  void setWeekdayOpen(String v) => state = state.copyWith(weekdayOpen: v);
  void setWeekdayClose(String v) => state = state.copyWith(weekdayClose: v);
  void setWeekendOpen(String v) => state = state.copyWith(weekendOpen: v);
  void setWeekendClose(String v) => state = state.copyWith(weekendClose: v);

  void setTurfGroup(int index, TurfGroupData group) {
    final list = [...state.turfGroups];
    list[index] = group;
    state = state.copyWith(turfGroups: list);
  }

  void addTurfGroup() {
    state = state.copyWith(turfGroups: [
      ...state.turfGroups,
      const TurfGroupData(sport: '', surfaceType: '', priceRupees: 0),
    ]);
  }

  void removeTurfGroup(int index) {
    if (state.turfGroups.length <= 1) return;
    final list = [...state.turfGroups]..removeAt(index);
    state = state.copyWith(turfGroups: list);
  }

  void setFullAddress(String v) => state = state.copyWith(fullAddress: v);
  void setHouseNumber(String v) => state = state.copyWith(houseNumber: v);
  void setCity(String v) => state = state.copyWith(city: v);
  void setArenaState(String v) => state = state.copyWith(state: v);
  void setPinCode(String v) => state = state.copyWith(pinCode: v);
  void setLandmark(String v) => state = state.copyWith(landmark: v);
  void setGoogleMapsLink(String v) => state = state.copyWith(googleMapsLink: v);
  void setLocation(double lat, double lng) =>
      state = state.copyWith(latitude: lat, longitude: lng);
  void setAmenities(List<String> v) => state = state.copyWith(amenities: v);

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> submit(String accessToken) async {
    final s = state;

    // Address at the arena level (shared by all turfs)
    final address = <String, dynamic>{
      'country': 'India',
      'city': s.city,
      'state': s.state,
      'pinCode': s.pinCode,
      if (s.latitude != null) 'latitude': s.latitude,
      if (s.longitude != null) 'longitude': s.longitude,
      if (s.fullAddress.isNotEmpty) 'towerBlock': s.fullAddress,
      if (s.houseNumber.isNotEmpty) 'houseNumber': s.houseNumber,
      if (s.landmark.isNotEmpty) 'landmark': s.landmark,
      if (s.googleMapsLink.isNotEmpty) 'googleMapsLink': s.googleMapsLink,
    };

    // Build nested turfs list — each group entry has sport + count, backend fans out
    final turfs = <Map<String, dynamic>>[];
    for (final group in s.turfGroups) {
      final turf = <String, dynamic>{
        'sport': group.sport,
        'count': group.count,
        'surfaceType': group.surfaceType,
        'standardPricePaise': group.priceRupees * 100,
        if (s.weekdayOpen.isNotEmpty) 'weekdayOpen': s.weekdayOpen,
        if (s.weekdayClose.isNotEmpty) 'weekdayClose': s.weekdayClose,
        if (s.weekendOpen.isNotEmpty) 'weekendOpen': s.weekendOpen,
        if (s.weekendClose.isNotEmpty) 'weekendClose': s.weekendClose,
        if (group.sizeFormat.isNotEmpty) 'sizeFormat': group.sizeFormat,
      };
      turfs.add(turf);
    }

    final body = <String, dynamic>{
      'name': s.arenaName,
      'address': address,
      'turfs': turfs,
      if (s.amenities.isNotEmpty) 'amenities': s.amenities,
    };

    final Response<dynamic> response;
    try {
      response = await DioClient.dio.post(
        ApiConfig.kVendorArenas,
        data: body,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
    } on DioException catch (e) {
      throw 'Network error: ${e.message}';
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      final decoded = response.data as Map<String, dynamic>?;
      final error   = decoded?['error'] as Map<String, dynamic>?;
      String msg;
      if (error != null) {
        final details = error['details'] as Map<String, dynamic>?;
        final errors  = details?['errors'];
        if (errors is List && errors.isNotEmpty) {
          msg = errors.map((e) => e.toString()).join(', ');
        } else {
          msg = error['message'] as String? ?? '[${response.statusCode}]';
        }
      } else {
        msg = '[${response.statusCode}]';
      }
      throw msg;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final arenaOnboardingProvider =
    NotifierProvider<ArenaOnboardingNotifier, ArenaOnboardingState>(
        ArenaOnboardingNotifier.new);
