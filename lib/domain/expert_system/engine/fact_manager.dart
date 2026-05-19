// lib/domain/expert_system/engine/fact_manager.dart
//
// يحضّر الحقائق (Facts) من سجل الطالب واللائحة
// قبل تشغيل قواعد النظام الخبير

import '../../entities/course.dart';
import '../../entities/student.dart';
import '../../../data/models/study_plan_model.dart';

/// مادة في سجل الطالب بعد التطبيع
class CourseRecord {
  final String normalizedCode; // الكود بعد التنظيف
  final String rawCode; // الكود الأصلي من الملف
  final String courseName;
  final bool isPassed; // هل API يقول إنه ناجح؟
  final double score;
  final int hours;
  final double passingScore; // الحد الأدنى للنجاح حسب اللائحة
  final String semesterLabel; // "المستوى الأول / الفصل الأول"
  final String academicYear;

  const CourseRecord({
    required this.normalizedCode,
    required this.rawCode,
    required this.courseName,
    required this.isPassed,
    required this.score,
    required this.hours,
    required this.passingScore,
    required this.semesterLabel,
    required this.academicYear,
  });

  /// هل الطالب اجتاز هذه المادة فعلاً بدرجة صحيحة؟
  /// لازم يكون الـ API يقول ناجح والدرجة >= الحد الأدنى للائحة
  bool get isActuallyPassed => isPassed && score >= passingScore;
}

class StudentFacts {
  final Student student;
  final StudyPlanModel curriculum;

  // كل الكورسات بعد التطبيع
  final List<CourseRecord> allRecords;

  // تجميعات جاهزة للقواعد
  final Map<String, List<CourseRecord>> recordsByNormalizedCode;
  final List<CourseRecord> passedRecords;
  final List<CourseRecord> failedRecords;
  final Set<String> passedNormalizedCodes;

  // توزيع الساعات حسب فئة اللائحة
  final int passedUniversityRequired;
  final int passedUniversityElective;
  final int passedFacultyRequired;
  final int passedFacultyElective;
  final int passedProgramRequired;
  final int passedProgramElective;
  final int totalPassedHours;

  final bool passedSocialCourse;

  const StudentFacts._({
    required this.student,
    required this.curriculum,
    required this.allRecords,
    required this.recordsByNormalizedCode,
    required this.passedRecords,
    required this.failedRecords,
    required this.passedNormalizedCodes,
    required this.passedUniversityRequired,
    required this.passedUniversityElective,
    required this.passedFacultyRequired,
    required this.passedFacultyElective,
    required this.passedProgramRequired,
    required this.passedProgramElective,
    required this.totalPassedHours,
    required this.passedSocialCourse,
  });

  factory StudentFacts.build(Student student, StudyPlanModel curriculum) {
    final passingScore = curriculum.passingScore;

    // ── 1. تطبيع كل الكورسات
    final allRecords = <CourseRecord>[];
    for (final semester in student.semesters) {
      for (final course in semester.courses) {
        if (course.courseName.isEmpty) continue;
        allRecords.add(CourseRecord(
          normalizedCode: StudyPlanModel.normalizeCode(course.courseCode),
          rawCode: course.courseCode,
          courseName: course.courseName,
          isPassed: course.isPassed,
          score: course.score,
          hours: course.hours,
          passingScore: passingScore,
          semesterLabel: semester.levelSemester,
          academicYear: semester.academicYear,
        ));
      }
    }

    // ── 2. تجميع حسب الكود المنظّف
    final byCode = <String, List<CourseRecord>>{};
    for (final r in allRecords) {
      byCode.putIfAbsent(r.normalizedCode, () => []).add(r);
    }

    final passed = allRecords.where((r) => r.isActuallyPassed).toList();
    final failed = allRecords.where((r) => !r.isActuallyPassed).toList();
    final passedCodes = passed.map((r) => r.normalizedCode).toSet();

    // ── 3. حساب الساعات حسب فئة اللائحة
    int uReq = 0, uElec = 0, fReq = 0, fElec = 0, pReq = 0, pElec = 0;

    for (final record in passed) {
      final currCourse = curriculum.findByCourseCode(record.rawCode);
      if (currCourse == null) continue;
      final h = record.hours > 0 ? record.hours : currCourse.creditHours;
      switch (currCourse.category) {
        case 'university_required':
          uReq += h;
          break;
        case 'university_elective':
          uElec += h;
          break;
        case 'faculty_required':
          fReq += h;
          break;
        case 'faculty_elective':
          fElec += h;
          break;
        case 'program_required':
          pReq += h;
          break;
        case 'program_elective':
          pElec += h;
          break;
      }
    }

    final totalPassed = uReq + uElec + fReq + fElec + pReq + pElec;

    // ── 4. قضايا مجتمعية (الأكواد المحتملة)
    final socialCourseCodes = ['60350', '0000', 'SOC101'];
    final passedSocial = passed.any((r) =>
        socialCourseCodes.contains(r.normalizedCode) ||
        r.courseName.contains('قضايا مجتمعية') ||
        r.courseName.contains('القضايا المجتمعية'));

    return StudentFacts._(
      student: student,
      curriculum: curriculum,
      allRecords: allRecords,
      recordsByNormalizedCode: byCode,
      passedRecords: passed,
      failedRecords: failed,
      passedNormalizedCodes: passedCodes,
      passedUniversityRequired: uReq,
      passedUniversityElective: uElec,
      passedFacultyRequired: fReq,
      passedFacultyElective: fElec,
      passedProgramRequired: pReq,
      passedProgramElective: pElec,
      totalPassedHours: totalPassed,
      passedSocialCourse: passedSocial,
    );
  }
}
