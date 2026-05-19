// lib/domain/expert_system/rules/graduation_rule.dart
//
// RULE-200: إجمالي الساعات المجتازة أقل من الحد الأدنى
// RULE-201: الساعات الإجبارية غير مكتملة (بالفئة)
// RULE-202: الساعات الاختيارية غير مكتملة
// RULE-203: لم يجتز مادة قضايا مجتمعية (شرط تخرج)

import '../../entities/academic_issue.dart';
import '../engine/fact_manager.dart';
import 'base_rule.dart';

class GraduationRule extends BaseRule {
  const GraduationRule();

  @override
  List<AcademicIssue> evaluate(StudentFacts facts) {
    final issues = <AcademicIssue>[];
    final c = facts.curriculum;

    // RULE-200: الساعات الكلية
    if (facts.totalPassedHours < c.minGraduationHours) {
      final remaining = c.minGraduationHours - facts.totalPassedHours;
      issues.add(AcademicIssue(
        ruleId: 'RULE-200',
        severity: IssueSeverity.warning,
        category: IssueCategory.graduation,
        title: 'لم تستكمل الحد الأدنى لساعات التخرج',
        description: 'الطالب اجتاز ${facts.totalPassedHours} ساعة من أصل '
            '${c.minGraduationHours} ساعة مطلوبة. '
            'المتبقي: $remaining ساعة.',
        suggestion: 'يجب تسجيل $remaining ساعة معتمدة إضافية للتخرج.',
      ));
    }

    // RULE-201: إجباري الجامعة
    if (facts.passedUniversityRequired < c.totalUniversityRequired) {
      issues.add(_hoursIssue(
        'RULE-201',
        'إجباري الجامعة',
        facts.passedUniversityRequired,
        c.totalUniversityRequired,
      ));
    }

    // RULE-201: اختياري الجامعة
    if (facts.passedUniversityElective < c.totalUniversityElective) {
      issues.add(_hoursIssue(
        'RULE-201',
        'اختياري الجامعة',
        facts.passedUniversityElective,
        c.totalUniversityElective,
      ));
    }

    // RULE-201: إجباري الكلية
    if (facts.passedFacultyRequired < c.totalFacultyRequired) {
      issues.add(_hoursIssue(
        'RULE-201',
        'إجباري الكلية',
        facts.passedFacultyRequired,
        c.totalFacultyRequired,
      ));
    }

    // RULE-202: اختياري الكلية
    if (c.totalFacultyElective > 0 &&
        facts.passedFacultyElective < c.totalFacultyElective) {
      issues.add(_hoursIssue(
        'RULE-202',
        'اختياري الكلية',
        facts.passedFacultyElective,
        c.totalFacultyElective,
      ));
    }

    // RULE-201: إجباري التخصص
    if (facts.passedProgramRequired < c.totalProgramRequired) {
      issues.add(_hoursIssue(
        'RULE-201',
        'إجباري التخصص',
        facts.passedProgramRequired,
        c.totalProgramRequired,
      ));
    }

    // RULE-202: اختياري التخصص
    if (facts.passedProgramElective < c.totalProgramElective) {
      issues.add(_hoursIssue(
        'RULE-202',
        'اختياري التخصص',
        facts.passedProgramElective,
        c.totalProgramElective,
      ));
    }

    // RULE-203: قضايا مجتمعية
    if (!facts.passedSocialCourse) {
      issues.add(const AcademicIssue(
        ruleId: 'RULE-203',
        severity: IssueSeverity.error,
        category: IssueCategory.graduation,
        title: 'لم يجتز مادة قضايا مجتمعية',
        description:
            'مادة "القضايا المجتمعية" شرط أساسي للتخرج ولا تُحتسب في الـ GPA. '
            'الطالب لم يجتزها بعد.',
        suggestion:
            'يجب تسجيل مادة القضايا المجتمعية (كود 60350) والنجاح فيها.',
      ));
    }

    return issues;
  }

  AcademicIssue _hoursIssue(
    String ruleId,
    String category,
    int achieved,
    int required,
  ) {
    final remaining = required - achieved;
    return AcademicIssue(
      ruleId: ruleId,
      severity: IssueSeverity.warning,
      category: IssueCategory.creditHours,
      title: 'ساعات $category غير مكتملة',
      description:
          'الطالب اجتاز $achieved ساعة من أصل $required ساعة مطلوبة في $category. '
          'المتبقي: $remaining ساعة.',
      suggestion: 'يجب تسجيل $remaining ساعة إضافية من مجموعة $category.',
    );
  }
}
