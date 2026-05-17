// ===== File: lib/data/models/student_index_model.dart =====
//
// يمثّل response من GET /api/v1/result/{job_id}
// { job_id, status, department, total_students,
//   students: [{student_id, name, sheet_name}], errors: [] }

class StudentIndexItemModel {
  final String studentId;
  final String name;
  final String sheetName;

  const StudentIndexItemModel({
    required this.studentId,
    required this.name,
    required this.sheetName,
  });

  factory StudentIndexItemModel.fromJson(Map<String, dynamic> json) =>
      StudentIndexItemModel(
        studentId: json['student_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        sheetName: json['sheet_name'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'name': name,
        'sheet_name': sheetName,
      };
}

class StudentIndexModel {
  final String jobId;
  final String status;
  final String? department;
  final int totalStudents;
  final List<StudentIndexItemModel> students;
  final List<Map<String, dynamic>> errors;

  const StudentIndexModel({
    required this.jobId,
    required this.status,
    this.department,
    required this.totalStudents,
    required this.students,
    required this.errors,
  });

  factory StudentIndexModel.fromJson(Map<String, dynamic> json) =>
      StudentIndexModel(
        jobId: json['job_id'] as String? ?? '',
        status: json['status'] as String? ?? '',
        department: json['department'] as String?,
        totalStudents: json['total_students'] as int? ?? 0,
        students: (json['students'] as List? ?? [])
            .map((e) =>
                StudentIndexItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        errors: (json['errors'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList(),
      );

  bool get hasErrors => errors.isNotEmpty;
  bool get isPartialSuccess => status == 'partial_success';
}
