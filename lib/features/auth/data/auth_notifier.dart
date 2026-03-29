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

// ── AuthState ──────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoggedIn;
  final String? identityId;
  final String? email;
  final List<String> roles;
  final bool profileCompleted;

  const AuthState({
    this.isLoggedIn = false,
    this.identityId,
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

    if (token == null || identityId == null) return const AuthState();

    return AuthState(
      isLoggedIn: true,
      identityId: identityId,
      email: email,
      roles: const ['vendor_owner'],
      profileCompleted: true,
    );
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

      await _storage.write(key: _kAccessToken,  value: data['accessToken']  as String);
      await _storage.write(key: _kRefreshToken, value: data['refreshToken'] as String);
      await _storage.write(key: _kIdentityId,   value: identity['id']       as String);
      await _storage.write(key: _kEmail,        value: identity['email']    as String);

      state = AsyncValue.data(AuthState(
        isLoggedIn: true,
        identityId: identity['id'] as String,
        email: identity['email'] as String,
        roles: roles,
        profileCompleted: identity['profileCompleted'] as bool? ?? true,
      ));
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

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

    await _storage.deleteAll();
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
    'AUTH_INVALID_CREDENTIALS' => 'Incorrect email or password.',
    'IDENTITY_BANNED'          => 'Your account has been suspended. Contact support.',
    'IDENTITY_INACTIVE'        => 'Your account is inactive. Contact support.',
    'AUTH_SIGNUP_FAILED'       => 'Sign-in failed. Please try again.',
    _                          => 'Something went wrong. Please try again.',
  };
}

// ── Providers ─────────────────────────────────────────────────────────────

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final isLoggedInProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.valueOrNull?.isLoggedIn ?? false;
});
