// lib/features/onboarding/presentation/steps/step3_bank_details.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/onboarding_notifier.dart';
import '../widgets/onboarding_widgets.dart';

class Step3BankDetails extends ConsumerStatefulWidget {
  const Step3BankDetails({super.key});

  @override
  ConsumerState<Step3BankDetails> createState() => _Step3State();
}

class _Step3State extends ConsumerState<Step3BankDetails> {
  late final TextEditingController _holderCtrl;
  late final TextEditingController _accountCtrl;
  late final TextEditingController _ifscCtrl;
  late final TextEditingController _branchCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(vendorOnboardingProvider);
    _holderCtrl  = TextEditingController(text: s.accountHolder);
    _accountCtrl = TextEditingController(text: s.accountNumber);
    _ifscCtrl    = TextEditingController(text: s.ifscCode);
    _branchCtrl  = TextEditingController(text: s.branchName);
  }

  @override
  void dispose() {
    _holderCtrl.dispose();
    _accountCtrl.dispose();
    _ifscCtrl.dispose();
    _branchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(vendorOnboardingProvider.notifier);
    final tc       = AppThemeColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Info banner ─────────────────────────────────────────────
          _InfoBanner(tc: tc),

          const SizedBox(height: 24),

          // ── Account Holder Name ─────────────────────────────────────
          const OnbFieldLabel('Account Holder Name'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'As printed on passbook',
            controller: _holderCtrl,
            onChanged: notifier.setAccountHolder,
          ),

          const SizedBox(height: 12),

          // ── Account Number ──────────────────────────────────────────
          const OnbFieldLabel('Account Number'),
          const SizedBox(height: 6),
          _AccountNumberField(
            controller: _accountCtrl,
            onChanged: notifier.setAccountNumber,
            tc: tc,
          ),

          const SizedBox(height: 12),

          // ── IFSC Code ───────────────────────────────────────────────
          const OnbFieldLabel('IFSC Code'),
          const SizedBox(height: 6),
          _IfscField(
            controller: _ifscCtrl,
            onChanged: notifier.setIfsc,
            tc: tc,
          ),
          const SizedBox(height: 4),
          Text(
            'e.g. SBIN0001234 — 4 letters, 0, then 6 digits',
            style: TextStyle(
              color: tc.onSurface30,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // ── Branch Name ─────────────────────────────────────────────
          const OnbFieldLabel('Branch Name'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Andheri West, Mumbai',
            controller: _branchCtrl,
            onChanged: notifier.setBranchName,
          ),

        ],
      ),
    );
  }
}

// ── Security info banner ──────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final AppThemeColors tc;
  const _InfoBanner({required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x33CCFF00)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your banking details are encrypted and used only for payout processing.',
              style: TextStyle(
                color: tc.onSurface70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account number field (numeric, obfuscated display option) ─────────────────

class _AccountNumberField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppThemeColors tc;

  const _AccountNumberField({
    required this.controller,
    required this.onChanged,
    required this.tc,
  });

  @override
  State<_AccountNumberField> createState() => _AccountNumberFieldState();
}

class _AccountNumberFieldState extends State<_AccountNumberField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: TextInputType.number,
      obscureText: _obscure,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: widget.onChanged,
      style: TextStyle(
        color: widget.tc.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: _obscure ? 4 : 1,
      ),
      decoration: InputDecoration(
        hintText: '••••••••••••',
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: widget.tc.onSurface50,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

// ── IFSC field (auto-uppercase, alphanumeric) ─────────────────────────────────

class _IfscField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppThemeColors tc;

  const _IfscField({
    required this.controller,
    required this.onChanged,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      maxLength: 11,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        _UpperCaseFormatter(),
      ],
      onChanged: onChanged,
      style: TextStyle(
        color: tc.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
      decoration: const InputDecoration(
        hintText: 'SBIN0001234',
        counterText: '',
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
