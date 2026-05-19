// lib/domain/entities/academic_issue.dart
//
// يمثّل مشكلة أكاديمية اكتشفها النظام الخبير

enum IssueSeverity { error, warning, info }

enum IssueCategory {
  duplication, // تكرار المواد
  prerequisite, // متطلبات سابقة
  graduation, // متطلبات التخرج
  gpa, // المعدل التراكمي
  creditHours, // الساعات المعتمدة
  elective, // المواد الاختيارية
}

class AcademicIssue {
  final String ruleId; // e.g. "RULE-001"
  final IssueSeverity severity;
  final IssueCategory category;
  final String title; // العنوان المختصر
  final String description; // الوصف التفصيلي
  final String? affectedCourseCode;
  final String? affectedCourseName;
  final String? suggestion; // اقتراح الحل

  const AcademicIssue({
    required this.ruleId,
    required this.severity,
    required this.category,
    required this.title,
    required this.description,
    this.affectedCourseCode,
    this.affectedCourseName,
    this.suggestion,
  });

  bool get isError => severity == IssueSeverity.error;
  bool get isWarning => severity == IssueSeverity.warning;
  bool get isInfo => severity == IssueSeverity.info;

  String get severityLabel {
    switch (severity) {
      case IssueSeverity.error:
        return 'خطأ';
      case IssueSeverity.warning:
        return 'تحذير';
      case IssueSeverity.info:
        return 'معلومة';
    }
  }

  String get categoryLabel {
    switch (category) {
      case IssueCategory.duplication:
        return 'تكرار';
      case IssueCategory.prerequisite:
        return 'متطلبات سابقة';
      case IssueCategory.graduation:
        return 'متطلبات التخرج';
      case IssueCategory.gpa:
        return 'المعدل';
      case IssueCategory.creditHours:
        return 'الساعات';
      case IssueCategory.elective:
        return 'اختيارية';
    }
  }

  @override
  String toString() => '[$ruleId] $severityLabel: $title';
}
