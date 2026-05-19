// lib/data/models/study_plan_model.dart
//
// يمثّل اللائحة الدراسية المحملة من assets/plans/*.json
// هيكلها مطابق لملفات JSON الموجودة

class CurriculumCourseModel {
  final String courseCode;
  final String courseNameAr;
  final String courseNameEn;
  final int creditHours;
  final int level; // 0 = yearly/any, 1-4 = year
  final String semester; // "Fall" | "Spring" | "Yearly"
  final String
      category; // university_required | university_elective | faculty_required | faculty_elective | program_required | program_elective
  final bool isElective;
  final String? electiveGroup;
  final List<String> prerequisites;
  final List<String> equivalentCodes;
  final List<int> conflictWith;
  final String departmentCode;

  const CurriculumCourseModel({
    required this.courseCode,
    required this.courseNameAr,
    required this.courseNameEn,
    required this.creditHours,
    required this.level,
    required this.semester,
    required this.category,
    required this.isElective,
    this.electiveGroup,
    required this.prerequisites,
    required this.equivalentCodes,
    required this.conflictWith,
    required this.departmentCode,
  });

  factory CurriculumCourseModel.fromJson(Map<String, dynamic> json) {
    return CurriculumCourseModel(
      courseCode: _s(json['course_code']),
      courseNameAr: _s(json['course_name_ar']),
      courseNameEn: _s(json['course_name_en']),
      creditHours: _i(json['credit_hours']),
      level: _i(json['level']),
      semester: _s(json['semester']),
      category: _s(json['category']),
      isElective: json['is_elective'] as bool? ?? false,
      electiveGroup: json['elective_group'] as String?,
      prerequisites: _strList(json['prerequisites']),
      equivalentCodes: _strList(json['equivalent_codes']),
      conflictWith: _intList(json['conflict_with']),
      departmentCode: _s(json['department_code']),
    );
  }

  static String _s(dynamic v) => v?.toString().trim() ?? '';
  static int _i(dynamic v) => v == null ? 0 : (int.tryParse(v.toString()) ?? 0);
  static List<String> _strList(dynamic v) =>
      (v as List?)?.map((e) => e.toString().trim()).toList() ?? [];
  static List<int> _intList(dynamic v) =>
      (v as List?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [];
}

class StudyPlanModel {
  final String curriculumId;
  final String curriculumName;
  final String programType; // "regular" | "special_program"
  final int admissionYearStart;
  final List<String> departments;
  final List<CurriculumCourseModel> courses;

  // إجمالي ساعات كل فئة (محسوبة من الكورسات)
  late final int totalUniversityRequired;
  late final int totalUniversityElective;
  late final int totalFacultyRequired;
  late final int totalFacultyElective;
  late final int totalProgramRequired;
  late final int totalProgramElective;
  late final int totalHours;

  // الحد الأدنى للتخرج حسب اللائحة
  final int minGraduationHours;

  StudyPlanModel({
    required this.curriculumId,
    required this.curriculumName,
    required this.programType,
    required this.admissionYearStart,
    required this.departments,
    required this.courses,
    required this.minGraduationHours,
  }) {
    totalUniversityRequired = _sumHours('university_required');
    totalUniversityElective = _sumHours('university_elective');
    totalFacultyRequired = _sumHours('faculty_required');
    totalFacultyElective = _sumHours('faculty_elective');
    totalProgramRequired = _sumHours('program_required');
    totalProgramElective = _sumHours('program_elective');
    totalHours = totalUniversityRequired +
        totalUniversityElective +
        totalFacultyRequired +
        totalFacultyElective +
        totalProgramRequired +
        totalProgramElective;
  }

  factory StudyPlanModel.fromJson(Map<String, dynamic> json) {
    final coursesList = (json['courses'] as List? ?? [])
        .map((c) => CurriculumCourseModel.fromJson(c as Map<String, dynamic>))
        .toList();

    // حساب الحد الأدنى للتخرج من metadata أو افتراضي
    final minHours = json['min_graduation_hours'] as int? ??
        _defaultMinHours(json['curriculum_id']?.toString() ?? '');

    return StudyPlanModel(
      curriculumId: json['curriculum_id']?.toString() ?? '',
      curriculumName: json['curriculum_name']?.toString() ?? '',
      programType: json['program_type']?.toString() ?? 'regular',
      admissionYearStart: json['admission_year_start'] as int? ?? 2019,
      departments:
          (json['departments'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      courses: coursesList,
      minGraduationHours: minHours,
    );
  }

  // ── الحد الأدنى حسب نوع اللائحة
  static int _defaultMinHours(String id) {
    if (id.contains('cs_english') || id.contains('computer_teacher'))
      return 146;
    if (id.contains('digital_art') || id.contains('fne')) return 150;
    if (id.contains('2024')) return 150;
    return 140; // لائحة 2019 الأقسام العادية
  }

  // ── درجة النجاح حسب نوع البرنامج
  double get passingScore => programType == 'special_program' ? 60.0 : 50.0;

  int _sumHours(String category) => courses
      .where((c) => c.category == category)
      .fold(0, (sum, c) => sum + c.creditHours);

  // ── البحث عن مادة بالكود (مع تنظيف)
  CurriculumCourseModel? findByCourseCode(String rawCode) {
    final cleaned = normalizeCode(rawCode);
    // أولاً: exact match على equivalent_codes
    for (final course in courses) {
      for (final eq in course.equivalentCodes) {
        if (normalizeCode(eq) == cleaned) return course;
      }
    }
    // ثانياً: partial match على courseCode
    for (final course in courses) {
      if (normalizeCode(course.courseCode).contains(cleaned) ||
          cleaned.contains(normalizeCode(course.courseCode))) {
        return course;
      }
    }
    return null;
  }

  /// تنظيف كود المادة: إزالة المسافات والرموز العربية والحروف الزائدة
  static String normalizeCode(String raw) {
    if (raw.isEmpty) return '';
    return raw
        .replaceAll(RegExp(r'[\s\u0600-\u06FF]+'), '') // مسافات وعربي
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') // أي رمز خاص
        .toUpperCase();
  }
}
