// lib/features/auth/presentation/pages/vendor_welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';

class VendorWelcomeScreen extends ConsumerWidget {
  const VendorWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: Stack(
        children: [

          // ── Decorative background numbers (editorial / sporty feel) ──
          Positioned(
            right: -24,
            top: 100,
            child: Text(
              '24/7',
              style: TextStyle(
                fontSize: 160,
                fontWeight: FontWeight.w900,
                color: tc.onSurface10,
                height: 1,
                letterSpacing: -8,
              ),
            ),
          ),
          Positioned(
            left: -16,
            bottom: 220,
            child: Text(
              '100%',
              style: TextStyle(
                fontSize: 110,
                fontWeight: FontWeight.w900,
                color: tc.onSurface10,
                height: 1,
                letterSpacing: -6,
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 1),

                // ── Logo ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/TurfinLogo.png',
                        width: 52,
                        height: 52,
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Turfin Ops',
                            style: TextStyle(
                              color: tc.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: tc.onSurface10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'VENDOR PORTAL',
                              style: TextStyle(
                                color: tc.onSurface60,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // ── Hero tagline ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage your\nturf. Own the\ngame.',
                        style: TextStyle(
                          color: tc.onSurface,
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Bookings, slots, payments and\ncheck-ins — all in one place.',
                        style: TextStyle(
                          color: tc.onSurface60,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 3),

                // ── CTAs ───────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    children: [

                      // Create Account — primary neon
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            ref.read(mockSkipOnboardingProvider.notifier).state = false;
                            ref.read(mockLoggedInProvider.notifier).state = true;
                          },
                          child: const Text(
                            'CREATE ACCOUNT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sign In — secondary outline
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () =>
                              ref.read(authModeProvider.notifier).state = 'login',
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: tc.onSurface50, width: 1.5),
                            foregroundColor: tc.onSurface,
                            backgroundColor: tc.onSurface10,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'SIGN IN',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Terms note ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: tc.onSurface30,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
