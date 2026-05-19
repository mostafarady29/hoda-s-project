// lib/domain/entities/analysis_result.dart

import 'academic_issue.dart';
import 'student.dart';

class AnalysisResult {
  final Student student;
  final String curriculumId;
  final String curriculumName;
  final List<AcademicIssue> issues;

  // ── إحصائيات سريعة
  final int totalPassedHours;
  final int minRequiredHours;
  final double latestGpa;
  final bool canGraduate;
  final bool passedSocialCourse; // قضايا مجتمعية

  // توزيع الساعات المجتازة بالفئة
  final int passedUniversityRequired;
  final int passedUniversityElective;
  final int passedFacultyRequired;
  final int passedFacultyElective;
  final int passedProgramRequired;
  final int passedProgramElective;

  const AnalysisResult({
    required this.student,
    required this.curriculumId,
    required this.curriculumName,
    required this.issues,
    required this.totalPassedHours,
    required this.minRequiredHours,
    required this.latestGpa,
    required this.canGraduate,
    required this.passedSocialCourse,
    this.passedUniversityRequired = 0,
    this.passedUniversityElective = 0,
    this.passedFacultyRequired = 0,
    this.passedFacultyElective = 0,
    this.passedProgramRequired = 0,
    this.passedProgramElective = 0,
  });

  List<AcademicIssue> get errors => issues.where((i) => i.isError).toList();

  List<AcademicIssue> get warnings => issues.where((i) => i.isWarning).toList();

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get isClean => issues.isEmpty;

  int get hoursRemaining =>
      (minRequiredHours - totalPassedHours).clamp(0, minRequiredHours);

  double get graduationProgress => minRequiredHours == 0
      ? 0
      : (totalPassedHours / minRequiredHours).clamp(0.0, 1.0);

  String get overallStatus {
    if (hasErrors) return 'يوجد أخطاء أكاديمية';
    if (hasWarnings) return 'يوجد تحذيرات';
    if (canGraduate) return 'مستوفٍ لمتطلبات التخرج';
    return 'لا توجد مشكلات';
  }
}
