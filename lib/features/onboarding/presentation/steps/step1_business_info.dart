// lib/features/onboarding/presentation/steps/step1_business_info.dart
// Step 2 of 5 — Personal Details

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/onboarding_notifier.dart';
import '../widgets/onboarding_widgets.dart';

class Step1PersonalDetails extends ConsumerStatefulWidget {
  const Step1PersonalDetails({super.key});

  @override
  ConsumerState<Step1PersonalDetails> createState() => _Step1State();
}

class _Step1State extends ConsumerState<Step1PersonalDetails> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(vendorOnboardingProvider);
    _nameCtrl  = TextEditingController(text: s.fullName);
    _emailCtrl = TextEditingController(text: s.email);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(vendorOnboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Full Name ───────────────────────────────────────────────
          const OnbFieldLabel('Full Name'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. Rajesh Kumar',
            controller: _nameCtrl,
            onChanged: notifier.setFullName,
          ),

          const SizedBox(height: 20),

          // ── Email Address (optional) ────────────────────────────────
          const OnbFieldLabel('Email Address', optional: true),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. rajesh@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.setEmail,
          ),

        ],
      ),
    );
  }
}
