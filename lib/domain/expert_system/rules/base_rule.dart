// lib/domain/expert_system/rules/base_rule.dart

import '../../entities/academic_issue.dart';
import '../engine/fact_manager.dart';

abstract class BaseRule {
  const BaseRule();

  /// تشغيل القاعدة وإرجاع قائمة المشكلات (أو قائمة فارغة)
  List<AcademicIssue> evaluate(StudentFacts facts);
}
