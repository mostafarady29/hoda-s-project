// ===== File: lib/data/models/semester_model.dart =====

import '../../domain/entities/semester.dart';
import 'course_model.dart';

class SemesterModel {
  final String department;
  final String levelSemester;
  final String academicYear;
  final int totalPassedHours;
  final double gpa;
  final String grade;
  final int semesterHours;
  final double semesterGpa;
  final int levelHours;
  final double levelGpa;
  final List<CourseModel> courses;

  const SemesterModel({
    required this.department,
    required this.levelSemester,
    required this.academicYear,
    required this.totalPassedHours,
    required this.gpa,
    required this.grade,
    required this.semesterHours,
    required this.semesterGpa,
    required this.levelHours,
    required this.levelGpa,
    required this.courses,
  });

  factory SemesterModel.fromJson(Map<String, dynamic> json) {
    final coursesList = json['courses'] as List? ?? [];
    return SemesterModel(
      department: _s(json['department']),
      levelSemester: _s(json['level_semester']),
      academicYear: _s(json['academic_year']),
      totalPassedHours: _i(json['total_passed_hours']),
      gpa: _d(json['gpa']),
      grade: _s(json['grade']),
      semesterHours: _i(json['semester_hours']),
      semesterGpa: _d(json['semester_gpa']),
      levelHours: _i(json['level_hours']),
      levelGpa: _d(json['level_gpa']),
      courses: coursesList
          .map((c) => CourseModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'department': department,
        'level_semester': levelSemester,
        'academic_year': academicYear,
        'total_passed_hours': totalPassedHours,
        'gpa': gpa,
        'grade': grade,
        'semester_hours': semesterHours,
        'semester_gpa': semesterGpa,
        'level_hours': levelHours,
        'level_gpa': levelGpa,
        'courses': courses.map((c) => c.toJson()).toList(),
      };

  Semester toEntity() => Semester(
        department: department,
        levelSemester: levelSemester,
        academicYear: academicYear,
        totalPassedHours: totalPassedHours,
        gpa: gpa,
        grade: grade,
        semesterHours: semesterHours,
        semesterGpa: semesterGpa,
        levelHours: levelHours,
        levelGpa: levelGpa,
        courses: courses.map((c) => c.toEntity()).toList(),
      );

  factory SemesterModel.fromEntity(Semester entity) => SemesterModel(
        department: entity.department,
        levelSemester: entity.levelSemester,
        academicYear: entity.academicYear,
        totalPassedHours: entity.totalPassedHours,
        gpa: entity.gpa,
        grade: entity.grade,
        semesterHours: entity.semesterHours,
        semesterGpa: entity.semesterGpa,
        levelHours: entity.levelHours,
        levelGpa: entity.levelGpa,
        courses: entity.courses.map(CourseModel.fromEntity).toList(),
      );

  static String _s(dynamic v) => v?.toString().trim() ?? '';
  static int _i(dynamic v) =>
      v == null ? 0 : (int.tryParse(v.toString().trim()) ?? 0);
  static double _d(dynamic v) =>
      v == null ? 0.0 : (double.tryParse(v.toString().trim()) ?? 0.0);
}
