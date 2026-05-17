// ===== File: lib/domain/usecases/upload_excel.dart =====

import 'dart:io';
import '../repositories/upload_repository.dart';

/// رفع ملف Excel → يرجع job_id
class UploadExcelUseCase {
  final UploadRepository _repository;

  const UploadExcelUseCase({required UploadRepository repository})
      : _repository = repository;

  // للـ Mobile/Desktop (File object)
  Future<String> call(File file, String department) =>
      _repository.uploadExcel(file, department);

  // ✅ للـ Web (bytes مباشرة)
  Future<String> fromBytes(List<int> bytes, String department) =>
      _repository.uploadExcelBytes(bytes, department);
}
