// lib/core/routing/app_router.dart
// UI-only mode: skips backend auth, goes straight to HomeScreen after splash.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/vendor_login_screen.dart';
import '../../features/home/presentation/pages/vendor_home_screen.dart';

// Simple bool provider — true once the user taps "Sign In" on the login screen.
final mockLoggedInProvider = StateProvider<bool>((ref) => false);

class AppRouter extends ConsumerWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(mockLoggedInProvider);

    // Show splash briefly on first load, then login, then home.
    if (!loggedIn) {
      return const VendorLoginScreen();
    }
    return const VendorHomeScreen();
  }
}
