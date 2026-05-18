// lib/features/auth/data/auth_notifier.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';

// ── Storage key constants ──────────────────────────────────────────────────

const _kAccessToken  = 'vendor_access_token';
const _kRefreshToken = 'vendor_refresh_token';
const _kIdentityId   = 'vendor_identity_id';
const _kEmail        = 'vendor_email';
const _kVendorId     = 'vendor_id';

// ── SignupFormData — holds all 4 pages of signup form data ─────────────────

class SignupFormData {
  // Page 1 — Account
  final String email;
  final String password;

  // Page 2 — Business Info
  final String ownerFullName;
  final String businessName;
  final String businessType; // 'individual' | 'company' | 'partnership'
  final String phone;
  final String? whatsapp;
  final String? gstNumber;

  // Page 3 — Address
  final String addressType;
  final String? houseNumber;
  final String? floor;
  final String? towerBlock;
  final String? landmark;
  final String city;
  final String state;
  final String pinCode;
  final String country;
  final double? latitude;
  final double? longitude;

  // Page 4 — Banking
  final String bankName;
  final String accountHolderName;
  final String accountNumber;
  final String ifsc;

  const SignupFormData({
    required this.email,
    required this.password,
    required this.ownerFullName,
    required this.businessName,
    required this.businessType,
    required this.phone,
    this.whatsapp,
    this.gstNumber,
    required this.addressType,
    this.houseNumber,
    this.floor,
    this.towerBlock,
    this.landmark,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.country,
    this.latitude,
    this.longitude,
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.ifsc,
  });

  Map<String, dynamic> toJson() {
    final address = <String, dynamic>{
      'type': addressType,
      'city': city,
      'state': state,
      'pinCode': pinCode,
      'country': country,
      'contactPhone': phone,
      if (houseNumber != null && houseNumber!.isNotEmpty) 'houseNumber': houseNumber,
      if (floor != null && floor!.isNotEmpty) 'floor': floor,
      if (towerBlock != null && towerBlock!.isNotEmpty) 'towerBlock': towerBlock,
      if (landmark != null && landmark!.isNotEmpty) 'landmark': landmark,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
    return {
      'email': email,
      'password': password,
      'role': 'vendor_owner',
      'vendorProfile': {
        'ownerFullName': ownerFullName,
        'businessName': businessName,
        'businessType': businessType,
        'phone': phone,
        if (whatsapp != null && whatsapp!.isNotEmpty) 'whatsapp': whatsapp,
        if (gstNumber != null && gstNumber!.isNotEmpty) 'gstNumber': gstNumber,
        'address': address,
        'bankingDetails': {
          'bankName': bankName,
          'accountHolderName': accountHolderName,
          'accountNumber': accountNumber,
          'ifsc': ifsc,
        },
      },
    };
  }
}

// ── AuthState ──────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoggedIn;
  final String? identityId;
  final String? vendorId;
  final String? email;
  final List<String> roles;
  final bool profileCompleted;

  const AuthState({
    this.isLoggedIn = false,
    this.identityId,
    this.vendorId,
    this.email,
    this.roles = const [],
    this.profileCompleted = false,
  });

  bool get isVendor => roles.contains('vendor_owner');
}

// ── AuthNotifier ───────────────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<AuthState> {
  final _storage = const FlutterSecureStorage();
  Dio get _dio => DioClient.dio;

  @override
  Future<AuthState> build() async {
    final token      = await _storage.read(key: _kAccessToken);
    final identityId = await _storage.read(key: _kIdentityId);
    final email      = await _storage.read(key: _kEmail);
    final vendorId   = await _storage.read(key: _kVendorId);

    if (token == null || identityId == null) return const AuthState();

    return AuthState(
      isLoggedIn: true,
      identityId: identityId,
      vendorId: vendorId,
      email: email,
      roles: const ['vendor_owner'],
      profileCompleted: true,
    );
  }

  // ── Sign Up ────────────────────────────────────────────────────────────────

  Future<void> signUp(SignupFormData data) async {
    state = const AsyncValue.loading();
    try {
      final res = await _dio.post(ApiConfig.kSignUp, data: data.toJson());

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw _mapErrorCode(
          (res.data as Map<String, dynamic>?)?['errorCode'] as String? ?? 'UNKNOWN_ERROR',
        );
      }

      final body     = res.data as Map<String, dynamic>;
      final resData  = body['data'] as Map<String, dynamic>;
      final identity = resData['identity'] as Map<String, dynamic>;
      final roles    = List<String>.from(identity['roles'] as List);

      final accessToken = resData['accessToken'] as String;
      await _saveTokens(
        accessToken:  accessToken,
        refreshToken: resData['refreshToken'] as String,
        identityId:   identity['id'] as String,
        email:        identity['email'] as String,
      );
      final vendorId = await fetchAndSaveVendorId(accessToken);

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        identityId: identity['id'] as String,
        vendorId:   vendorId,
        email:      identity['email'] as String,
        roles:      roles,
        profileCompleted: identity['profileCompleted'] as bool? ?? true,
      ));
    } catch (e) {
      state = AsyncValue.error(_friendlyError(e), StackTrace.current);
    }
  }

  // ── Sign In ────────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final res = await _dio.post(
        ApiConfig.kSignIn,
        data: {'email': email, 'password': password},
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        throw _mapErrorCode(
          (res.data as Map<String, dynamic>?)?['errorCode'] as String? ?? 'UNKNOWN_ERROR',
        );
      }

      final body     = res.data as Map<String, dynamic>;
      final data     = body['data'] as Map<String, dynamic>;
      final identity = data['identity'] as Map<String, dynamic>;
      final roles    = List<String>.from(identity['roles'] as List);

      if (!roles.contains('vendor_owner')) throw 'NOT_A_VENDOR';

      final accessToken = data['accessToken'] as String;
      await _saveTokens(
        accessToken:  accessToken,
        refreshToken: data['refreshToken'] as String,
        identityId:   identity['id'] as String,
        email:        identity['email'] as String,
      );
      final vendorId = await fetchAndSaveVendorId(accessToken);

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        identityId: identity['id'] as String,
        vendorId:   vendorId,
        email:      identity['email'] as String,
        roles:      roles,
        profileCompleted: identity['profileCompleted'] as bool? ?? true,
      ));
    } catch (e) {
      state = AsyncValue.error(_friendlyError(e), StackTrace.current);
    }
  }

  // ── Fetch and persist vendor ID ────────────────────────────────────────────

  Future<String?> fetchAndSaveVendorId(String token) async {
    try {
      final res = await _dio.get(
        ApiConfig.kVendorMe,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      if (res.statusCode != 200) return null;
      final id = (res.data['data'] as Map<String, dynamic>?)?['id'] as String?;
      if (id != null) await _storage.write(key: _kVendorId, value: id);
      return id;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getVendorId() => _storage.read(key: _kVendorId);

  // ── Sign Out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    final token = await _storage.read(key: _kAccessToken);
    if (token != null) {
      try {
        await _dio.post(
          ApiConfig.kSignOut,
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
      } catch (_) {
        // Best-effort — clear local storage regardless
      }
    }
    await _storage.deleteAll();
    state = const AsyncValue.data(AuthState());
  }

  // ── Token Refresh ──────────────────────────────────────────────────────────

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _kRefreshToken);
    if (refreshToken == null) return null;

    try {
      final res = await _dio.post(
        ApiConfig.kRefresh,
        data: {'refreshToken': refreshToken},
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        await signOut();
        return null;
      }

      final data       = res.data['data'] as Map<String, dynamic>;
      final newAccess  = data['accessToken']  as String;
      final newRefresh = data['refreshToken'] as String;
      await _storage.write(key: _kAccessToken,  value: newAccess);
      await _storage.write(key: _kRefreshToken, value: newRefresh);
      return newAccess;
    } catch (_) {
      await signOut();
      return null;
    }
  }

  // ── Get Token ─────────────────────────────────────────────────────────────

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String identityId,
    required String email,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken,  value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
      _storage.write(key: _kIdentityId,   value: identityId),
      _storage.write(key: _kEmail,        value: email),
    ]);
  }

  String _mapErrorCode(String code) => switch (code) {
    'AUTH_EMAIL_ALREADY_EXISTS' => 'An account with this email already exists.',
    'AUTH_INVALID_CREDENTIALS'  => 'Incorrect email or password.',
    'IDENTITY_BANNED'           => 'Your account has been suspended. Contact support.',
    'IDENTITY_INACTIVE'         => 'Your account is inactive. Contact support.',
    'AUTH_SIGNUP_FAILED'        => 'Signup failed. Please try again.',
    _                           => 'Something went wrong. Please try again.',
  };

  // Unwrap DioException to a user-readable string; keep other errors as-is.
  dynamic _friendlyError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timed out. Check your internet and try again.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'No internet connection.';
      }
    }
    return e;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.valueOrNull?.isLoggedIn ?? false;
});
