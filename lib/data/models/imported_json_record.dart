// ===== File: lib/data/models/imported_json_record.dart =====
//
// يمثّل بنية الـ JSON الكاملة اللي بيرجعها الباك اند
// لكل طالب من GET /api/v1/result/{job_id}/student/{student_id}
//
// البنية:
// {
//   "student": { id, name, study_level, cumulative_percentage, department },
//   "semesters": [
//     {
//       "department": "...",
//       "level_semester": "الأول / الأول",
//       "academic_year": "2020/2021",
//       "total_passed_hours": "30",
//       "gpa": "3.5",
//       "grade": "...",
//       "semester_hours": "...",
//       "semester_gpa": "...",
//       "level_hours": "...",
//       "level_gpa": "...",
//       "courses": [
//         {
//           "seq": "1", "course_code": "CS101", "course_name": "...",
//           "passed": "نعم", "grade_letter": "A", "score": "85",
//           "hours": "3", "points": "...", "cumulative": "...",
//           "min_score": "...", "max_score": "..."
//         }
//       ]
//     }
//   ],
//   "sheet_name": "Sheet1",
//   "parsed_at": "2024-..."
// }

// ──────────────────────────────────────────────
// Student info
// ──────────────────────────────────────────────
class ImportedStudentInfo {
  final String id;
  final String name;
  final String studyLevel;
  final String cumulativePercentage;
  final String department;

  const ImportedStudentInfo({
    required this.id,
    required this.name,
    required this.studyLevel,
    required this.cumulativePercentage,
    required this.department,
  });

  factory ImportedStudentInfo.fromJson(Map<String, dynamic> json) {
    return ImportedStudentInfo(
      id: _s(json['id']),
      name: _s(json['name']),
      studyLevel: _s(json['study_level']),
      cumulativePercentage: _s(json['cumulative_percentage']),
      department: _s(json['department']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'study_level': studyLevel,
        'cumulative_percentage': cumulativePercentage,
        'department': department,
      };

  static String _s(dynamic v) => v?.toString().trim() ?? '';
}

// ──────────────────────────────────────────────
// Course record
// ──────────────────────────────────────────────
class ImportedCourseRecord {
  final String seq;
  final String courseCode;
  final String courseName;
  final String passed; // "نعم" | "" | درجة عددية
  final String gradeLetter; // "A" | "B+" | "راسب" إلخ
  final String score;
  final String hours;
  final String points;
  final String cumulative;
  final String minScore;
  final String maxScore;

  const ImportedCourseRecord({
    required this.seq,
    required this.courseCode,
    required this.courseName,
    required this.passed,
    required this.gradeLetter,
    required this.score,
    required this.hours,
    required this.points,
    required this.cumulative,
    required this.minScore,
    required this.maxScore,
  });

  factory ImportedCourseRecord.fromJson(Map<String, dynamic> json) {
    return ImportedCourseRecord(
      seq: _s(json['seq']),
      courseCode: _s(json['course_code']),
      courseName: _s(json['course_name']),
      passed: _s(json['passed']),
      gradeLetter: _s(json['grade_letter']),
      score: _s(json['score']),
      hours: _s(json['hours']),
      points: _s(json['points']),
      cumulative: _s(json['cumulative']),
      minScore: _s(json['min_score']),
      maxScore: _s(json['max_score']),
    );
  }

  Map<String, dynamic> toJson() => {
        'seq': seq,
        'course_code': courseCode,
        'course_name': courseName,
        'passed': passed,
        'grade_letter': gradeLetter,
        'score': score,
        'hours': hours,
        'points': points,
        'cumulative': cumulative,
        'min_score': minScore,
        'max_score': maxScore,
      };

  // Helpers
  bool get isPassed {
    final lower = passed.toLowerCase().trim();
    if (lower == 'نعم' || lower == 'yes') return true;
    if (lower == 'راسب' || lower == 'no' || lower == 'لا') return false;
    final num = double.tryParse(score);
    return num != null && num >= 50;
  }

  int get hoursInt => int.tryParse(hours) ?? 0;
  double get scoreDouble => double.tryParse(score) ?? 0.0;

  static String _s(dynamic v) => v?.toString().trim() ?? '';
}

// ──────────────────────────────────────────────
// Semester record
// ──────────────────────────────────────────────
class ImportedSemesterRecord {
  final String department;
  final String levelSemester; // "الأول / الأول"
  final String academicYear; // "2020/2021"
  final String totalPassedHours;
  final String gpa;
  final String grade;
  final String semesterHours;
  final String semesterGpa;
  final String levelHours;
  final String levelGpa;
  final List<ImportedCourseRecord> courses;

  const ImportedSemesterRecord({
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

  factory ImportedSemesterRecord.fromJson(Map<String, dynamic> json) {
    final coursesList = json['courses'] as List? ?? [];
    return ImportedSemesterRecord(
      department: _s(json['department']),
      levelSemester: _s(json['level_semester']),
      academicYear: _s(json['academic_year']),
      totalPassedHours: _s(json['total_passed_hours']),
      gpa: _s(json['gpa']),
      grade: _s(json['grade']),
      semesterHours: _s(json['semester_hours']),
      semesterGpa: _s(json['semester_gpa']),
      levelHours: _s(json['level_hours']),
      levelGpa: _s(json['level_gpa']),
      courses: coursesList
          .map((c) => ImportedCourseRecord.fromJson(c as Map<String, dynamic>))
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

  // Helpers
  int get totalPassedHoursInt => int.tryParse(totalPassedHours) ?? 0;
  double get gpaDouble => double.tryParse(gpa) ?? 0.0;
  int get semesterHoursInt => int.tryParse(semesterHours) ?? 0;

  List<ImportedCourseRecord> get passedCourses =>
      courses.where((c) => c.isPassed).toList();

  List<ImportedCourseRecord> get failedCourses =>
      courses.where((c) => !c.isPassed && c.courseName.isNotEmpty).toList();

  static String _s(dynamic v) => v?.toString().trim() ?? '';
}

// ──────────────────────────────────────────────
// Top-level: full student JSON record
// ──────────────────────────────────────────────
class ImportedJsonRecord {
  final ImportedStudentInfo student;
  final List<ImportedSemesterRecord> semesters;
  final String sheetName;
  final String parsedAt;

  const ImportedJsonRecord({
    required this.student,
    required this.semesters,
    required this.sheetName,
    required this.parsedAt,
  });

  factory ImportedJsonRecord.fromJson(Map<String, dynamic> json) {
    final studentRaw = json['student'] as Map<String, dynamic>? ?? {};
    final semestersRaw = json['semesters'] as List? ?? [];

    return ImportedJsonRecord(
      student: ImportedStudentInfo.fromJson(studentRaw),
      semesters: semestersRaw
          .map(
              (s) => ImportedSemesterRecord.fromJson(s as Map<String, dynamic>))
          .toList(),
      sheetName: json['sheet_name'] as String? ?? '',
      parsedAt: json['parsed_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'student': student.toJson(),
        'semesters': semesters.map((s) => s.toJson()).toList(),
        'sheet_name': sheetName,
        'parsed_at': parsedAt,
      };

  // ── Aggregate helpers (مهمين للـ Expert System)

  /// كل المواد في التاريخ الدراسي
  List<ImportedCourseRecord> get allCourses =>
      semesters.expand((s) => s.courses).toList();

  /// المواد الناجح فيها فقط
  List<ImportedCourseRecord> get passedCourses =>
      allCourses.where((c) => c.isPassed).toList();

  /// إجمالي الساعات المعتمدة الناجح فيها
  int get totalPassedCreditHours =>
      passedCourses.fold(0, (sum, c) => sum + c.hoursInt);

  /// آخر semester (الأحدث)
  ImportedSemesterRecord? get latestSemester =>
      semesters.isNotEmpty ? semesters.last : null;

  /// آخر GPA تراكمي
  double get latestCumulativeGpa {
    for (final s in semesters.reversed) {
      final v = double.tryParse(s.gpa);
      if (v != null && v > 0) return v;
    }
    return 0.0;
  }

  /// كل الأكواد التي درسها الطالب (للكشف عن التكرار)
  List<String> get allCourseCodesStudied =>
      allCourses.map((c) => c.courseCode).where((c) => c.isNotEmpty).toList();

  /// أكواد المواد التي نجح فيها
  Set<String> get passedCourseCodes =>
      passedCourses.map((c) => c.courseCode).where((c) => c.isNotEmpty).toSet();
}

// ──────────────────────────────────────────────
// Index entry (من GET /result/{job_id})
// ──────────────────────────────────────────────
class ImportedStudentSummary {
  final String studentId;
  final String name;
  final String sheetName;

  const ImportedStudentSummary({
    required this.studentId,
    required this.name,
    required this.sheetName,
  });

  factory ImportedStudentSummary.fromJson(Map<String, dynamic> json) {
    return ImportedStudentSummary(
      studentId: json['student_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sheetName: json['sheet_name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'name': name,
        'sheet_name': sheetName,
      };
}

class ImportedResultIndex {
  final String jobId;
  final String status;
  final String? department;
  final int totalStudents;
  final List<ImportedStudentSummary> students;
  final List<Map<String, dynamic>> errors;

  const ImportedResultIndex({
    required this.jobId,
    required this.status,
    this.department,
    required this.totalStudents,
    required this.students,
    required this.errors,
  });

  factory ImportedResultIndex.fromJson(Map<String, dynamic> json) {
    return ImportedResultIndex(
      jobId: json['job_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      department: json['department'] as String?,
      totalStudents: json['total_students'] as int? ?? 0,
      students: (json['students'] as List? ?? [])
          .map(
              (e) => ImportedStudentSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      errors: (json['errors'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}
