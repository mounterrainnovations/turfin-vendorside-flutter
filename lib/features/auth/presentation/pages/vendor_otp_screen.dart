// lib/features/auth/presentation/pages/vendor_otp_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';

class VendorOtpScreen extends ConsumerStatefulWidget {
  const VendorOtpScreen({super.key});

  @override
  ConsumerState<VendorOtpScreen> createState() => _VendorOtpScreenState();
}

class _VendorOtpScreenState extends ConsumerState<VendorOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitEntered(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _verify() {
    ref.read(authModeProvider.notifier).state = 'account_created';
  }

  @override
  Widget build(BuildContext context) {
    final tc = AppThemeColors.of(context);
    final phone = ref.watch(pendingPhoneProvider);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Back
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

              Text(
                'Verify your number',
                style: TextStyle(
                  color: tc.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                phone.isNotEmpty
                    ? 'Enter the 6-digit code sent to $phone'
                    : 'Enter the 6-digit verification code.',
                style: TextStyle(color: tc.onSurface60, fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 8),

              // Mock badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x1ACCFF00),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0x33CCFF00)),
                ),
                child: const Text(
                  'MOCK — OTP not sent, tap VERIFY to continue',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 46,
                    height: 56,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (v) => _onDigitEntered(i, v),
                      style: TextStyle(
                        color: tc.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: tc.borderDefault, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: tc.onSurface10,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Resend
              Center(
                child: TextButton(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('OTP resend — Mock (not integrated yet)'),
                      backgroundColor: tc.surface,
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  child: Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: tc.onSurface60,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: tc.onSurface30,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Verify button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _verify,
                  child: const Text(
                    'VERIFY',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
