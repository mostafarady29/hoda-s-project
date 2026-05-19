// lib/domain/expert_system/rules/duplicate_rule.dart
//
// RULE-001: تكرار تسجيل مادة ناجحة
// RULE-002: إعادة تسجيل مادة راسب (مسموح - تحذير فقط)
// RULE-003: اجتياز مادتين اختياريتين متعارضتين (conflict_with)

import '../../entities/academic_issue.dart';
import '../engine/fact_manager.dart';
import 'base_rule.dart';

class DuplicateRule extends BaseRule {
  const DuplicateRule();

  @override
  List<AcademicIssue> evaluate(StudentFacts facts) {
    final issues = <AcademicIssue>[];

    for (final entry in facts.recordsByNormalizedCode.entries) {
      final code = entry.key;
      final records = entry.value;

      if (records.length < 2) continue;

      final passedOccurrences =
          records.where((r) => r.isActuallyPassed).toList();
      final failedOccurrences =
          records.where((r) => !r.isActuallyPassed).toList();

      // RULE-001: نجح في المادة أكثر من مرة
      if (passedOccurrences.length >= 2) {
        issues.add(AcademicIssue(
          ruleId: 'RULE-001',
          severity: IssueSeverity.error,
          category: IssueCategory.duplication,
          title: 'تكرار تسجيل مادة ناجحة',
          description:
              'المادة "${records.first.courseName}" (${records.first.rawCode}) '
              'مسجلة ومجتازة ${passedOccurrences.length} مرات. '
              'يُحسب للطالب فائض في الساعات المعتمدة.',
          affectedCourseCode: records.first.rawCode,
          affectedCourseName: records.first.courseName,
          suggestion:
              'يجب إلغاء تسجيل الساعات الزائدة وإحلال مادة أخرى مكانها.',
        ));
        continue;
      }

      // RULE-002: راسب في المادة أكثر من مرة (تحذير فقط - مسموح)
      if (passedOccurrences.isEmpty && failedOccurrences.length >= 2) {
        issues.add(AcademicIssue(
          ruleId: 'RULE-002',
          severity: IssueSeverity.warning,
          category: IssueCategory.duplication,
          title: 'إعادة تسجيل مادة راسب',
          description:
              'المادة "${records.first.courseName}" (${records.first.rawCode}) '
              'مسجلة ${failedOccurrences.length} مرات والطالب راسب في جميعها. '
              'هذا مسموح به لكنه يستحق المتابعة.',
          affectedCourseCode: records.first.rawCode,
          affectedCourseName: records.first.courseName,
          suggestion: 'تابع الطالب وتأكد من حضوره وفهمه للمادة.',
        ));
      }
    }

    // RULE-003: اجتياز مادتين متعارضتين (conflict_with في اللائحة)
    issues.addAll(_checkElectiveConflicts(facts));

    return issues;
  }

  List<AcademicIssue> _checkElectiveConflicts(StudentFacts facts) {
    final issues = <AcademicIssue>[];
    final checked = <String>{};

    for (final record in facts.passedRecords) {
      final currCourse = facts.curriculum.findByCourseCode(record.rawCode);
      if (currCourse == null || currCourse.conflictWith.isEmpty) continue;

      for (final conflictCode in currCourse.conflictWith) {
        final conflictNorm = conflictCode.toString();
        final pairKey = [record.normalizedCode, conflictNorm]..sort();
        final pairId = pairKey.join('_');
        if (checked.contains(pairId)) continue;
        checked.add(pairId);

        // هل الطالب نجح في المادة المتعارضة أيضاً؟
        final conflictPassed = facts.passedRecords.any((r) =>
            r.normalizedCode.contains(conflictNorm) ||
            conflictNorm.contains(r.normalizedCode));

        if (conflictPassed) {
          // ابحث عن اسم المادة المتعارضة
          final conflictCourse = facts.curriculum.courses.firstWhere(
            (c) =>
                c.courseCode.contains(conflictNorm) ||
                c.equivalentCodes.any((e) => e.contains(conflictNorm)),
            orElse: () => currCourse,
          );

          issues.add(AcademicIssue(
            ruleId: 'RULE-003',
            severity: IssueSeverity.error,
            category: IssueCategory.elective,
            title: 'اجتياز مادتين اختياريتين متعارضتين',
            description: 'الطالب اجتاز "${currCourse.courseNameAr}" '
                'و"${conflictCourse.courseNameAr}" معاً، '
                'وهما متعارضتان في اللائحة (لا يُسمح باجتياز الاثنتين). '
                'يُحتسب له فقط إحداهما.',
            affectedCourseCode: record.rawCode,
            affectedCourseName: record.courseName,
            suggestion:
                'يجب مراجعة السجل وحذف إحدى المادتين من الساعات المحتسبة.',
          ));
        }
      }
    }

    return issues;
  }
}
