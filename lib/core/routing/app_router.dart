// lib/core/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/vendor_login_screen.dart';
import '../../features/auth/presentation/pages/vendor_welcome_screen.dart';
import '../../features/home/presentation/pages/vendor_home_screen.dart';
import '../../features/onboarding/data/onboarding_notifier.dart';
import '../../features/onboarding/presentation/pages/vendor_onboarding_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_under_review_screen.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';

// 'welcome' | 'login'  — controls which auth screen is shown.
final authModeProvider = StateProvider<String>((ref) => 'welcome');

// true once the user taps "Sign In" on the login screen.
final mockLoggedInProvider = StateProvider<bool>((ref) => false);

// true once the 2-second splash delay completes.
final splashDoneProvider = StateProvider<bool>((ref) => false);

// true when this vendor has already completed onboarding (existing vendor).
final mockSkipOnboardingProvider = StateProvider<bool>((ref) => false);

// true when admin has approved the vendor (mock — toggled by DEV button).
final onboardingApprovedProvider = StateProvider<bool>((ref) => false);

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splashDone     = ref.watch(splashDoneProvider);
    final loggedIn       = ref.watch(mockLoggedInProvider);
    final authMode       = ref.watch(authModeProvider);
    final skipOnboarding = ref.watch(mockSkipOnboardingProvider);
    final approved       = ref.watch(onboardingApprovedProvider);
    final onboarding     = ref.watch(vendorOnboardingProvider);

    if (!splashDone) {
      return SplashScreen(
        onComplete: () => ref.read(splashDoneProvider.notifier).state = true,
      );
    }

    if (!loggedIn) {
      if (authMode == 'login') return const VendorLoginScreen();
      return const VendorWelcomeScreen();
    }

    // Existing vendor — go straight to home.
    if (skipOnboarding || approved) return const VendorHomeScreen();

    // New vendor — onboarding flow.
    if (onboarding.submitted) return const OnboardingUnderReviewScreen();
    return const VendorOnboardingScreen();
  }
}
