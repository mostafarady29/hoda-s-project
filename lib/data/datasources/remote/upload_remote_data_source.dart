// ===== File: lib/data/datasources/remote/upload_remote_data_source.dart =====

import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/upload_response_model.dart';

abstract class UploadRemoteDataSource {
  /// رفع ملف (Mobile/Desktop)
  Future<UploadResponseModel> uploadExcel(File file, String department);

  /// ✅ رفع bytes (Web)
  Future<UploadResponseModel> uploadExcelBytes(
      List<int> bytes, String department);
}

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  final Dio _dio;

  const UploadRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<UploadResponseModel> uploadExcel(File file, String department) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'department': department,
    });
    return _upload(formData);
  }

  @override
  Future<UploadResponseModel> uploadExcelBytes(
      List<int> bytes, String department) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: 'academic_record.xlsx',
      ),
      'department': department,
    });
    return _upload(formData);
  }

  Future<UploadResponseModel> _upload(FormData formData) async {
    // ✅ ✅ ✅ التعديل هنا: /api/v1/upload بدل /upload
    final response = await _dio.post(
      '/api/v1/upload', // 👈 غيري ده
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );
    return UploadResponseModel.fromJson(response.data);
  }
}
