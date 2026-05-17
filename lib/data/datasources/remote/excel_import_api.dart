// ===== File: lib/data/datasources/remote/excel_import_api.dart =====

import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';

// ── DTOs (بيعكسوا JSON الباكاند بالظبط)

class UploadResponseDto {
  final String jobId;
  final String status;
  final String message;

  const UploadResponseDto({
    required this.jobId,
    required this.status,
    required this.message,
  });

  factory UploadResponseDto.fromJson(Map<String, dynamic> json) =>
      UploadResponseDto(
        jobId: json['job_id'] as String,
        status: json['status'] as String,
        message: json['message'] as String? ?? '',
      );
}

class JobStatusDto {
  final String jobId;
  final String status;
  final String? filename;
  final String? department;
  final Map<String, dynamic> stats;
  final List<String> errorLog;

  const JobStatusDto({
    required this.jobId,
    required this.status,
    this.filename,
    this.department,
    this.stats = const {},
    this.errorLog = const [],
  });

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed' || status == 'partial_success';
  bool get isFailed => status == 'failed';
  bool get isPartialSuccess => status == 'partial_success';

  factory JobStatusDto.fromJson(Map<String, dynamic> json) => JobStatusDto(
        jobId: json['job_id'] as String,
        status: json['status'] as String,
        filename: json['filename'] as String?,
        department: json['department'] as String?,
        stats: (json['stats'] as Map<String, dynamic>?) ?? {},
        errorLog:
            (json['error_log'] as List?)?.map((e) => e.toString()).toList() ??
                [],
      );
}

class StudentSummaryDto {
  final String studentId;
  final String name;
  final String sheetName;

  const StudentSummaryDto({
    required this.studentId,
    required this.name,
    required this.sheetName,
  });

  factory StudentSummaryDto.fromJson(Map<String, dynamic> json) =>
      StudentSummaryDto(
        studentId: json['student_id'] as String,
        name: json['name'] as String? ?? '',
        sheetName: json['sheet_name'] as String? ?? '',
      );
}

class ResultIndexDto {
  final String jobId;
  final String status;
  final String? department;
  final int totalStudents;
  final List<StudentSummaryDto> students;
  final List<Map<String, dynamic>> errors;

  const ResultIndexDto({
    required this.jobId,
    required this.status,
    this.department,
    required this.totalStudents,
    required this.students,
    required this.errors,
  });

  factory ResultIndexDto.fromJson(Map<String, dynamic> json) => ResultIndexDto(
        jobId: json['job_id'] as String,
        status: json['status'] as String,
        department: json['department'] as String?,
        totalStudents: json['total_students'] as int? ?? 0,
        students: (json['students'] as List? ?? [])
            .map((e) => StudentSummaryDto.fromJson(e as Map<String, dynamic>))
            .toList(),
        errors: (json['errors'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );
}

// ── Raw student detail — الـ domain mapper هيحوله لـ Entity
typedef StudentDetailRaw = Map<String, dynamic>;

// ── Abstract interface
abstract class ExcelImportApi {
  /// رفع ملف Excel → يرجع job_id
  Future<UploadResponseDto> uploadExcel(File file, String department);

  /// جلب حالة الـ job
  Future<JobStatusDto> getJobStatus(String jobId);

  /// جلب قائمة الطلاب بعد اكتمال المعالجة
  Future<ResultIndexDto> getResultIndex(String jobId);

  /// جلب بيانات طالب واحد بالتفصيل
  Future<StudentDetailRaw> getStudentDetail(String jobId, String studentId);

  /// جلب مجموعة طلاب دفعة واحدة (max 50)
  Future<Map<String, StudentDetailRaw>> getStudentsBatch(
      String jobId, List<String> studentIds);
}

// ── Concrete implementation using Dio
class ExcelImportApiImpl implements ExcelImportApi {
  final Dio _dio;

  ExcelImportApiImpl({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 120),
              headers: {
                'Accept': 'application/json',
              },
            ));

  @override
  Future<UploadResponseDto> uploadExcel(File file, String department) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        'department': department,
      });

      final response = await _dio.post(
        ApiEndpoints.upload,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return UploadResponseDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<JobStatusDto> getJobStatus(String jobId) async {
    try {
      final response = await _dio.get(ApiEndpoints.jobStatus(jobId));
      return JobStatusDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<ResultIndexDto> getResultIndex(String jobId) async {
    try {
      final response = await _dio.get(ApiEndpoints.resultIndex(jobId));
      return ResultIndexDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<StudentDetailRaw> getStudentDetail(
      String jobId, String studentId) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.studentDetail(jobId, studentId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, StudentDetailRaw>> getStudentsBatch(
      String jobId, List<String> studentIds) async {
    try {
      final response =
          await _dio.get(ApiEndpoints.studentsBatch(jobId, studentIds));
      final body = response.data as Map<String, dynamic>;
      final raw = (body['students'] as Map<String, dynamic>?) ?? {};
      return raw.map((k, v) => MapEntry(k, v as Map<String, dynamic>));
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ── Error translator
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ImportApiException('انتهت مهلة الاتصال. تحقق من الشبكة.');
      case DioExceptionType.connectionError:
        return const ImportApiException(
            'لا يمكن الاتصال بالخادم. تحقق أن الخادم يعمل.');
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        final detail = _extractDetail(e.response?.data);
        if (status == 400) return ImportApiException('ملف غير صالح: $detail');
        if (status == 404) return ImportApiException('غير موجود: $detail');
        if (status == 409)
          return ImportApiException('المهمة لم تكتمل: $detail');
        if (status == 413)
          return const ImportApiException('حجم الملف كبير جداً');
        if (status == 422)
          return ImportApiException('خطأ في المعالجة: $detail');
        if (status == 429)
          return const ImportApiException('الخادم مشغول، حاول بعد قليل');
        return ImportApiException('خطأ ${status ?? "غير معروف"}: $detail');
      default:
        return ImportApiException('خطأ غير متوقع: ${e.message}');
    }
  }

  String _extractDetail(dynamic data) {
    if (data is Map) {
      return data['detail']?.toString() ??
          data['message']?.toString() ??
          data.toString();
    }
    return data?.toString() ?? '';
  }
}

class ImportApiException implements Exception {
  final String message;
  const ImportApiException(this.message);
  @override
  String toString() => 'ImportApiException: $message';
}
