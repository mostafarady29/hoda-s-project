// ===== File: lib/data/models/upload_response_model.dart =====
//
// يمثّل الـ response من POST /api/v1/upload
// { "job_id": "...", "status": "pending", "message": "..." }

class UploadResponseModel {
  final String jobId;
  final String status;
  final String message;

  const UploadResponseModel({
    required this.jobId,
    required this.status,
    required this.message,
  });

  factory UploadResponseModel.fromJson(Map<String, dynamic> json) {
    return UploadResponseModel(
      jobId: json['job_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'job_id': jobId,
        'status': status,
        'message': message,
      };

  @override
  String toString() =>
      'UploadResponseModel(jobId: $jobId, status: $status, message: $message)';
}
