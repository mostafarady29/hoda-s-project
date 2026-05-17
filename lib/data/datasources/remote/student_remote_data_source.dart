// ===== File: lib/data/datasources/remote/student_remote_data_source.dart =====

import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/imported_json_record.dart';

abstract class StudentRemoteDataSource {
  /// قائمة الطلاب (أسماء + IDs) بعد اكتمال المعالجة
  Future<ImportedResultIndex> getStudentsIndex(String jobId);

  /// بيانات طالب واحد كاملة
  Future<ImportedJsonRecord> getStudentDetail(String jobId, String studentId);

  /// بيانات مجموعة طلاب دفعة واحدة (max 50)
  Future<Map<String, ImportedJsonRecord>> getStudentsBatch(
    String jobId,
    List<String> studentIds,
  );
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  final Dio _dio;

  StudentRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ImportedResultIndex> getStudentsIndex(String jobId) async {
    final response = await _dio.get(ApiEndpoints.resultIndex(jobId));
    return ImportedResultIndex.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ImportedJsonRecord> getStudentDetail(
      String jobId, String studentId) async {
    final response =
        await _dio.get(ApiEndpoints.studentDetail(jobId, studentId));
    return ImportedJsonRecord.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<Map<String, ImportedJsonRecord>> getStudentsBatch(
    String jobId,
    List<String> studentIds,
  ) async {
    final response =
        await _dio.get(ApiEndpoints.studentsBatch(jobId, studentIds));
    final body = response.data as Map<String, dynamic>;
    final raw = (body['students'] as Map<String, dynamic>?) ?? {};
    return raw.map(
      (id, data) => MapEntry(
        id,
        ImportedJsonRecord.fromJson(data as Map<String, dynamic>),
      ),
    );
  }
}
