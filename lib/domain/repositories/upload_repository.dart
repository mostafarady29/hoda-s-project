// ===== File: lib/domain/repositories/upload_repository.dart =====

import 'dart:io';
import '../../data/models/import_status_model.dart';
import '../../data/models/student_index_model.dart';

/// العقد اللي بيربط الـ domain بالـ data layer للعمليات المتعلقة بالرفع.
abstract class UploadRepository {
  /// رفع ملف Excel (File object) → يرجع job_id (Mobile/Desktop)
  Future<String> uploadExcel(File file, String department);

  /// ✅ رفع ملف Excel من bytes → يرجع job_id (Web + Cross-platform)
  Future<String> uploadExcelBytes(List<int> bytes, String department);

  /// جلب حالة الـ job (للـ polling)
  Future<ImportStatusModel> getJobStatus(String jobId);

  /// حذف job من الخادم
  Future<void> deleteJob(String jobId);

  /// جلب index قائمة الطلاب بعد اكتمال المعالجة
  Future<StudentIndexModel> getStudentsIndex(String jobId);
}
