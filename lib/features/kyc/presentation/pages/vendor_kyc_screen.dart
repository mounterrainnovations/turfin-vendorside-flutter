// lib/features/kyc/presentation/pages/vendor_kyc_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/kyc_notifier.dart';

class VendorKycScreen extends ConsumerWidget {
  const VendorKycScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc       = AppThemeColors.of(context);
    final kycAsync = ref.watch(kycProvider);

    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      appBar: AppBar(
        backgroundColor: tc.scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: tc.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'KYC Documents',
          style: TextStyle(
            color: tc.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: tc.onSurface60),
            onPressed: () => ref.read(kycProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: kycAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(
          child: Text('Failed to load KYC status',
              style: TextStyle(color: AppColors.error)),
        ),
        data: (kyc) => _KycBody(kyc: kyc),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _KycBody extends ConsumerWidget {
  final KycState kyc;
  const _KycBody({required this.kyc});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        // ── Status banner ──────────────────────────────────────────────────
        _StatusBanner(status: kyc.overallStatus, tc: tc),
        const SizedBox(height: 20),

        Text(
          'REQUIRED DOCUMENTS',
          style: TextStyle(
            color: tc.sectionLabel,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 12),

        // ── Document cards ─────────────────────────────────────────────────
        for (final field in KycField.values) ...[
          _DocumentCard(field: field, fieldState: kyc.fieldState(field)),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 8),
        Text(
          'Accepted formats: JPEG, PNG, WEBP, HEIC, HEIF\nMax file size: 10 MB per document',
          style: TextStyle(
            color: tc.onSurface30,
            fontSize: 12,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Status banner ─────────────────────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  final String status;
  final AppThemeColors tc;
  const _StatusBanner({required this.status, required this.tc});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color border, Color dot, String label) = switch (status) {
      'verified'   => (const Color(0x1A22C55E), const Color(0x3322C55E), const Color(0xFF22C55E), 'Verified'),
      'in_review'  => (const Color(0x1A3B82F6), const Color(0x333B82F6), const Color(0xFF3B82F6), 'In Review'),
      'rejected'   => (const Color(0x1AEF4444), const Color(0x33EF4444), const Color(0xFFEF4444), 'Rejected — Please re-upload flagged documents'),
      'pending'    => (const Color(0x1AFBBF24), const Color(0x33FBBF24), const Color(0xFFFBBF24), 'Submitted — Awaiting Review'),
      _            => (tc.surface,               tc.borderDefault,         tc.onSurface30,          'Not started'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: tc.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Document card ─────────────────────────────────────────────────────────────

class _DocumentCard extends ConsumerWidget {
  final KycField field;
  final KycFieldState fieldState;
  const _DocumentCard({required this.field, required this.fieldState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tc = AppThemeColors.of(context);
    final isUploading = fieldState.status == FieldUploadStatus.uploading;

    return Container(
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor(tc)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    field.label,
                    style: TextStyle(
                      color: tc.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusChip(status: fieldState.status),
              ],
            ),
          ),

          // ── Error message ────────────────────────────────────────────────
          if (fieldState.error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: AppColors.error, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fieldState.error!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Preview (if uploaded) ─────────────────────────────────────────
          if (fieldState.signedUrl != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  fieldState.signedUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: tc.onSurface10,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(Icons.insert_drive_file_outlined,
                          color: tc.onSurface30, size: 28),
                    ),
                  ),
                ),
              ),
            ),

          // ── Upload button ────────────────────────────────────────────────
          if (fieldState.status != FieldUploadStatus.verified)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () => _pickAndUpload(context, ref, field),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isUploading ? tc.onSurface20 : tc.borderDefault,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: isUploading
                      ? SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: tc.onSurface60,
                          ),
                        )
                      : Icon(
                          fieldState.status == FieldUploadStatus.idle
                              ? Icons.upload_rounded
                              : Icons.refresh_rounded,
                          size: 18,
                          color: tc.onSurface,
                        ),
                  label: Text(
                    isUploading
                        ? 'Uploading…'
                        : fieldState.status == FieldUploadStatus.idle
                            ? 'Upload Document'
                            : 'Replace',
                    style: TextStyle(
                      color: isUploading ? tc.onSurface30 : tc.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 14),
        ],
      ),
    );
  }

  Color _borderColor(AppThemeColors tc) => switch (fieldState.status) {
    FieldUploadStatus.verified => const Color(0x3322C55E),
    FieldUploadStatus.rejected => const Color(0x33EF4444),
    FieldUploadStatus.uploaded => const Color(0x333B82F6),
    _                          => tc.borderDefault,
  };

  Future<void> _pickAndUpload(
    BuildContext context,
    WidgetRef ref,
    KycField field,
  ) async {
    final picker = ImagePicker();
    final source = await _chooseSource(context);
    if (source == null) return;

    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked == null) return;

    await ref.read(kycProvider.notifier).uploadField(field, File(picked.path));
  }

  Future<ImageSource?> _chooseSource(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final tc = AppThemeColors.of(ctx);
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          decoration: BoxDecoration(
            color: tc.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: tc.onSurface20,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded, color: tc.onSurface),
                title: Text('Take Photo',
                    style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w500)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded, color: tc.onSurface),
                title: Text('Choose from Gallery',
                    style: TextStyle(color: tc.onSurface, fontWeight: FontWeight.w500)),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final FieldUploadStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color text, String label) = switch (status) {
      FieldUploadStatus.verified  => (const Color(0x1A22C55E), const Color(0xFF22C55E), 'Verified'),
      FieldUploadStatus.rejected  => (const Color(0x1AEF4444), const Color(0xFFEF4444), 'Rejected'),
      FieldUploadStatus.uploaded  => (const Color(0x1A3B82F6), const Color(0xFF3B82F6), 'Uploaded'),
      FieldUploadStatus.uploading => (const Color(0x1AFBBF24), const Color(0xFFFBBF24), 'Uploading'),
      FieldUploadStatus.idle      => (const Color(0x1A94A3B8), const Color(0xFF94A3B8), 'Not uploaded'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
