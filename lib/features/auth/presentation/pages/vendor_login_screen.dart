// lib/features/auth/presentation/pages/vendor_login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/routing/app_router.dart';
import '../../data/auth_notifier.dart';

class VendorLoginScreen extends ConsumerStatefulWidget {
  const VendorLoginScreen({super.key});

  @override
  ConsumerState<VendorLoginScreen> createState() => _VendorLoginScreenState();
}

class _VendorLoginScreenState extends ConsumerState<VendorLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email and password.');
      return;
    }

    setState(() { _errorMessage = null; _isLoading = true; });

    await ref.read(authNotifierProvider.notifier).signIn(email, password);

    if (!mounted) return;

    ref.read(authNotifierProvider).whenOrNull(
      error: (e, _) => setState(() {
        _isLoading = false;
        _errorMessage = _mapError(e.toString());
      }),
      data: (_) => setState(() => _isLoading = false),
    );
  }

  String _mapError(String e) {
    if (e == 'NOT_A_VENDOR') return 'This app is for registered vendors only.';
    return e;
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
              const SizedBox(height: 20),

              // ── Back to welcome ────────────────────────────────────
              GestureDetector(
                onTap: () => ref.read(authModeProvider.notifier).state = 'welcome',
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tc.onSurface10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: tc.onSurface, size: 20),
                ),
              ),

              const SizedBox(height: 40),

              // ── Logo ───────────────────────────────────────────────
              Row(
                children: [
                  Image.asset(
                    'assets/TurfinLogo.png',
                    width: 48,
                    height: 48,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Turfin Ops',
                        style: TextStyle(
                          color: tc.onSurface,
                          fontSize: 20,
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
                          'Vendor App',
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
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Email ──────────────────────────────────────────────
              Text('Email',
                  style: TextStyle(
                      color: tc.onSurface70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              CustomTextField(
                hint: 'vendor@turfin.com',
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              // ── Password ───────────────────────────────────────────
              Text('Password',
                  style: TextStyle(
                      color: tc.onSurface70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
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
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 32),

              // ── Sign In button ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('SIGN IN'),
                ),
              ),

              const SizedBox(height: 20),

              // ── Divider ────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                      child: Divider(color: tc.borderDefault, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(color: tc.onSurface30, fontSize: 12),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: tc.borderDefault, thickness: 1)),
                ],
              ),

              const SizedBox(height: 20),

              // ── Google ─────────────────────────────────────────────
              _SocialButton(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Google sign-in coming soon')),
                ),
                icon: FaIcon(FontAwesomeIcons.google, size: 18, color: AppThemeColors.of(context).onSurface),
                label: 'Continue with Google',
              ),

              const SizedBox(height: 12),

              // ── Apple ──────────────────────────────────────────────
              _SocialButton(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Apple sign-in coming soon')),
                ),
                icon: FaIcon(FontAwesomeIcons.apple, size: 18, color: AppThemeColors.of(context).onSurface),
                label: 'Continue with Apple',
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

// ── Social sign-in button ─────────────────────────────────────────────────────

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget icon;
  final String label;
  const _SocialButton({required this.onTap, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final tc     = AppThemeColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: tc.borderDefault),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: tc.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

