// ===== File: lib/data/mappers/import_mapper.dart =====
//
// يحول الـ JSON الخام اللي بيرجعه الباك اند
// إلى Domain Entities اللي بيشتغل بيهم الـ Expert System.
//

import '../../domain/entities/student.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/semester.dart';

class ImportMapper {
  const ImportMapper();

  /// Entry point: raw JSON → Student entity
  Student fromRaw(Map<String, dynamic> raw) {
    final studentMap = raw['student'] as Map<String, dynamic>? ?? {};
    final semestersList = raw['semesters'] as List? ?? [];

    return Student(
      id: _str(studentMap['id']),
      name: _str(studentMap['name']),
      studyLevel: _str(studentMap['study_level']),
      department: _str(studentMap['department']),
      cumulativePercentage: _str(studentMap['cumulative_percentage']),
      semesters: semestersList
          .map((s) => _mapSemester(s as Map<String, dynamic>))
          .toList(),
      parsedAt: raw['parsed_at'] as String?,
      sheetName: raw['sheet_name'] as String?,
    );
  }

  Semester _mapSemester(Map<String, dynamic> s) {
    final coursesList = s['courses'] as List? ?? [];

    return Semester(
      department: _str(s['department']),
      levelSemester: _str(s['level_semester']), // e.g. "الأول / الأول"
      academicYear: _str(s['academic_year']), // e.g. "2020/2021"
      totalPassedHours: _parseInt(s['total_passed_hours']),
      gpa: _parseDouble(s['gpa']),
      grade: _str(s['grade']),
      semesterHours: _parseInt(s['semester_hours']),
      semesterGpa: _parseDouble(s['semester_gpa']),
      levelHours: _parseInt(s['level_hours']),
      levelGpa: _parseDouble(s['level_gpa']),
      courses: coursesList
          .map((c) => _mapCourse(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Course _mapCourse(Map<String, dynamic> c) {
    return Course(
      seq: _str(c['seq']),
      courseCode: _str(c['course_code']),
      courseName: _str(c['course_name']),
      isPassed: _parsePassed(c['passed']),
      gradeLetter: _str(c['grade_letter']),
      score: _parseDouble(c['score']),
      hours: _parseInt(c['hours']),
      points: _parseDouble(c['points']),
      cumulative: _str(c['cumulative']),
      minScore: _parseDouble(c['min_score']),
      maxScore: _parseDouble(c['max_score']),
    );
  }

  // ── Helpers

  String _str(dynamic v) => v?.toString().trim() ?? '';

  int _parseInt(dynamic v) {
    if (v == null || v.toString().trim().isEmpty) return 0;
    return int.tryParse(v.toString().trim()) ?? 0;
  }

  double _parseDouble(dynamic v) {
    if (v == null || v.toString().trim().isEmpty) return 0.0;
    return double.tryParse(v.toString().trim()) ?? 0.0;
  }

  /// الباك اند بيرجع "نعم" أو "" أو "راسب" أو درجة
  bool _parsePassed(dynamic v) {
    final s = v?.toString().trim().toLowerCase() ?? '';
    if (s == 'نعم' || s == 'yes' || s == 'true' || s == '1') return true;
    if (s == 'راسب' || s == 'no' || s == 'false' || s == '0') return false;
    // لو درجة → اعتبرها ناجح لو > 0
    final num = double.tryParse(s);
    return num != null && num > 0;
  }
}
