// lib/features/onboarding/presentation/steps/step2_contact_info.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/onboarding_notifier.dart';
import '../widgets/onboarding_widgets.dart';

const _indianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya',
  'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim',
  'Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand',
  'West Bengal', 'Delhi', 'Jammu & Kashmir', 'Ladakh', 'Puducherry',
  'Chandigarh', 'Andaman & Nicobar Islands', 'Lakshadweep',
  'Dadra & Nagar Haveli and Daman & Diu',
];

class Step2ContactInfo extends ConsumerStatefulWidget {
  const Step2ContactInfo({super.key});

  @override
  ConsumerState<Step2ContactInfo> createState() => _Step2State();
}

class _Step2State extends ConsumerState<Step2ContactInfo> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _whatsappCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _gstCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _pincodeCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(vendorOnboardingProvider);
    _phoneCtrl    = TextEditingController(text: s.phone);
    _whatsappCtrl = TextEditingController(text: s.whatsapp);
    _emailCtrl    = TextEditingController(text: s.email);
    _gstCtrl      = TextEditingController(text: s.gstNumber);
    _addressCtrl  = TextEditingController(text: s.addressLine);
    _cityCtrl     = TextEditingController(text: s.city);
    _pincodeCtrl  = TextEditingController(text: s.pincode);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _whatsappCtrl.dispose();
    _emailCtrl.dispose();
    _gstCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s        = ref.watch(vendorOnboardingProvider);
    final notifier = ref.read(vendorOnboardingProvider.notifier);
    final tc       = AppThemeColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Phone ───────────────────────────────────────────────────
          const OnbFieldLabel('Phone Number'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: '+91 98765 43210',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            onChanged: notifier.setPhone,
          ),

          const SizedBox(height: 12),

          // ── WhatsApp ────────────────────────────────────────────────
          const OnbFieldLabel('WhatsApp Number', optional: true),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'Same as phone if identical',
            controller: _whatsappCtrl,
            keyboardType: TextInputType.phone,
            onChanged: notifier.setWhatsapp,
            suffixIcon: _phoneCtrl.text.isNotEmpty
                ? _SameAsPhoneButton(
                    onTap: () {
                      _whatsappCtrl.text = _phoneCtrl.text;
                      notifier.setWhatsapp(_phoneCtrl.text);
                    },
                    tc: tc,
                  )
                : null,
          ),

          const SizedBox(height: 12),

          // ── Email ───────────────────────────────────────────────────
          const OnbFieldLabel('Email Address'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'business@example.com',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.setEmail,
          ),

          const SizedBox(height: 12),

          // ── GST ─────────────────────────────────────────────────────
          const OnbFieldLabel('GST Number', optional: true),
          const SizedBox(height: 6),
          CustomTextField(
            hint: '27AABCU9603R1ZN',
            controller: _gstCtrl,
            onChanged: notifier.setGst,
          ),

          const OnbSectionDivider(),

          // ── Address section header ──────────────────────────────────
          Text(
            'PERSONAL ADDRESS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: tc.sectionLabel,
            ),
          ),
          const SizedBox(height: 16),

          // ── Address line ────────────────────────────────────────────
          const OnbFieldLabel('Address'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'House/Flat no., Street, Area',
            controller: _addressCtrl,
            maxLines: 3,
            onChanged: notifier.setAddressLine,
          ),

          const SizedBox(height: 12),

          // ── City + Pincode row ──────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('City'),
                    const SizedBox(height: 6),
                    CustomTextField(
                      hint: 'Mumbai',
                      controller: _cityCtrl,
                      onChanged: notifier.setCity,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OnbFieldLabel('PIN Code'),
                    const SizedBox(height: 6),
                    _PincodeField(
                      controller: _pincodeCtrl,
                      onChanged: notifier.setPincode,
                      tc: tc,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── State ───────────────────────────────────────────────────
          const OnbFieldLabel('State'),
          const SizedBox(height: 6),
          OnbDropdownTile(
            value: s.addressState.isEmpty ? null : s.addressState,
            placeholder: 'Select state',
            onTap: () async {
              final result = await showOnbOptionPicker(
                context,
                title: 'State',
                options: _indianStates,
                selected: s.addressState.isEmpty ? null : s.addressState,
              );
              if (result != null) notifier.setAddressState(result);
            },
          ),

        ],
      ),
    );
  }
}

// ── "Same as phone" button inside WhatsApp field suffix ───────────────────────

class _SameAsPhoneButton extends StatelessWidget {
  final VoidCallback onTap;
  final AppThemeColors tc;
  const _SameAsPhoneButton({required this.onTap, required this.tc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Padding(
        padding: EdgeInsets.only(right: 12),
        child: Text(
          'Same',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── PIN code field (numeric, max 6 digits) ────────────────────────────────────

class _PincodeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppThemeColors tc;

  const _PincodeField({
    required this.controller,
    required this.onChanged,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      style: TextStyle(
        color: tc.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: const InputDecoration(
        hintText: '400001',
        counterText: '',
      ),
    );
  }
}
