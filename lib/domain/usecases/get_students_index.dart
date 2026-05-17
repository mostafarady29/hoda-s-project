// ===== File: lib/domain/usecases/get_students_index.dart =====

import '../repositories/upload_repository.dart';
import '../../data/models/student_index_model.dart';

/// جلب قائمة الطلاب (أسماء + IDs) بعد اكتمال المعالجة
class GetStudentsIndexUseCase {
  final UploadRepository _repository;

  const GetStudentsIndexUseCase({required UploadRepository repository})
      : _repository = repository;

  Future<StudentIndexModel> call(String jobId) =>
      _repository.getStudentsIndex(jobId);
}
