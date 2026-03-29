// lib/features/auth/presentation/pages/vendor_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/routing/app_router.dart';

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

  void _signIn() {
    setState(() => _errorMessage = null);

    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    ref.read(mockLoggedInProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);

    return Scaffold(
        backgroundColor: tc.scaffoldBg,
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
                          color: Color(0xFF000000),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TurfIn',
                          style: TextStyle(
                            color: tc.onSurface,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: tc.onSurface10,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VENDOR PORTAL',
                            style: TextStyle(
                              color: tc.onSurface60,
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
                    color: tc.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to manage your turfs and bookings.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tc.onSurface60,
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
                      border: Border.all(color: const Color(0x66EF4444)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Email ──────────────────────────────────────────────
                Text('Email', style: TextStyle(color: tc.onSurface70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'vendor@turfin.com',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 14),

                // ── Password ───────────────────────────────────────────
                Text('Password', style: TextStyle(color: tc.onSurface70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Enter your password',
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: tc.onSurface50,
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
                    onPressed: _signIn,
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
                      color: tc.onSurface30,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
    );
  }
}
