// lib/features/auth/presentation/pages/account_created_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';

class AccountCreatedScreen extends ConsumerWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x1ACCFF00),
                  border: Border.all(color: const Color(0x33CCFF00), width: 2),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 52,
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Account Created!',
                style: TextStyle(
                  color: tc.onSurface,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              Text(
                'Your vendor account is ready.\nComplete onboarding to list your turf and start accepting bookings.',
                style: TextStyle(
                  color: tc.onSurface60,
                  fontSize: 15,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Clear 'account_created' so inPostSignupFlow becomes false,
                    // allowing loggedIn to evaluate to true and route to onboarding.
                    ref.read(authModeProvider.notifier).state = 'welcome';
                    ref.read(mockLoggedInProvider.notifier).state = true;
                  },
                  child: const Text(
                    'CONTINUE TO ONBOARDING',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
