// ===== File: lib/data/repositories/import_repository.dart =====

import 'dart:io';
import '../../data/datasources/remote/excel_import_api.dart';
import '../../data/mappers/import_mapper.dart';
import '../../domain/entities/student.dart';

// ── Abstract contract (defined in domain layer)
abstract class ImportRepository {
  /// رفع workbook → ينتهي لما تكتمل المعالجة → يرجع قائمة الطلاب
  Stream<ImportUploadEvent> uploadWorkbook(File file, String department);

  /// جلب بيانات طالب واحد كاملة → Domain Entity
  Future<Student> getStudentDetail(String jobId, String studentId);

  /// جلب مجموعة طلاب دفعة واحدة
  Future<List<Student>> getStudentsBatch(String jobId, List<String> studentIds);

  /// جلب index لكل الطلاب (الأسماء و IDs بس، بدون تفاصيل)
  Future<List<StudentSummary>> getResultIndex(String jobId);
}

// ── Events بيبعثهم الـ Stream
sealed class ImportUploadEvent {}

class ImportUploading extends ImportUploadEvent {}

class ImportProcessing extends ImportUploadEvent {
  final String jobId;
  ImportProcessing(this.jobId);
}

class ImportCompleted extends ImportUploadEvent {
  final String jobId;
  final int totalStudents;
  final int failed;
  final bool hasWarnings;
  ImportCompleted({
    required this.jobId,
    required this.totalStudents,
    required this.failed,
    required this.hasWarnings,
  });
}

class ImportFailed extends ImportUploadEvent {
  final String message;
  ImportFailed(this.message);
}

// ── Simple DTO for the index list
class StudentSummary {
  final String studentId;
  final String name;
  final String sheetName;
  const StudentSummary({
    required this.studentId,
    required this.name,
    required this.sheetName,
  });
}

// ── Concrete implementation
class ImportRepositoryImpl implements ImportRepository {
  final ExcelImportApi _api;
  final ImportMapper _mapper;

  static const Duration _pollInterval = Duration(seconds: 2);
  static const Duration _timeout = Duration(minutes: 10);

  ImportRepositoryImpl({
    required ExcelImportApi api,
    ImportMapper? mapper,
  })  : _api = api,
        _mapper = mapper ?? const ImportMapper();

  @override
  Stream<ImportUploadEvent> uploadWorkbook(
      File file, String department) async* {
    // 1. Upload
    yield ImportUploading();
    late UploadResponseDto uploaded;
    try {
      uploaded = await _api.uploadExcel(file, department);
    } on ImportApiException catch (e) {
      yield ImportFailed(e.message);
      return;
    }

    final jobId = uploaded.jobId;
    yield ImportProcessing(jobId);

    // 2. Poll
    final deadline = DateTime.now().add(_timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(_pollInterval);

      late JobStatusDto status;
      try {
        status = await _api.getJobStatus(jobId);
      } on ImportApiException {
        continue; // network blip — retry
      }

      if (status.isCompleted) {
        yield ImportCompleted(
          jobId: jobId,
          totalStudents: status.stats['total_students'] as int? ?? 0,
          failed: status.stats['failed'] as int? ?? 0,
          hasWarnings: status.isPartialSuccess,
        );
        return;
      }

      if (status.isFailed) {
        yield ImportFailed(
          status.errorLog.isNotEmpty
              ? status.errorLog.join('\n')
              : 'فشلت المعالجة',
        );
        return;
      }
    }

    yield ImportFailed('انتهت مهلة الانتظار');
  }

  @override
  Future<List<StudentSummary>> getResultIndex(String jobId) async {
    final dto = await _api.getResultIndex(jobId);
    return dto.students
        .map((s) => StudentSummary(
              studentId: s.studentId,
              name: s.name,
              sheetName: s.sheetName,
            ))
        .toList();
  }

  @override
  Future<Student> getStudentDetail(String jobId, String studentId) async {
    final raw = await _api.getStudentDetail(jobId, studentId);
    return _mapper.fromRaw(raw);
  }

  @override
  Future<List<Student>> getStudentsBatch(
      String jobId, List<String> studentIds) async {
    final rawMap = await _api.getStudentsBatch(jobId, studentIds);
    return rawMap.values.map(_mapper.fromRaw).toList();
  }
}
