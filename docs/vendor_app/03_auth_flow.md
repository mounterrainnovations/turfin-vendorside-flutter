# 03 — Auth Flow

The vendor app uses the **same NestJS backend JWT auth** as the consumer app.
The only difference is that the sign-in request must come from an account with the
`vendor_owner` role. The backend validates role automatically.

---

## How Auth Works

```
VendorLoginScreen
  → POST /auth/signin { email, password }
  ← { accessToken, refreshToken, identity: { id, email, roles, profileCompleted } }

Tokens stored in flutter_secure_storage:
  vendor_access_token
  vendor_refresh_token
  vendor_identity_id
  vendor_email

AppRouter watches authProvider → routes to VendorHomeScreen
```

If the signed-in account does NOT have `vendor_owner` in `identity.roles`, display:
> "This account is not registered as a vendor. Please use the TurfIn customer app."

---

## STEP 15 — auth_notifier.dart

```dart
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
    // Restore session from storage
    final token      = await _storage.read(key: _kAccessToken);
    final identityId = await _storage.read(key: _kIdentityId);
    final email      = await _storage.read(key: _kEmail);

    if (token == null || identityId == null) return const AuthState();

    // Optionally: validate token is not expired by decoding JWT payload
    // For now we trust storage — the router will catch 401s when needed
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

      final data = jsonDecode(response.body)['data'] as Map<String, dynamic>;
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
```

---

## STEP 16 — app_router.dart

```dart
// lib/core/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_notifier.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/vendor_login_screen.dart';
import '../../features/home/presentation/pages/vendor_home_screen.dart';

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      loading: () => const SplashScreen(),
      error:   (_, __) => const VendorLoginScreen(),
      data: (auth) {
        if (!auth.isLoggedIn) return const VendorLoginScreen();
        return const VendorHomeScreen();
      },
    );
  }
}
```

---

## STEP 17 — splash_screen.dart

The splash screen shows the TurfIn logo while the `authNotifierProvider` resolves.
`AppRouter` handles routing automatically once the async state settles.

```dart
// lib/features/splash/presentation/pages/splash_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo mark — neon green circle with "T" initial
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: const Text(
                'T',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // App name
            const Text(
              'TurfIn',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            // Vendor badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white20),
              ),
              child: const Text(
                'VENDOR',
                style: TextStyle(
                  color: AppColors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 18 — vendor_login_screen.dart

Full login screen for vendors.

```dart
// lib/features/auth/presentation/pages/vendor_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/auth_notifier.dart';

class VendorLoginScreen extends ConsumerStatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  ConsumerState<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends ConsumerState<VendorLoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() => _errorMessage = null);

    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    await ref.read(authNotifierProvider.notifier).signIn(email, password);

    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      final err = authState.error.toString();
      setState(() => _errorMessage = err == 'NOT_A_VENDOR'
          ? 'This account is not a vendor account. Use the TurfIn customer app.'
          : err);
    }
    // On success, AppRouter rebuilds and navigates automatically
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authNotifierProvider).isLoading;

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: AppColors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 64),

                // ── Logo ───────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'T',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TurfIn',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.white10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VENDOR PORTAL',
                            style: TextStyle(
                              color: AppColors.white60,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // ── Heading ────────────────────────────────────────────
                Text(
                  'Welcome back.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your turfs and bookings.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white60,
                  ),
                ),

                const SizedBox(height: 40),

                // ── Error box ──────────────────────────────────────────
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0x1AEF4444),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Email ──────────────────────────────────────────────
                const Text('Email', style: TextStyle(color: AppColors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'vendor@turfin.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                // ── Password ───────────────────────────────────────────
                const Text('Password', style: TextStyle(color: AppColors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Enter your password',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.white50,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Sign In button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signIn,
                    child: const Text('SIGN IN'),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Footer note ────────────────────────────────────────
                Center(
                  child: Text(
                    'This portal is for registered turf vendors only.\nContact support to register your turf.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white30,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Auth API Contract

### POST /auth/signin

**Request:**
```json
{
  "email": "vendor@example.com",
  "password": "password123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "identity": {
      "id": "uuid",
      "email": "vendor@example.com",
      "roles": ["vendor_owner"],
      "profileCompleted": true
    }
  }
}
```

**Error Response (401):**
```json
{
  "errorCode": "AUTH_INVALID_CREDENTIALS",
  "message": "Invalid email or password"
}
```

**Forbidden (vendor_owner role missing):**
The backend returns `roles: ["end_user"]`. The Flutter app detects this client-side
and shows the "not a vendor" error.

---

## Checkpoint 3 ✓

At the end of this step:
- `AuthNotifier` correctly signs in, stores tokens, handles errors
- `AppRouter` watches auth state and routes automatically
- `SplashScreen` shows while auth resolves
- `VendorLoginScreen` shows correct error for non-vendor accounts
- On successful sign-in, app navigates to `VendorHomeScreen` automatically

**Next: [04_screens_step_by_step.md](./04_screens_step_by_step.md)**
