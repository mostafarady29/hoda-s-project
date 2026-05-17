// ===== File: lib/data/repositories/upload_repository_impl.dart =====

import 'dart:io';
import 'package:dio/dio.dart';

import '../../domain/repositories/upload_repository.dart';
import '../datasources/remote/upload_remote_data_source.dart';
import '../datasources/remote/job_remote_data_source.dart';
import '../datasources/remote/student_remote_data_source.dart';
import '../models/import_status_model.dart';
import '../models/student_index_model.dart';

class UploadRepositoryImpl implements UploadRepository {
  final UploadRemoteDataSource _uploadDs;
  final JobRemoteDataSource _jobDs;
  final StudentRemoteDataSource _studentDs;

  const UploadRepositoryImpl({
    required UploadRemoteDataSource uploadDataSource,
    required JobRemoteDataSource jobDataSource,
    required StudentRemoteDataSource studentDataSource,
  })  : _uploadDs = uploadDataSource,
        _jobDs = jobDataSource,
        _studentDs = studentDataSource;

  @override
  Future<String> uploadExcel(File file, String department) async {
    try {
      final response = await _uploadDs.uploadExcel(file, department);
      return response.jobId;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ✅ جديد: رفع bytes مباشرة (للـ Web)
  @override
  Future<String> uploadExcelBytes(List<int> bytes, String department) async {
    try {
      final response = await _uploadDs.uploadExcelBytes(bytes, department);
      return response.jobId;
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<ImportStatusModel> getJobStatus(String jobId) async {
    try {
      return await _jobDs.getJobStatus(jobId);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      await _jobDs.deleteJob(jobId);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<StudentIndexModel> getStudentsIndex(String jobId) async {
    try {
      final index = await _studentDs.getStudentsIndex(jobId);
      return StudentIndexModel(
        jobId: index.jobId,
        status: index.status,
        department: index.department,
        totalStudents: index.totalStudents,
        students: index.students
            .map((s) => StudentIndexItemModel(
                  studentId: s.studentId,
                  name: s.name,
                  sheetName: s.sheetName,
                ))
            .toList(),
        errors: index.errors,
      );
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  // ── Error mapping
  Exception _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final detail = _extractDetail(e.response?.data);
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return RepositoryException('انتهت مهلة الاتصال بالخادم');
      case DioExceptionType.connectionError:
        return RepositoryException('لا يمكن الاتصال بالخادم');
      case DioExceptionType.badResponse:
        if (status == 400) return RepositoryException('ملف غير صالح: $detail');
        if (status == 404) return RepositoryException('المهمة غير موجودة');
        if (status == 409)
          return RepositoryException('المهمة لم تكتمل بعد: $detail');
        if (status == 413) return RepositoryException('حجم الملف كبير جداً');
        if (status == 422)
          return RepositoryException('خطأ في المعالجة: $detail');
        if (status == 429)
          return RepositoryException('الخادم مشغول، حاول بعد قليل');
        return RepositoryException('خطأ $status: $detail');
      default:
        return RepositoryException('خطأ غير متوقع: ${e.message}');
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

class RepositoryException implements Exception {
  final String message;
  const RepositoryException(this.message);

  @override
  String toString() => message;
}
