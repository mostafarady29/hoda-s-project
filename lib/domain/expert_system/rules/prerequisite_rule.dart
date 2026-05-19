// lib/domain/expert_system/rules/prerequisite_rule.dart
//
// RULE-100: تسجيل مادة دون استيفاء متطلبها السابق
// RULE-101: تسجيل مادة دون أي من متطلباتها السابقة

import '../../entities/academic_issue.dart';
import '../engine/fact_manager.dart';
import 'base_rule.dart';
import '../../../data/models/study_plan_model.dart';

class PrerequisiteRule extends BaseRule {
  const PrerequisiteRule();

  @override
  List<AcademicIssue> evaluate(StudentFacts facts) {
    final issues = <AcademicIssue>[];

    // لكل مادة في سجل الطالب (مجتازة أو مسجلة)
    for (final record in facts.allRecords) {
      final currCourse = facts.curriculum.findByCourseCode(record.rawCode);
      if (currCourse == null || currCourse.prerequisites.isEmpty) continue;

      // تحقق من كل متطلب سابق
      final missingPrereqs = <String>[];
      final missingNames = <String>[];

      for (final prereqCode in currCourse.prerequisites) {
        final prereqNorm = StudyPlanModel.normalizeCode(prereqCode);
        final satisfied = facts.passedNormalizedCodes.any(
            (code) => code.contains(prereqNorm) || prereqNorm.contains(code));

        if (!satisfied) {
          missingPrereqs.add(prereqCode);
          // ابحث عن اسم المتطلب
          final prereqCourse = facts.curriculum.findByCourseCode(prereqCode);
          missingNames.add(prereqCourse?.courseNameAr ?? prereqCode);
        }
      }

      if (missingPrereqs.isEmpty) continue;

      final allMissing =
          missingPrereqs.length == currCourse.prerequisites.length;

      issues.add(AcademicIssue(
        ruleId: allMissing ? 'RULE-101' : 'RULE-100',
        severity: IssueSeverity.error,
        category: IssueCategory.prerequisite,
        title: allMissing
            ? 'تسجيل مادة دون أي من متطلباتها السابقة'
            : 'تسجيل مادة دون استيفاء متطلب سابق',
        description: 'المادة "${currCourse.courseNameAr}" (${record.rawCode}) '
            '${allMissing ? "تتطلب اجتياز متطلبات سابقة لم يستوفِها الطالب" : "تتطلب اجتياز"}: '
            '${missingNames.join("، ")}.',
        affectedCourseCode: record.rawCode,
        affectedCourseName: currCourse.courseNameAr,
        suggestion:
            'يجب التأكد من اجتياز ${missingNames.join("، ")} قبل تسجيل هذه المادة.',
      ));
    }

    return issues;
  }
}
