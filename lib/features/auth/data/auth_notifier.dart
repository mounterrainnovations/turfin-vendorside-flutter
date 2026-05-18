// lib/features/auth/data/auth_notifier.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

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
  final String? whatsapp;    // optional (max 20)
  final String? gstNumber;   // optional (max 50)

  // Page 3 — Address
  final String addressType;   // always 'work' for vendor
  final String? houseNumber;  // optional – flat/shop/house number
  final String? floor;        // optional – floor / level
  final String? towerBlock;   // optional – tower, wing, or block name
  final String? landmark;     // optional – nearby landmark
  final String city;
  final String state;
  final String pinCode;
  final String country;       // always 'India'
  final double? latitude;     // from map picker
  final double? longitude;    // from map picker

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
      final response = await http.post(
        Uri.parse(ApiConfig.signUp),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorCode = body['errorCode'] as String? ?? 'UNKNOWN_ERROR';
        throw _mapErrorCode(errorCode);
      }

      final responseData = body['data'] as Map<String, dynamic>;
      final identity     = responseData['identity'] as Map<String, dynamic>;
      final roles        = List<String>.from(identity['roles'] as List);

      final accessToken = responseData['accessToken'] as String;
      await _storage.write(key: _kAccessToken,  value: accessToken);
      await _storage.write(key: _kRefreshToken, value: responseData['refreshToken'] as String);
      await _storage.write(key: _kIdentityId,   value: identity['id']               as String);
      await _storage.write(key: _kEmail,        value: identity['email']            as String);

      final vendorId = await _fetchAndSaveVendorId(accessToken);

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        identityId: identity['id']    as String,
        vendorId:   vendorId,
        email:      identity['email'] as String,
        roles:      roles,
        profileCompleted: identity['profileCompleted'] as bool? ?? true,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // ── Sign In ────────────────────────────────────────────────────────────────

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signIn),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorCode = body['errorCode'] as String? ?? 'UNKNOWN_ERROR';
        throw _mapErrorCode(errorCode);
      }

      final data     = body['data'] as Map<String, dynamic>;
      final identity = data['identity'] as Map<String, dynamic>;
      final roles    = List<String>.from(identity['roles'] as List);

      if (!roles.contains('vendor_owner')) {
        throw 'NOT_A_VENDOR';
      }

      final accessToken = data['accessToken'] as String;
      await _storage.write(key: _kAccessToken,  value: accessToken);
      await _storage.write(key: _kRefreshToken, value: data['refreshToken'] as String);
      await _storage.write(key: _kIdentityId,   value: identity['id']       as String);
      await _storage.write(key: _kEmail,        value: identity['email']    as String);

      final vendorId = await _fetchAndSaveVendorId(accessToken);

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        identityId: identity['id']    as String,
        vendorId:   vendorId,
        email:      identity['email'] as String,
        roles:      roles,
        profileCompleted: identity['profileCompleted'] as bool? ?? true,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // ── Fetch and persist vendor ID ───────────────────────────────────────────

  Future<String?> _fetchAndSaveVendorId(String token) async {
    try {
      final res = await http.get(
        Uri.parse(ApiConfig.vendorMe),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode != 200) return null;

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      final id   = data?['id'] as String?;
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
        await http.post(
          Uri.parse(ApiConfig.signOut),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      } catch (_) {
        // Best-effort signout — clear local storage regardless
      }
    }

    await _storage.deleteAll(); // clears all keys including _kVendorId
    state = const AsyncValue.data(AuthState());
  }

  // ── Token Refresh ──────────────────────────────────────────────────────────

  Future<String?> refreshAccessToken() async {
    final refreshToken = await _storage.read(key: _kRefreshToken);
    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.refresh),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        await signOut();
        return null;
      }

      final data       = jsonDecode(response.body)['data'] as Map<String, dynamic>;
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

  // ── Get Token (for API calls) ──────────────────────────────────────────────

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  // ── Error mapper ──────────────────────────────────────────────────────────

  String _mapErrorCode(String code) => switch (code) {
    'AUTH_EMAIL_ALREADY_EXISTS' => 'An account with this email already exists.',
    'AUTH_INVALID_CREDENTIALS'  => 'Incorrect email or password.',
    'IDENTITY_BANNED'           => 'Your account has been suspended. Contact support.',
    'IDENTITY_INACTIVE'         => 'Your account is inactive. Contact support.',
    'AUTH_SIGNUP_FAILED'        => 'Signup failed. Please try again.',
    _                           => 'Something went wrong. Please try again.',
  };
}

// ── Providers ─────────────────────────────────────────────────────────────

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.valueOrNull?.isLoggedIn ?? false;
});
