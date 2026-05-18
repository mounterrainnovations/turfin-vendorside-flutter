// lib/core/config/app_env.dart
//
// Environment is injected at build time via --dart-define=FLAVOR=<value>.
// Because this is a compile-time constant, dead branches are tree-shaken:
// the Alice/inspector code is completely absent from the production binary.
//
// Usage:
//   flutter run                                     → FLAVOR defaults to "debug"
//   flutter run  --dart-define=FLAVOR=staging       → staging env, inspector ON
//   flutter build apk --dart-define=FLAVOR=production → production, inspector OFF

import 'package:flutter/foundation.dart';

enum Flavor { debug, staging, production }

class AppEnv {
  AppEnv._();

  static const _raw =
      String.fromEnvironment('FLAVOR', defaultValue: 'debug');

  static final Flavor flavor = switch (_raw) {
    'production' => Flavor.production,
    'staging'    => Flavor.staging,
    _            => Flavor.debug,
  };

  // Base URL per environment
  static String get apiBaseUrl => switch (flavor) {
    Flavor.production => 'https://akuma.turfinapp.com/api/v1',
    Flavor.staging    => 'https://akuma.turfinapp.com/api/v1', // swap when staging env exists
    Flavor.debug      => 'http://192.168.56.1:3000/api/v1',
  };

  // Show the Alice network inspector in debug and staging; never in production.
  // kDebugMode also catches plain `flutter run` without --dart-define.
  static bool get showInspector =>
      kDebugMode || flavor == Flavor.debug || flavor == Flavor.staging;

  static bool get isProduction => flavor == Flavor.production;
}
