// ===== File: lib/data/repositories/student_repository_impl.dart =====

import 'package:dio/dio.dart';

import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student.dart';
import '../datasources/remote/student_remote_data_source.dart';
import '../mappers/import_mapper.dart';
import '../models/imported_json_record.dart';
import '../../core/services/storage/hive_storage_service.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource _remoteDs;
  final ImportMapper _mapper;
  final HiveStorageService _storage;

  StudentRepositoryImpl({
    required StudentRemoteDataSource remoteDataSource,
    ImportMapper? mapper,
    HiveStorageService? storage,
  })  : _remoteDs = remoteDataSource,
        _mapper = mapper ?? const ImportMapper(),
        _storage = storage ?? HiveStorageService.instance;

  @override
  Future<Student> getStudentDetail(String jobId, String studentId) async {
    // 1. بص في الـ cache الأول
    final cached = getCachedStudent(jobId, studentId);
    if (cached != null) return cached;

    // 2. اجلب من الخادم
    try {
      final record = await _remoteDs.getStudentDetail(jobId, studentId);

      // 3. احفظ في الـ cache للـ offline
      await _storage.saveStudent(jobId, record);

      return _mapper.fromRaw(record.toJson());
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<List<Student>> getStudentsBatch(
      String jobId, List<String> studentIds) async {
    // فصّل بين اللي عندنا locally واللي محتاجين نجيبه
    final needed = <String>[];
    final result = <Student>[];

    for (final id in studentIds) {
      final cached = getCachedStudent(jobId, id);
      if (cached != null) {
        result.add(cached);
      } else {
        needed.add(id);
      }
    }

    if (needed.isEmpty) return result;

    // جيب الباقي من الخادم (chunks of 50)
    try {
      const chunkSize = 50;
      for (var i = 0; i < needed.length; i += chunkSize) {
        final chunk = needed.sublist(
          i,
          i + chunkSize > needed.length ? needed.length : i + chunkSize,
        );

        final recordMap = await _remoteDs.getStudentsBatch(jobId, chunk);

        // احفظ في الـ cache
        await _storage.saveStudentsBatch(jobId, recordMap.values.toList());

        // حوّل لـ entities
        result.addAll(
          recordMap.values.map((r) => _mapper.fromRaw(r.toJson())),
        );
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    }

    return result;
  }

  @override
  Student? getCachedStudent(String jobId, String studentId) {
    final record = _storage.getStudent(jobId, studentId);
    if (record == null) return null;
    try {
      return _mapper.fromRaw(record.toJson());
    } catch (_) {
      return null;
    }
  }

  @override
  bool isStudentCached(String jobId, String studentId) =>
      _storage.hasStudent(jobId, studentId);

  // ── Error mapping
  Exception _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return StudentRepositoryException('انتهت مهلة الاتصال');
      case DioExceptionType.connectionError:
        return StudentRepositoryException('لا يوجد اتصال بالخادم');
      case DioExceptionType.badResponse:
        if (status == 404)
          return StudentRepositoryException('الطالب غير موجود');
        if (status == 409)
          return StudentRepositoryException('المهمة لم تكتمل بعد');
        return StudentRepositoryException('خطأ $status من الخادم');
      default:
        return StudentRepositoryException('خطأ غير متوقع: ${e.message}');
    }
  }
}

class StudentRepositoryException implements Exception {
  final String message;
  const StudentRepositoryException(this.message);

  @override
  String toString() => message;
}
