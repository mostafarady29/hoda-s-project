// ===== File: lib/data/datasources/remote/job_remote_data_source.dart =====

import 'package:dio/dio.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/import_status_model.dart';

abstract class JobRemoteDataSource {
  /// جلب حالة الـ job (للـ polling)
  Future<ImportStatusModel> getJobStatus(String jobId);

  /// حذف job ونتائجها من الخادم
  Future<void> deleteJob(String jobId);
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final Dio _dio;

  JobRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ImportStatusModel> getJobStatus(String jobId) async {
    final response = await _dio.get(ApiEndpoints.jobStatus(jobId));
    return ImportStatusModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteJob(String jobId) async {
    await _dio.delete(ApiEndpoints.deleteJob(jobId));
  }
}
