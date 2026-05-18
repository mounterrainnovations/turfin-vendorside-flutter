// lib/core/config/api_config.dart

import 'app_env.dart';

class ApiConfig {
  // ── Base URL ───────────────────────────────────────────────────────────────
  // Used by DioClient's BaseOptions and any remaining package:http call sites.
  static String get baseUrl => AppEnv.apiBaseUrl;

  // ── Full URLs (package:http legacy call sites) ─────────────────────────────
  static String get signUp   => '$baseUrl/auth/signup';
  static String get signIn   => '$baseUrl/auth/signin';
  static String get signOut  => '$baseUrl/auth/signout';
  static String get refresh  => '$baseUrl/auth/refresh';

  static String get vendorMe    => '$baseUrl/vendors/me';
  static String get vendorTurfs => '$baseUrl/vendors/turfs';
  static String get vendorArenas => '$baseUrl/vendors/arenas';

  static String get slots     => '$baseUrl/slots';
  static String get bookings  => '$baseUrl/bookings/vendor';
  static String get fields    => '$baseUrl/fields';

  static String get kycSubmit      => '$baseUrl/kyc/me/submit';
  static String get kycMe          => '$baseUrl/kyc/me';
  static String get storageUpload  => '$baseUrl/storage/upload-url';
  static String get storageView    => '$baseUrl/storage/view-url';

  static String get earnings  => '$baseUrl/payments/vendor';
  static String get dashboard => '$baseUrl/dashboard/vendor';
  static String get sports    => '$baseUrl/sports';
  static String get amenities => '$baseUrl/amenities';

  // ── Paths only (for Dio — DioClient.baseUrl owns the host) ─────────────────
  static const kSignUp   = '/auth/signup';
  static const kSignIn   = '/auth/signin';
  static const kSignOut  = '/auth/signout';
  static const kRefresh  = '/auth/refresh';

  static const kVendorMe     = '/vendors/me';
  static const kVendorTurfs  = '/vendors/turfs';
  static const kVendorArenas = '/vendors/arenas';

  static const kSlots    = '/slots';
  static const kBookings = '/bookings/vendor';
  static const kFields   = '/fields';

  static const kKycSubmit     = '/kyc/me/submit';
  static const kKycMe         = '/kyc/me';
  static const kStorageUpload = '/storage/upload-url';
  static const kStorageView   = '/storage/view-url';

  static const kEarnings  = '/payments/vendor';
  static const kDashboard = '/dashboard/vendor';
  static const kSports    = '/sports';
  static const kAmenities = '/amenities';
}
