// ===== File: lib/core/services/import/upload_queue_service.dart =====

import 'dart:async';
import 'dart:io';
import '../../../data/datasources/remote/excel_import_api.dart';

enum UploadPhase { idle, uploading, processing, done, failed }

class UploadProgress {
  final UploadPhase phase;
  final String? jobId;
  final String message;
  final int? totalStudents;
  final int? successfulStudents;
  final int? failedStudents;
  final String? errorMessage;

  const UploadProgress({
    required this.phase,
    this.jobId,
    required this.message,
    this.totalStudents,
    this.successfulStudents,
    this.failedStudents,
    this.errorMessage,
  });
}

/// يرفع الملف ويعمل polling تلقائياً حتى تكتمل المعالجة.
/// استخدمه في Riverpod/BLoC provider.
class UploadQueueService {
  final ExcelImportApi _api;

  // Polling config
  static const Duration _pollInterval = Duration(seconds: 2);
  static const Duration _maxWait = Duration(minutes: 10);

  UploadQueueService({required ExcelImportApi api}) : _api = api;

  /// الـ Stream بيبعث UploadProgress كل خطوة.
  /// استخدم await for أو StreamBuilder في الـ UI.
  Stream<UploadProgress> uploadAndProcess(File file, String department) async* {
    // ── Phase 1: Uploading
    yield const UploadProgress(
      phase: UploadPhase.uploading,
      message: 'جاري رفع الملف...',
    );

    late UploadResponseDto uploadResponse;
    try {
      uploadResponse = await _api.uploadExcel(file, department);
    } on ImportApiException catch (e) {
      yield UploadProgress(
        phase: UploadPhase.failed,
        message: 'فشل رفع الملف',
        errorMessage: e.message,
      );
      return;
    }

    final jobId = uploadResponse.jobId;

    // ── Phase 2: Polling
    yield UploadProgress(
      phase: UploadPhase.processing,
      jobId: jobId,
      message: 'جاري معالجة الملف...',
    );

    final deadline = DateTime.now().add(_maxWait);

    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_pollInterval);

      late JobStatusDto status;
      try {
        status = await _api.getJobStatus(jobId);
      } on ImportApiException catch (e) {
        // Network hiccup — don't fail yet, keep trying
        yield UploadProgress(
          phase: UploadPhase.processing,
          jobId: jobId,
          message: 'جاري الاتصال... (${e.message})',
        );
        continue;
      }

      if (status.isCompleted) {
        // ── Phase 3: Done
        yield UploadProgress(
          phase: UploadPhase.done,
          jobId: jobId,
          message: status.isPartialSuccess
              ? 'اكتملت المعالجة مع بعض التحذيرات'
              : 'اكتملت المعالجة بنجاح',
          totalStudents: status.stats['total_students'] as int?,
          successfulStudents: status.stats['successful'] as int?,
          failedStudents: status.stats['failed'] as int?,
        );
        return;
      }

      if (status.isFailed) {
        yield UploadProgress(
          phase: UploadPhase.failed,
          jobId: jobId,
          message: 'فشلت المعالجة',
          errorMessage: status.errorLog.isNotEmpty
              ? status.errorLog.join('\n')
              : 'خطأ غير معروف',
        );
        return;
      }

      // Still pending/processing — keep polling
      yield UploadProgress(
        phase: UploadPhase.processing,
        jobId: jobId,
        message: 'جاري معالجة الملف... (${status.status})',
      );
    }

    // Timeout
    yield UploadProgress(
      phase: UploadPhase.failed,
      jobId: jobId,
      message: 'انتهت مهلة الانتظار',
      errorMessage: 'استغرقت المعالجة وقتاً أطول من المتوقع. حاول مرة أخرى.',
    );
  }
}
