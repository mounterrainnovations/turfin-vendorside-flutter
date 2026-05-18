// lib/core/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/data/auth_notifier.dart';
import '../../features/auth/presentation/pages/vendor_login_screen.dart';
import '../../features/auth/presentation/pages/vendor_welcome_screen.dart';
import '../../features/auth/presentation/pages/vendor_signup_screen.dart';
import '../../features/auth/presentation/pages/vendor_otp_screen.dart';
import '../../features/auth/presentation/pages/account_created_screen.dart';
import '../../features/home/presentation/pages/vendor_home_screen.dart';
import '../../features/onboarding/presentation/pages/arena_onboarding_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_under_review_screen.dart';
import '../../features/onboarding/data/onboarding_status_notifier.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

// 'welcome' | 'login' | 'signup' | 'otp' | 'account_created'
final authModeProvider = StateProvider<String>((ref) => 'welcome');

// Kept for the post-signup UX flow (AccountCreatedScreen / VendorOtpScreen).
final mockLoggedInProvider = StateProvider<bool>((ref) => false);

// true once the 2-second splash delay completes.
final splashDoneProvider = StateProvider<bool>((ref) => false);

// Holds the phone number entered during signup, shown on the OTP screen.
final pendingPhoneProvider = StateProvider<String>((ref) => '');

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashDone   = ref.watch(splashDoneProvider);
    final authAsync    = ref.watch(authNotifierProvider);
    final mockLoggedIn = ref.watch(mockLoggedInProvider);
    final authMode     = ref.watch(authModeProvider);

    // Splash covers the initial FlutterSecureStorage auth check.
    // Auth loading during sign-in/sign-up is handled by each screen's own overlay —
    // the router must NOT re-show splash during those operations or it disposes
    // the active form and resets it to page 0.
    if (!splashDone) {
      return SplashScreen(
        onComplete: () => ref.read(splashDoneProvider.notifier).state = true,
      );
    }

    // During the post-signup OTP / account-created UX flow, authMode is 'otp'
    // or 'account_created'. Keep showing those screens even though the token is
    // already stored, so the vendor goes through the full confirmation steps.
    final inPostSignupFlow = authMode == 'otp' || authMode == 'account_created';

    // loggedIn = real stored auth (handles app restart) OR mock flag (new signup
    // flow completing), but suppressed while the post-signup UX is still active.
    final realLoggedIn = authAsync.valueOrNull?.isLoggedIn ?? false;
    final loggedIn     = (realLoggedIn || mockLoggedIn) && !inPostSignupFlow;

    if (!loggedIn) {
      return switch (authMode) {
        'login'           => const VendorLoginScreen(),
        'signup'          => const VendorSignupScreen(),
        'otp'             => const VendorOtpScreen(),
        'account_created' => const AccountCreatedScreen(),
        _                 => const VendorWelcomeScreen(),
      };
    }

    // Logged in — check vendor status and onboarding completeness via backend.
    final statusAsync = ref.watch(onboardingStatusProvider);

    return statusAsync.when(
      loading: () => const _LoadingScreen(),
      error: (_, __) => const VendorLoginScreen(),
      data: (status) => switch (status) {
        OnboardingStatus.vendorBanned => const _VendorBlockedScreen(
          title: 'Account Banned',
          message: 'Your account has been permanently banned. Please contact support.',
        ),
        OnboardingStatus.vendorSuspended => const _VendorBlockedScreen(
          title: 'Account Suspended',
          message: 'Your account has been suspended. Please contact support to resolve this.',
        ),
        OnboardingStatus.pendingArena    => const ArenaOnboardingScreen(),
        OnboardingStatus.pendingApproval => const OnboardingUnderReviewScreen(),
        OnboardingStatus.complete        => const VendorHomeScreen(),
      },
    );
  }
}

// ── Loading screen ────────────────────────────────────────────────────────────

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Blocked account screen (banned / suspended) ───────────────────────────────

class _VendorBlockedScreen extends ConsumerWidget {
  final String title;
  final String message;
  const _VendorBlockedScreen({required this.title, required this.message});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.block_rounded, size: 64, color: Color(0xFFEF4444)),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: TextStyle(
                    color: tc.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: tc.onSurface60, height: 1.5),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signOut(),
                    child: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
