// lib/features/onboarding/data/onboarding_status_notifier.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
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
  @override
  Future<OnboardingStatus> build() async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Always refresh to avoid acting on an expired token
    String? token = await authNotifier.refreshAccessToken();
    token ??= await authNotifier.getAccessToken();
    if (token == null) return OnboardingStatus.pendingArena;

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // ── 1. Check vendor status ──────────────────────────────────────────────
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.vendorMe), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = (body['data'] as Map<String, dynamic>?);
        final status = data?['status'] as String?;
        if (status == 'banned')    return OnboardingStatus.vendorBanned;
        if (status == 'suspended') return OnboardingStatus.vendorSuspended;
      }
    } catch (_) {
      // Network hiccup — continue; worst case we show wrong screen briefly
    }

    // ── 2. Check arenas ─────────────────────────────────────────────────────
    try {
      final res = await http
          .get(Uri.parse(ApiConfig.vendorArenas), headers: headers)
          .timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return OnboardingStatus.pendingArena;

      final body  = jsonDecode(res.body) as Map<String, dynamic>;
      final arenas = _extractList(body);

      if (arenas.isEmpty) return OnboardingStatus.pendingArena;

      // At least one arena active → vendor is fully approved
      final hasActive = arenas.any(
        (a) => (a as Map<String, dynamic>)['status'] == 'active',
      );
      if (hasActive) return OnboardingStatus.complete;

      // Arenas exist but none active — awaiting admin approval
      return OnboardingStatus.pendingApproval;
    } catch (_) {
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
