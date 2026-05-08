// lib/features/onboarding/presentation/steps/step1_business_info.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/onboarding_notifier.dart';
import '../widgets/onboarding_widgets.dart';

const _businessTypes = [
  'Proprietorship',
  'Partnership',
  'Private Limited',
  'Limited Liability Partnership (LLP)',
  'Other',
];

const _businessServices = [
  'Turf / Sports Ground',
  'Cricket Academy',
  'Football Club',
  'Swimming Pool',
  'Multi-sport Complex',
  'Badminton Court',
  'Other',
];

class Step1BusinessInfo extends ConsumerStatefulWidget {
  const Step1BusinessInfo({super.key});

  @override
  ConsumerState<Step1BusinessInfo> createState() => _Step1State();
}

class _Step1State extends ConsumerState<Step1BusinessInfo> {
  late final TextEditingController _businessNameCtrl;
  late final TextEditingController _ownerNameCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(vendorOnboardingProvider);
    _businessNameCtrl = TextEditingController(text: s.businessName);
    _ownerNameCtrl    = TextEditingController(text: s.ownerName);
  }

  @override
  void dispose() {
    _businessNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s        = ref.watch(vendorOnboardingProvider);
    final notifier = ref.read(vendorOnboardingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Business Name ───────────────────────────────────────────
          const OnbFieldLabel('Business Name'),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'e.g. Ace Sports Arena',
            controller: _businessNameCtrl,
            onChanged: notifier.setBusinessName,
          ),

          const SizedBox(height: 22),

          // ── Business Type ───────────────────────────────────────────
          const OnbFieldLabel('Business Type'),
          const SizedBox(height: 8),
          OnbDropdownTile(
            value: s.businessType.isEmpty ? null : s.businessType,
            placeholder: 'Select business structure',
            onTap: () async {
              final result = await showOnbOptionPicker(
                context,
                title: 'Business Type',
                options: _businessTypes,
                selected: s.businessType.isEmpty ? null : s.businessType,
              );
              if (result != null) notifier.setBusinessType(result);
            },
          ),

          const SizedBox(height: 22),

          // ── Business Service ────────────────────────────────────────
          const OnbFieldLabel('Primary Service'),
          const SizedBox(height: 8),
          OnbDropdownTile(
            value: s.businessService.isEmpty ? null : s.businessService,
            placeholder: 'Select what you offer',
            onTap: () async {
              final result = await showOnbOptionPicker(
                context,
                title: 'Primary Service',
                options: _businessServices,
                selected: s.businessService.isEmpty ? null : s.businessService,
              );
              if (result != null) notifier.setBusinessService(result);
            },
          ),

          const SizedBox(height: 22),

          // ── Owner Name ──────────────────────────────────────────────
          const OnbFieldLabel('Owner / Proprietor Name'),
          const SizedBox(height: 8),
          CustomTextField(
            hint: 'e.g. Rajesh Kumar',
            controller: _ownerNameCtrl,
            onChanged: notifier.setOwnerName,
          ),

        ],
      ),
    );
  }
}
