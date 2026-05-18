// lib/features/onboarding/data/onboarding_status_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/data/auth_notifier.dart';

enum OnboardingStatus {
  pendingArena,    // no arenas created yet → show arena creation form
  pendingApproval, // arena(s) created but none active → show under-review screen
  complete,        // at least one arena is active → show dashboard
  vendorBanned,
  vendorSuspended,
}

class OnboardingStatusNotifier
    extends AutoDisposeAsyncNotifier<OnboardingStatus> {
  Dio get _dio => DioClient.dio;

  @override
  Future<OnboardingStatus> build() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Always refresh to avoid acting on an expired token.
    String? token = await authNotifier.refreshAccessToken();
    token ??= await authNotifier.getAccessToken();
    if (token == null) return OnboardingStatus.pendingArena;

    final headers = {'Authorization': 'Bearer $token'};

    // ── 1. Vendor account status ────────────────────────────────────────────
    try {
      final res = await _dio.get(
        ApiConfig.kVendorMe,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      if (res.statusCode == 200) {
        final status =
            ((res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?)?['status']
                as String?;
        if (status == 'banned')    return OnboardingStatus.vendorBanned;
        if (status == 'suspended') return OnboardingStatus.vendorSuspended;
      }
    } on DioException catch (_) {
      // Network hiccup — continue; worst case we show wrong screen briefly.
    }

    // ── 2. Arena check ──────────────────────────────────────────────────────
    try {
      final res = await _dio.get(
        ApiConfig.kVendorArenas,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );

      if (res.statusCode != 200) return OnboardingStatus.pendingArena;

      final arenas = _extractList(res.data as Map<String, dynamic>);
      if (arenas.isEmpty) return OnboardingStatus.pendingArena;

      // At least one active arena → vendor is fully live.
      final hasActive = arenas.any(
        (a) => (a as Map<String, dynamic>)['status'] == 'active',
      );
      return hasActive
          ? OnboardingStatus.complete
          : OnboardingStatus.pendingApproval;
    } on DioException catch (_) {
      return OnboardingStatus.pendingArena;
    }
  }

  List<dynamic> _extractList(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is List) return data;
    if (data is Map) {
      final items = data['items'];
      if (items is List) return items;
    }
    return [];
  }
}

final onboardingStatusProvider = AsyncNotifierProvider.autoDispose<
    OnboardingStatusNotifier, OnboardingStatus>(OnboardingStatusNotifier.new);
