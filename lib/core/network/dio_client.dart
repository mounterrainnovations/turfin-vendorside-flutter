// lib/core/network/dio_client.dart
//
// Single Dio instance for the whole app.
// Alice is wired in only when AppEnv.showInspector is true.  Because that flag
// is a compile-time constant the Alice import and interceptor are dead code in
// production builds and are fully eliminated by Dart's tree-shaker.

import 'package:alice/alice.dart';
import 'package:alice/model/alice_configuration.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import '../config/app_env.dart';
import 'alice_dio_interceptor.dart';

class DioClient {
  DioClient._();

  // Holds the Alice instance; null in production builds.
  static Alice? alice;

  static Dio? _dio;

  static Dio get dio {
    _dio ??= _build();
    return _dio!;
  }

  // ── Initialise Alice (call once in main() before runApp) ──────────────────
  //
  // Passing showInspector as a guard means the Alice import itself is still
  // present in production (Dart can't always tree-shake based on runtime
  // guards).  The compile-time constant in AppEnv.showInspector combined with
  // kDebugMode = false in release mode is sufficient to suppress all Alice
  // activity; no notification, no shake-detector, and no UI is launched.

  static void initAlice(GlobalKey<NavigatorState> navigatorKey) {
    if (!AppEnv.showInspector) return;

    alice = Alice(
      configuration: AliceConfiguration(
        navigatorKey: navigatorKey,
        showNotification: true,     // tap notification → inspector
        showInspectorOnShake: true, // shake device → inspector
      ),
    );

    // Force rebuild so the interceptor is added to the fresh Dio instance.
    _dio = null;
  }

  // ── Build Dio ─────────────────────────────────────────────────────────────

  static Dio _build() {
    final d = Dio(
      BaseOptions(
        baseUrl: AppEnv.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
        // 4xx responses are returned, not thrown — notifiers check statusCode.
        // 5xx and network errors still throw DioException.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (AppEnv.showInspector && alice != null) {
      d.interceptors.add(AliceDioInterceptor(alice!));
    }

    return d;
  }
}
