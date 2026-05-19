// lib/domain/expert_system/engine/inference_engine.dart
//
// المحرك الاستدلالي — يشغّل كل القواعد بالترتيب
// ويجمع النتائج في AnalysisResult

import '../../entities/academic_issue.dart';
import '../../entities/analysis_result.dart';
import '../../entities/student.dart';
import '../../../data/models/study_plan_model.dart';
import 'fact_manager.dart';
import '../rules/base_rule.dart';
import '../rules/duplicate_rule.dart';
import '../rules/prerequisite_rule.dart';
import '../rules/graduation_rule.dart';
import '../rules/gpa_warning_rule.dart';

class InferenceEngine {
  // قائمة القواعد بالترتيب
  static const List<BaseRule> _rules = [
    GpaWarningRule(), // GPA أولاً (الأعلى أولوية)
    DuplicateRule(), // تكرار المواد
    PrerequisiteRule(), // المتطلبات السابقة
    GraduationRule(), // متطلبات التخرج
  ];

  const InferenceEngine();

  /// تحليل سجل طالب مقابل لائحة معينة
  AnalysisResult analyze(Student student, StudyPlanModel curriculum) {
    // 1. بناء الحقائق
    final facts = StudentFacts.build(student, curriculum);

    // 2. تشغيل كل القواعد
    final issues = <AcademicIssue>[];
    for (final rule in _rules) {
      issues.addAll(rule.evaluate(facts));
    }

    // 3. ترتيب المشكلات: أخطاء أولاً ثم تحذيرات
    issues.sort((a, b) {
      final severityOrder = {
        IssueSeverity.error: 0,
        IssueSeverity.warning: 1,
        IssueSeverity.info: 2,
      };
      return (severityOrder[a.severity] ?? 2)
          .compareTo(severityOrder[b.severity] ?? 2);
    });

    // 4. تحديد هل يمكن التخرج
    final canGraduate = issues.isEmpty ||
        (issues.every((i) => i.isWarning || i.isInfo) &&
            facts.totalPassedHours >= curriculum.minGraduationHours &&
            facts.passedSocialCourse);

    return AnalysisResult(
      student: student,
      curriculumId: curriculum.curriculumId,
      curriculumName: curriculum.curriculumName,
      issues: issues,
      totalPassedHours: facts.totalPassedHours,
      minRequiredHours: curriculum.minGraduationHours,
      latestGpa: student.latestGpa,
      canGraduate: canGraduate,
      passedSocialCourse: facts.passedSocialCourse,
      passedUniversityRequired: facts.passedUniversityRequired,
      passedUniversityElective: facts.passedUniversityElective,
      passedFacultyRequired: facts.passedFacultyRequired,
      passedFacultyElective: facts.passedFacultyElective,
      passedProgramRequired: facts.passedProgramRequired,
      passedProgramElective: facts.passedProgramElective,
    );
  }

  /// تحليل مجموعة طلاب دفعة واحدة
  List<AnalysisResult> analyzeAll(
    List<Student> students,
    StudyPlanModel curriculum,
  ) {
    return students.map((s) => analyze(s, curriculum)).toList();
  }
}
