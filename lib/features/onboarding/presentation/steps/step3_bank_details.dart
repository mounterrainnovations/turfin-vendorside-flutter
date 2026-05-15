// lib/features/onboarding/presentation/steps/step3_bank_details.dart
// Step 4 of 5 — KYC Verification

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/onboarding_notifier.dart';
import '../widgets/onboarding_widgets.dart';

class Step3KycVerification extends ConsumerWidget {
  const Step3KycVerification({super.key});

  Future<String?> _pickImage(BuildContext context) async {
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
              title: Text('Choose from Gallery', style: TextStyle(color: tc.onSurface)),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final s        = ref.watch(vendorOnboardingProvider);
    final notifier = ref.read(vendorOnboardingProvider.notifier);
    final tc       = AppThemeColors.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Upload clear photos of your documents. Blurry or cropped images will delay your review.',
            style: TextStyle(
              color: tc.onSurface60,
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 24),

          // ── Section A — Identity Verification ──────────────────────
          const OnbSectionHeader(
            section: 'SECTION A',
            title: 'Identity Verification',
          ),

          _DocUploadTile(
            label: 'Aadhaar Card',
            description: 'Front side of your Aadhaar card',
            isRequired: true,
            filePath: s.aadhaarPath,
            onTap: () async {
              final path = await _pickImage(context);
              if (path != null) notifier.setAadhaar(path);
            },
            tc: tc,
          ),

          const SizedBox(height: 16),

          _DocUploadTile(
            label: 'PAN Card',
            description: 'Your income tax PAN card',
            isRequired: true,
            filePath: s.panPath,
            onTap: () async {
              final path = await _pickImage(context);
              if (path != null) notifier.setPan(path);
            },
            tc: tc,
          ),

          const OnbSectionDivider(),

          // ── Section B — Business Verification (Optional) ────────────
          const OnbSectionHeader(
            section: 'SECTION B',
            title: 'Business Verification',
          ),

          // GST note
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: tc.onSurface10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    color: tc.onSurface30, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'GST is optional and required only for GST invoices, business verification, or enterprise / vendor upgrades.',
                    style: TextStyle(
                      color: tc.onSurface50,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const OnbFieldLabel('GST Number', optional: true),
          const SizedBox(height: 6),
          _GstField(notifier: notifier, initialValue: s.gstNumber, tc: tc),

          const SizedBox(height: 16),

          _DocUploadTile(
            label: 'GST Certificate',
            description: 'Upload your GST registration certificate',
            isRequired: false,
            filePath: s.gstCertPath,
            onTap: () async {
              final path = await _pickImage(context);
              if (path != null) notifier.setGstCert(path);
            },
            tc: tc,
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: tc.onSurface10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: tc.onSurface30, size: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Accepted: JPG, PNG. Max 5 MB per document.',
                    style: TextStyle(
                      color: tc.onSurface50,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

// ── GST Number field ──────────────────────────────────────────────────────────

class _GstField extends StatefulWidget {
  final VendorOnboardingNotifier notifier;
  final String initialValue;
  final AppThemeColors tc;

  const _GstField({
    required this.notifier,
    required this.initialValue,
    required this.tc,
  });

  @override
  State<_GstField> createState() => _GstFieldState();
}

class _GstFieldState extends State<_GstField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hint: 'e.g. 27AABCU9603R1ZN',
      controller: _ctrl,
      onChanged: widget.notifier.setGstNumber,
    );
  }
}

// ── Document upload tile ──────────────────────────────────────────────────────

class _DocUploadTile extends StatelessWidget {
  final String label;
  final String description;
  final bool isRequired;
  final String? filePath;
  final VoidCallback onTap;
  final AppThemeColors tc;

  const _DocUploadTile({
    required this.label,
    required this.description,
    required this.isRequired,
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
            ? _UploadedState(filePath: filePath!, label: label, tc: tc)
            : _EmptyState(
                label: label,
                description: description,
                isRequired: isRequired,
                tc: tc,
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String label;
  final String description;
  final bool isRequired;
  final AppThemeColors tc;

  const _EmptyState({
    required this.label,
    required this.description,
    required this.isRequired,
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.cloud_upload_outlined,
              color: tc.onSurface30, size: 28),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: TextStyle(
                    color: tc.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
            if (!isRequired) ...[
              const SizedBox(width: 6),
              Text('optional',
                  style: TextStyle(
                      color: tc.onSurface30,
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ],
        ),
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
            borderRadius: BorderRadius.circular(30),
          ),
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

class _UploadedState extends StatelessWidget {
  final String filePath;
  final String label;
  final AppThemeColors tc;

  const _UploadedState({
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.primary, size: 18),
        ),
      ],
    );
  }
}
