// lib/features/onboarding/presentation/pages/vendor_onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/section_label.dart';
import '../../data/onboarding_notifier.dart';
import '../steps/step1_business_info.dart';
import '../steps/step2_contact_info.dart';
import '../steps/step3_bank_details.dart';
import '../steps/step4_kyc_documents.dart';

// Step metadata: (title, subtitle) — displayed as steps 1–4 of 4.
const _steps = [
  ('Personal Details',  'Your basic information'),
  ('Arena Setup',       'Tell us about your arena'),
  ('KYC Verification',  'Verify your identity'),
  ('Bank & Payout',     'Where should we send payments?'),
];

class VendorOnboardingScreen extends ConsumerStatefulWidget {
  const VendorOnboardingScreen({super.key});

  @override
  ConsumerState<VendorOnboardingScreen> createState() =>
      _VendorOnboardingScreenState();
}

class _VendorOnboardingScreenState
    extends ConsumerState<VendorOnboardingScreen> {
  final _pageController = PageController();
  bool _loading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _isStepValid(int step, VendorOnboardingState s) {
    switch (step) {
      case 0: // Personal Details
        return s.fullName.isNotEmpty && s.email.isNotEmpty;

      case 1: // Arena Setup — required fields across all sections
        return s.arenaName.isNotEmpty &&
            s.arenaDescription.isNotEmpty &&
            s.sportsAvailable.isNotEmpty &&
            s.fullAddress.isNotEmpty &&
            s.city.isNotEmpty &&
            s.arenaState.isNotEmpty &&
            s.pincode.isNotEmpty &&
            s.coverPhotoPath != null &&
            s.openingTime.isNotEmpty &&
            s.closingTime.isNotEmpty &&
            s.availableDays.isNotEmpty &&
            s.weekdayPrice.isNotEmpty &&
            s.weekendPrice.isNotEmpty &&
            s.slotDuration.isNotEmpty;

      case 2: // KYC — Aadhaar + PAN required
        return s.aadhaarPath != null && s.panPath != null;

      case 3: // Bank Details — all required fields + account numbers must match
        return s.accountHolderName.isNotEmpty &&
            s.bankName.isNotEmpty &&
            s.accountNumber.isNotEmpty &&
            s.confirmAccountNumber.isNotEmpty &&
            s.accountNumber == s.confirmAccountNumber &&
            s.ifscCode.isNotEmpty &&
            s.cancelledChequePath != null;

      default:
        return false;
    }
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _onContinue() {
    final s = ref.read(vendorOnboardingProvider);

    if (!_isStepValid(s.step, s)) {
      _showError(s.step, s);
      return;
    }

    if (s.step == 3) {
      _submit();
      return;
    }

    ref.read(vendorOnboardingProvider.notifier).nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onBack() {
    final step = ref.read(vendorOnboardingProvider).step;
    if (step == 0) return;
    ref.read(vendorOnboardingProvider.notifier).prevStep();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submit() async {
    setState(() => _loading = true);
    // TODO: call API — POST /vendors/onboard
    await Future.delayed(const Duration(seconds: 1));
    ref.read(vendorOnboardingProvider.notifier).submit();
    setState(() => _loading = false);
  }

  void _showError(int step, VendorOnboardingState s) {
    final String message;
    switch (step) {
      case 0:
        message = s.fullName.isEmpty
            ? 'Please enter your full name.'
            : 'Please enter your email address.';
      case 1:
        if (s.arenaName.isEmpty) {
          message = 'Please enter your arena name.';
        } else if (s.sportsAvailable.isEmpty) {
          message = 'Please select at least one sport.';
        } else if (s.fullAddress.isEmpty ||
            s.city.isEmpty ||
            s.arenaState.isEmpty ||
            s.pincode.isEmpty) {
          message = 'Please fill in all location details.';
        } else if (s.coverPhotoPath == null) {
          message = 'Please upload a cover photo of your arena.';
        } else if (s.openingTime.isEmpty || s.closingTime.isEmpty) {
          message = 'Please set opening and closing times.';
        } else if (s.availableDays.isEmpty) {
          message = 'Please select at least one available day.';
        } else if (s.weekdayPrice.isEmpty || s.weekendPrice.isEmpty) {
          message = 'Please enter weekday and weekend prices.';
        } else {
          message = 'Please fill in all required arena details.';
        }
      case 2:
        message = 'Please upload your Aadhaar and PAN card.';
      case 3:
        if (s.accountNumber != s.confirmAccountNumber) {
          message = 'Account numbers do not match.';
        } else if (s.cancelledChequePath == null) {
          message = 'Please upload your cancelled cheque or passbook.';
        } else {
          message = 'Please fill in all bank details.';
        }
      default:
        message = 'Please complete all required fields.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final s  = ref.watch(vendorOnboardingProvider);
    final tc = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ────────────────────────────────────────────────
            _buildHeader(context, tc, s),

            // ── Step pages ────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  Step1PersonalDetails(),
                  Step2ArenaSetup(),
                  Step3KycVerification(),
                  Step4BankDetails(),
                ],
              ),
            ),

            // ── Bottom CTA ────────────────────────────────────────────
            _buildBottomCta(context, tc, s),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppThemeColors tc,
    VendorOnboardingState s,
  ) {
    final isFirst = s.step == 0;
    final displayStep = s.step + 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Back + progress row ───────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: isFirst ? null : _onBack,
                child: AnimatedOpacity(
                  opacity: isFirst ? 0.3 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tc.onSurface10,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: tc.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StepProgressBar(
                  filledCount: displayStep,
                  total: 4,
                  tc: tc,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '$displayStep / 4',
                style: TextStyle(
                  color: tc.onSurface50,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Step label + title ────────────────────────────────────
          SectionLabel('step $displayStep of 4'),
          const SizedBox(height: 6),
          Text(
            _steps[s.step].$1,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: tc.onSurface,
                  letterSpacing: -0.3,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            _steps[s.step].$2,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: tc.onSurface60,
                ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomCta(
    BuildContext context,
    AppThemeColors tc,
    VendorOnboardingState s,
  ) {
    final isLast = s.step == 3;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: tc.scaffoldBg,
        border: Border(top: BorderSide(color: tc.borderSubtle)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _loading ? null : _onContinue,
          child: _loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.black,
                  ),
                )
              : Text(
                  isLast ? 'SUBMIT FOR REVIEW' : 'SAVE & CONTINUE',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Step progress bar (5 animated pill segments) ──────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int filledCount; // how many segments to fill (displayStep)
  final int total;
  final AppThemeColors tc;

  const _StepProgressBar({
    required this.filledCount,
    required this.total,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) return const SizedBox(width: 6);
        final segIndex = i ~/ 2;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            height: 4,
            decoration: BoxDecoration(
              color: segIndex < filledCount
                  ? AppColors.primary
                  : tc.onSurface10,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
