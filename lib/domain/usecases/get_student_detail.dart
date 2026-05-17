// ===== File: lib/domain/usecases/get_student_detail.dart =====

import '../repositories/student_repository.dart';
import '../entities/student.dart';

/// جلب بيانات طالب واحد كاملة (مع الـ cache)
class GetStudentDetailUseCase {
  final StudentRepository _repository;

  const GetStudentDetailUseCase({required StudentRepository repository})
      : _repository = repository;

  Future<Student> call(String jobId, String studentId) =>
      _repository.getStudentDetail(jobId, studentId);
}
