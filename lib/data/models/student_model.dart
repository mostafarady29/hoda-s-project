// ===== File: lib/data/models/student_model.dart =====

import '../../domain/entities/student.dart';
import 'semester_model.dart';

class StudentModel {
  final String id;
  final String name;
  final String studyLevel;
  final String department;
  final String cumulativePercentage;
  final List<SemesterModel> semesters;
  final String? parsedAt;
  final String? sheetName;

  const StudentModel({
    required this.id,
    required this.name,
    required this.studyLevel,
    required this.department,
    required this.cumulativePercentage,
    required this.semesters,
    this.parsedAt,
    this.sheetName,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    final studentMap = json['student'] as Map<String, dynamic>? ?? json;
    final semestersList = json['semesters'] as List? ?? [];

    return StudentModel(
      id: _s(studentMap['id']),
      name: _s(studentMap['name']),
      studyLevel: _s(studentMap['study_level']),
      department: _s(studentMap['department']),
      cumulativePercentage: _s(studentMap['cumulative_percentage']),
      semesters: semestersList
          .map((s) => SemesterModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      parsedAt: json['parsed_at'] as String?,
      sheetName: json['sheet_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'student': {
          'id': id,
          'name': name,
          'study_level': studyLevel,
          'department': department,
          'cumulative_percentage': cumulativePercentage,
        },
        'semesters': semesters.map((s) => s.toJson()).toList(),
        'parsed_at': parsedAt,
        'sheet_name': sheetName,
      };

  /// موديل → Domain Entity
  Student toEntity() => Student(
        id: id,
        name: name,
        studyLevel: studyLevel,
        department: department,
        cumulativePercentage: cumulativePercentage,
        semesters: semesters.map((s) => s.toEntity()).toList(),
        parsedAt: parsedAt,
        sheetName: sheetName,
      );

  /// Domain Entity → موديل
  factory StudentModel.fromEntity(Student entity) => StudentModel(
        id: entity.id,
        name: entity.name,
        studyLevel: entity.studyLevel,
        department: entity.department,
        cumulativePercentage: entity.cumulativePercentage,
        semesters:
            entity.semesters.map((s) => SemesterModel.fromEntity(s)).toList(),
        parsedAt: entity.parsedAt,
        sheetName: entity.sheetName,
      );

  static String _s(dynamic v) => v?.toString().trim() ?? '';
}
