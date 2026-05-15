// lib/features/onboarding/presentation/steps/step4_kyc_documents.dart
// Step 5 of 5 — Bank & Payout Details

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/onboarding_notifier.dart';
import '../widgets/onboarding_widgets.dart';

class Step4BankDetails extends ConsumerStatefulWidget {
  const Step4BankDetails({super.key});

  @override
  ConsumerState<Step4BankDetails> createState() => _Step4State();
}

class _Step4State extends ConsumerState<Step4BankDetails> {
  late final TextEditingController _holderCtrl;
  late final TextEditingController _bankNameCtrl;
  late final TextEditingController _accountCtrl;
  late final TextEditingController _confirmCtrl;
  late final TextEditingController _ifscCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(vendorOnboardingProvider);
    _holderCtrl  = TextEditingController(text: s.accountHolderName);
    _bankNameCtrl = TextEditingController(text: s.bankName);
    _accountCtrl = TextEditingController(text: s.accountNumber);
    _confirmCtrl = TextEditingController(text: s.confirmAccountNumber);
    _ifscCtrl    = TextEditingController(text: s.ifscCode);
  }

  @override
  void dispose() {
    _holderCtrl.dispose();
    _bankNameCtrl.dispose();
    _accountCtrl.dispose();
    _confirmCtrl.dispose();
    _ifscCtrl.dispose();
    super.dispose();
  }

  Future<String?> _pickDoc(BuildContext context) async {
    final tc = AppThemeColors.of(context);
    String? source;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: tc.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: tc.onSurface20,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: tc.onSurface),
              title: Text('Take Photo', style: TextStyle(color: tc.onSurface)),
              onTap: () { source = 'camera'; Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: tc.onSurface),
              title: Text('Choose from Gallery',
                  style: TextStyle(color: tc.onSurface)),
              onTap: () { source = 'gallery'; Navigator.pop(ctx); },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (source == null) return null;
    final file = await ImagePicker().pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    return file?.path;
  }

  @override
  Widget build(BuildContext context) {
    final s        = ref.watch(vendorOnboardingProvider);
    final notifier = ref.read(vendorOnboardingProvider.notifier);
    final tc       = AppThemeColors.of(context);

    final accountMismatch = s.accountNumber.isNotEmpty &&
        s.confirmAccountNumber.isNotEmpty &&
        s.accountNumber != s.confirmAccountNumber;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Security banner ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33CCFF00)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary, size: 18),
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
          ),

          const SizedBox(height: 28),

          // ── Account Holder Name ─────────────────────────────────────
          const OnbFieldLabel('Account Holder Name'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'As printed on passbook',
            controller: _holderCtrl,
            onChanged: notifier.setAccountHolderName,
          ),

          const SizedBox(height: 16),

          // ── Bank Name ───────────────────────────────────────────────
          const OnbFieldLabel('Bank Name'),
          const SizedBox(height: 6),
          CustomTextField(
            hint: 'e.g. State Bank of India',
            controller: _bankNameCtrl,
            onChanged: notifier.setBankName,
          ),

          const SizedBox(height: 16),

          // ── Account Number ──────────────────────────────────────────
          const OnbFieldLabel('Account Number'),
          const SizedBox(height: 6),
          _AccountNumberField(
            controller: _accountCtrl,
            onChanged: notifier.setAccountNumber,
            tc: tc,
          ),

          const SizedBox(height: 16),

          // ── Confirm Account Number ──────────────────────────────────
          const OnbFieldLabel('Confirm Account Number'),
          const SizedBox(height: 6),
          _AccountNumberField(
            controller: _confirmCtrl,
            onChanged: notifier.setConfirmAccountNumber,
            tc: tc,
            errorText: accountMismatch ? 'Account numbers do not match' : null,
          ),

          const SizedBox(height: 16),

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
                fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 20),

          // ── Cancelled Cheque / Passbook ─────────────────────────────
          const OnbFieldLabel('Cancelled Cheque / Passbook'),
          const SizedBox(height: 6),
          _DocUploadTile(
            label: 'Cancelled Cheque or Passbook',
            description: 'Upload a photo of cancelled cheque or passbook front page',
            filePath: s.cancelledChequePath,
            onTap: () async {
              final path = await _pickDoc(context);
              if (path != null) notifier.setCancelledCheque(path);
            },
            tc: tc,
          ),

        ],
      ),
    );
  }
}

// ── Account number field (obscured, toggle) ───────────────────────────────────

class _AccountNumberField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final AppThemeColors tc;
  final String? errorText;

  const _AccountNumberField({
    required this.controller,
    required this.onChanged,
    required this.tc,
    this.errorText,
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
        errorText: widget.errorText,
        suffixIcon: IconButton(
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: widget.tc.onSurface50,
            size: 20,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}

// ── IFSC field (auto-uppercase, 11 chars) ─────────────────────────────────────

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
          letterSpacing: 2),
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
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

// ── Document upload tile ──────────────────────────────────────────────────────

class _DocUploadTile extends StatelessWidget {
  final String label;
  final String description;
  final String? filePath;
  final VoidCallback onTap;
  final AppThemeColors tc;

  const _DocUploadTile({
    required this.label,
    required this.description,
    required this.filePath,
    required this.onTap,
    required this.tc,
  });

  bool get _hasFile => filePath != null && filePath!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hasFile ? AppColors.primarySubtle : tc.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hasFile ? AppColors.primary70 : tc.borderDefault,
            width: _hasFile ? 1.5 : 1.0,
          ),
        ),
        child: _hasFile
            ? _UploadedRow(filePath: filePath!, label: label, tc: tc)
            : _EmptyUpload(
                label: label, description: description, tc: tc),
      ),
    );
  }
}

class _EmptyUpload extends StatelessWidget {
  final String label;
  final String description;
  final AppThemeColors tc;

  const _EmptyUpload({
    required this.label,
    required this.description,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
              color: tc.onSurface10,
              borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.cloud_upload_outlined,
              color: tc.onSurface30, size: 28),
        ),
        const SizedBox(height: 14),
        Text(label,
            style: TextStyle(
                color: tc.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(description,
            style: TextStyle(
                color: tc.onSurface50,
                fontSize: 12,
                fontWeight: FontWeight.w400),
            textAlign: TextAlign.center),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
              color: tc.onSurface10,
              borderRadius: BorderRadius.circular(30)),
          child: Text('TAP TO UPLOAD',
              style: TextStyle(
                  color: tc.onSurface60,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0)),
        ),
      ],
    );
  }
}

class _UploadedRow extends StatelessWidget {
  final String filePath;
  final String label;
  final AppThemeColors tc;

  const _UploadedRow({
    required this.filePath,
    required this.label,
    required this.tc,
  });

  String get _fileName {
    final parts = filePath.split(Platform.pathSeparator);
    return parts.isEmpty ? 'document' : parts.last;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(File(filePath),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: tc.onSurface10,
                    child: Icon(Icons.insert_drive_file_outlined,
                        color: tc.onSurface30, size: 28),
                  )),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(_fileName,
                  style: TextStyle(
                      color: tc.onSurface60,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text('Tap to change',
                  style: TextStyle(
                      color: tc.onSurface50,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.check_rounded,
              color: AppColors.primary, size: 18),
        ),
      ],
    );
  }
}
