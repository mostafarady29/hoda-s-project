// ===== File: lib/domain/usecases/get_job_status.dart =====

import '../repositories/upload_repository.dart';
import '../../data/models/import_status_model.dart';

/// جلب حالة الـ job الحالية (يُستدعى في الـ polling loop)
class GetJobStatusUseCase {
  final UploadRepository _repository;

  const GetJobStatusUseCase({required UploadRepository repository})
      : _repository = repository;

  Future<ImportStatusModel> call(String jobId) =>
      _repository.getJobStatus(jobId);
}
