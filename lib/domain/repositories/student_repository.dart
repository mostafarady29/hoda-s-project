// ===== File: lib/domain/repositories/student_repository.dart =====

import '../entities/student.dart';

/// العقد اللي بيربط الـ domain بالـ data layer لعمليات الطلاب.
abstract class StudentRepository {
  /// جلب بيانات طالب واحد كاملة (من الخادم أو الـ cache)
  Future<Student> getStudentDetail(String jobId, String studentId);

  /// جلب مجموعة طلاب دفعة واحدة
  Future<List<Student>> getStudentsBatch(String jobId, List<String> studentIds);

  /// جلب الطالب من الـ local cache فقط (offline mode)
  Student? getCachedStudent(String jobId, String studentId);

  /// هل الطالب محفوظ locally?
  bool isStudentCached(String jobId, String studentId);
}
