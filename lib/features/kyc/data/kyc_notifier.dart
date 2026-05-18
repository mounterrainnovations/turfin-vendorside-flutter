// lib/features/kyc/data/kyc_notifier.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';
import '../../../features/auth/data/auth_notifier.dart';

// ── Constants ─────────────────────────────────────────────────────────────────

const _kMaxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

const _kAllowedMimeTypes = {
  'image/jpeg',
  'image/jpg',
  'image/png',
  'image/webp',
  'image/heic',
  'image/heif',
};

const _kExtToMime = {
  'jpg':  'image/jpeg',
  'jpeg': 'image/jpeg',
  'png':  'image/png',
  'webp': 'image/webp',
  'heic': 'image/heic',
  'heif': 'image/heif',
};

// ── KYC document field keys ───────────────────────────────────────────────────

enum KycField {
  aadhaarCardFront,
  aadhaarCardBack,
  panCard,
  passbookOrCancelledCheque,
}

extension KycFieldX on KycField {
  String get key => switch (this) {
    KycField.aadhaarCardFront          => 'aadhaarCardFront',
    KycField.aadhaarCardBack           => 'aadhaarCardBack',
    KycField.panCard                   => 'panCard',
    KycField.passbookOrCancelledCheque => 'passbookOrCancelledCheque',
  };

  String get label => switch (this) {
    KycField.aadhaarCardFront          => 'Aadhaar Card (Front)',
    KycField.aadhaarCardBack           => 'Aadhaar Card (Back)',
    KycField.panCard                   => 'PAN Card',
    KycField.passbookOrCancelledCheque => 'Passbook / Cancelled Cheque',
  };
}

// ── Upload status per field ───────────────────────────────────────────────────

enum FieldUploadStatus { idle, uploading, uploaded, verified, rejected }

class KycFieldState {
  final FieldUploadStatus status;
  final String? signedUrl;
  final String? error;

  const KycFieldState({
    this.status = FieldUploadStatus.idle,
    this.signedUrl,
    this.error,
  });

  KycFieldState copyWith({
    FieldUploadStatus? status,
    String? signedUrl,
    String? error,
  }) => KycFieldState(
    status:    status    ?? this.status,
    signedUrl: signedUrl ?? this.signedUrl,
    error:     error     ?? this.error,
  );
}

// ── Overall KYC state ─────────────────────────────────────────────────────────

class KycState {
  final String overallStatus;
  final Map<KycField, KycFieldState> fields;
  final bool isLoading;
  final String? globalError;

  const KycState({
    this.overallStatus = 'not_started',
    this.fields = const {},
    this.isLoading = false,
    this.globalError,
  });

  KycState copyWith({
    String? overallStatus,
    Map<KycField, KycFieldState>? fields,
    bool? isLoading,
    String? globalError,
  }) => KycState(
    overallStatus: overallStatus ?? this.overallStatus,
    fields:        fields        ?? this.fields,
    isLoading:     isLoading     ?? this.isLoading,
    globalError:   globalError   ?? this.globalError,
  );

  KycFieldState fieldState(KycField f) =>
      fields[f] ?? const KycFieldState();
}

// ── KYC Notifier ──────────────────────────────────────────────────────────────

class KycNotifier extends AsyncNotifier<KycState> {
  Dio get _dio => DioClient.dio;

  @override
  Future<KycState> build() async => _fetchStatus();

  // ── Fetch current KYC status ───────────────────────────────────────────────

  Future<KycState> _fetchStatus() async {
    final token = await _freshToken();
    if (token == null) return const KycState();

    try {
      final res = await _dio.get(
        ApiConfig.kKycMe,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      if (res.statusCode != 200) return const KycState();

      final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      if (data == null) return const KycState();

      final overallStatus = data['status'] as String? ?? 'not_started';
      final docs   = data['documents']    as Map<String, dynamic>? ?? {};
      final verify = data['verification'] as Map<String, dynamic>? ?? {};

      final fields = <KycField, KycFieldState>{};
      for (final field in KycField.values) {
        final url        = docs[field.key] as String?;
        final isVerified = verify[field.key] as bool? ?? false;
        final isRejected = (verify[field.key] == false) && (url?.isNotEmpty ?? false);

        final status = (url == null || url.isEmpty)
            ? FieldUploadStatus.idle
            : isVerified
                ? FieldUploadStatus.verified
                : isRejected
                    ? FieldUploadStatus.rejected
                    : FieldUploadStatus.uploaded;

        fields[field] = KycFieldState(
          status:    status,
          signedUrl: (url?.isEmpty ?? true) ? null : url,
        );
      }
      return KycState(overallStatus: overallStatus, fields: fields);
    } catch (_) {
      return const KycState();
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _fetchStatus());
  }

  // ── Upload a single document field ────────────────────────────────────────

  Future<String?> uploadField(KycField field, File file) async {
    final current = state.valueOrNull ?? const KycState();

    final ext  = file.path.split('.').last.toLowerCase();
    final mime = _kExtToMime[ext];

    if (mime == null || !_kAllowedMimeTypes.contains(mime)) {
      _setFieldError(field, 'Invalid file type. Use JPEG, PNG, WEBP, HEIC, or HEIF.');
      return null;
    }

    final size = await file.length();
    if (size > _kMaxFileSizeBytes) {
      final mb = (size / 1024 / 1024).toStringAsFixed(1);
      _setFieldError(field, 'File is ${mb}MB. Maximum allowed size is 10MB.');
      return null;
    }

    _setFieldStatus(field, FieldUploadStatus.uploading);

    try {
      final token = await _freshToken();
      if (token == null) throw Exception('Session expired. Please sign in again.');

      final authNotifier = ref.read(authNotifierProvider.notifier);
      String? vendorId = ref.read(authNotifierProvider).valueOrNull?.vendorId;
      vendorId ??= await authNotifier.getVendorId();
      vendorId ??= await authNotifier.fetchAndSaveVendorId(token);
      if (vendorId == null || vendorId.isEmpty) {
        throw Exception('Could not resolve vendor profile. Please sign out and sign in again.');
      }

      // Step 1 — get signed upload URL from our API (captured by Alice)
      final uploadUrlRes = await _dio.get(
        '${ApiConfig.kStorageUpload}?path=vendors/$vendorId/kyc/${field.key}&fileType=$mime',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (uploadUrlRes.statusCode != 200) {
        throw Exception(_parseApiError(uploadUrlRes.data, uploadUrlRes.statusCode,
            fallback: 'Could not get upload URL'));
      }
      final uploadData  = (uploadUrlRes.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?;
      final signedUrl   = uploadData?['uploadUrl'] as String?;
      final storagePath = uploadData?['path']      as String?;
      if (signedUrl == null || signedUrl.isEmpty)   throw Exception('Upload URL missing in response.');
      if (storagePath == null || storagePath.isEmpty) throw Exception('Storage path missing in response.');

      // Step 2 — PUT binary directly to Supabase signed URL.
      // Uses a standalone Dio so it does NOT inherit DioClient's baseUrl or
      // Content-Type:application/json default, and doesn't pollute Alice logs
      // with raw binary blobs.
      final fileBytes = await file.readAsBytes();
      final rawDio = Dio();
      final putRes = await rawDio.put<dynamic>(
        signedUrl,
        data: Stream.fromIterable(fileBytes.map((b) => [b])),
        options: Options(
          headers: {
            'Content-Type':   mime,
            'Content-Length': fileBytes.length,
          },
          sendTimeout:    const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );
      if (putRes.statusCode != 200 && putRes.statusCode != 201) {
        throw Exception('File upload failed (HTTP ${putRes.statusCode}).');
      }

      // Step 3 — register path with our KYC endpoint (captured by Alice)
      final submitRes = await _dio.patch(
        ApiConfig.kKycSubmit,
        data: {'documents': {field.key: storagePath}},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout:    const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (submitRes.statusCode != 200 && submitRes.statusCode != 201) {
        throw Exception(_parseApiError(submitRes.data, submitRes.statusCode,
            fallback: 'Document submission failed'));
      }

      // Step 4 — get signed view URL for preview (captured by Alice)
      final viewRes = await _dio.get(
        '${ApiConfig.kStorageView}?path=${Uri.encodeComponent(storagePath)}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          sendTimeout:    const Duration(seconds: 8),
          receiveTimeout: const Duration(seconds: 8),
        ),
      );
      String? viewUrl;
      if (viewRes.statusCode == 200) {
        viewUrl = ((viewRes.data as Map<String, dynamic>)['data']
            as Map<String, dynamic>?)?['signedUrl'] as String?;
      }

      final updatedFields = Map<KycField, KycFieldState>.from(current.fields);
      updatedFields[field] = KycFieldState(
        status:    FieldUploadStatus.uploaded,
        signedUrl: viewUrl,
      );
      state = AsyncValue.data(current.copyWith(fields: updatedFields));
      return storagePath;
    } catch (e) {
      _setFieldError(field, e.toString().replaceFirst('Exception: ', ''));
      return null;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _setFieldStatus(KycField field, FieldUploadStatus status) {
    final current = state.valueOrNull ?? const KycState();
    final updated = Map<KycField, KycFieldState>.from(current.fields);
    updated[field] = (updated[field] ?? const KycFieldState()).copyWith(status: status, error: null);
    state = AsyncValue.data(current.copyWith(fields: updated));
  }

  void _setFieldError(KycField field, String error) {
    final current = state.valueOrNull ?? const KycState();
    final updated = Map<KycField, KycFieldState>.from(current.fields);
    updated[field] = (updated[field] ?? const KycFieldState())
        .copyWith(status: FieldUploadStatus.idle, error: error);
    state = AsyncValue.data(current.copyWith(fields: updated));
  }

  String _parseApiError(dynamic data, int? status, {required String fallback}) {
    try {
      final error   = (data as Map<String, dynamic>)['error'] as Map<String, dynamic>?;
      if (error == null) return '$fallback (HTTP $status)';
      final details = error['details'] as Map<String, dynamic>?;
      final errors  = details?['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.map((e) => e.toString()).join(', ');
      }
      final msg = error['message'] as String?;
      if (msg != null && msg.isNotEmpty) return msg;
    } catch (_) {}
    return '$fallback (HTTP $status)';
  }

  Future<String?> _freshToken() async {
    final notifier = ref.read(authNotifierProvider.notifier);
    return await notifier.refreshAccessToken() ?? await notifier.getAccessToken();
  }
}

final kycProvider = AsyncNotifierProvider<KycNotifier, KycState>(KycNotifier.new);
