// ===== File: lib/data/models/import_status_model.dart =====
//
// يمثّل الـ response من GET /api/v1/job/{job_id}
// {
//   "job_id": "...",
//   "status": "processing" | "completed" | "failed" | "partial_success" | "pending",
//   "filename": "...",
//   "department": "...",
//   "created_at": "...",
//   "updated_at": "...",
//   "stats": { "total_students": 50, "successful": 48, "failed": 2 },
//   "error_log": [...]
// }

class ImportStatsModel {
  final int totalStudents;
  final int successful;
  final int failed;

  const ImportStatsModel({
    this.totalStudents = 0,
    this.successful = 0,
    this.failed = 0,
  });

  factory ImportStatsModel.fromJson(Map<String, dynamic> json) {
    return ImportStatsModel(
      totalStudents: _parseInt(json['total_students']),
      successful: _parseInt(json['successful']),
      failed: _parseInt(json['failed']),
    );
  }

  static int _parseInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

  Map<String, dynamic> toJson() => {
        'total_students': totalStudents,
        'successful': successful,
        'failed': failed,
      };

  double get successRate =>
      totalStudents == 0 ? 0.0 : successful / totalStudents;
}

class ImportStatusModel {
  final String jobId;
  final String status;
  final String? filename;
  final String? department;
  final String? createdAt;
  final String? updatedAt;
  final ImportStatsModel stats;
  final List<String> errorLog;

  const ImportStatusModel({
    required this.jobId,
    required this.status,
    this.filename,
    this.department,
    this.createdAt,
    this.updatedAt,
    this.stats = const ImportStatsModel(),
    this.errorLog = const [],
  });

  // ── Status helpers
  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isPartialSuccess => status == 'partial_success';
  bool get isDone => isCompleted || isPartialSuccess;
  bool get isFailed => status == 'failed';
  bool get isActive => isPending || isProcessing;

  factory ImportStatusModel.fromJson(Map<String, dynamic> json) {
    final statsRaw = json['stats'];
    return ImportStatusModel(
      jobId: json['job_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      filename: json['filename'] as String?,
      department: json['department'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      stats: statsRaw is Map<String, dynamic>
          ? ImportStatsModel.fromJson(statsRaw)
          : const ImportStatsModel(),
      errorLog:
          (json['error_log'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'job_id': jobId,
        'status': status,
        'filename': filename,
        'department': department,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'stats': stats.toJson(),
        'error_log': errorLog,
      };

  /// Arabic label for the current status
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'في الانتظار';
      case 'processing':
        return 'جاري المعالجة';
      case 'completed':
        return 'اكتملت بنجاح';
      case 'partial_success':
        return 'اكتملت مع تحذيرات';
      case 'failed':
        return 'فشلت المعالجة';
      default:
        return status;
    }
  }

  @override
  String toString() =>
      'ImportStatusModel(jobId: $jobId, status: $status, stats: ${stats.toJson()})';
}
