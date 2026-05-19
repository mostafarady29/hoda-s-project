// lib/domain/expert_system/rules/gpa_warning_rule.dart
//
// RULE-300: GPA < 2.0 → إنذار أكاديمي
// RULE-301: GPA < 1.0 → فصل أكاديمي محتمل

import '../../entities/academic_issue.dart';
import '../engine/fact_manager.dart';
import 'base_rule.dart';

class GpaWarningRule extends BaseRule {
  const GpaWarningRule();

  @override
  List<AcademicIssue> evaluate(StudentFacts facts) {
    final issues = <AcademicIssue>[];
    final gpa = facts.student.latestGpa;

    if (gpa <= 0) return issues; // لا يوجد GPA بعد

    if (gpa < 1.0) {
      issues.add(AcademicIssue(
        ruleId: 'RULE-301',
        severity: IssueSeverity.error,
        category: IssueCategory.gpa,
        title: 'معدل تراكمي خطير — فصل أكاديمي محتمل',
        description: 'المعدل التراكمي للطالب ${gpa.toStringAsFixed(2)} '
            'وهو أقل من 1.0. الطالب في خطر الفصل الأكاديمي.',
        suggestion: 'يجب تدخل عاجل من المرشد الأكاديمي ومتابعة الطالب فورياً.',
      ));
    } else if (gpa < 2.0) {
      issues.add(AcademicIssue(
        ruleId: 'RULE-300',
        severity: IssueSeverity.warning,
        category: IssueCategory.gpa,
        title: 'معدل تراكمي أقل من الحد الأدنى — إنذار أكاديمي',
        description: 'المعدل التراكمي للطالب ${gpa.toStringAsFixed(2)} '
            'وهو أقل من 2.0. الطالب في وضع إنذار أكاديمي.',
        suggestion: 'يحتاج الطالب لمتابعة مكثفة وتحسين أداءه في الفصل القادم.',
      ));
    }

    return issues;
  }
}
