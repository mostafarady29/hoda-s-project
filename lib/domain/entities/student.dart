import 'package:equatable/equatable.dart';
import 'semester.dart';
import 'course.dart';

class Student extends Equatable {
  final String id;
  final String name;
  final String studyLevel;
  final String department;
  final String cumulativePercentage;
  final List<Semester> semesters;
  final String? parsedAt;
  final String? sheetName;

  const Student({
    required this.id,
    required this.name,
    required this.studyLevel,
    required this.department,
    required this.cumulativePercentage,
    required this.semesters,
    this.parsedAt,
    this.sheetName,
  });

  factory Student.empty() => const Student(
        id: '',
        name: '',
        studyLevel: '',
        department: '',
        cumulativePercentage: '',
        semesters: [],
        parsedAt: null,
        sheetName: null,
      );

  Student copyWith({
    String? id,
    String? name,
    String? studyLevel,
    String? department,
    String? cumulativePercentage,
    List<Semester>? semesters,
    String? parsedAt,
    String? sheetName,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      studyLevel: studyLevel ?? this.studyLevel,
      department: department ?? this.department,
      cumulativePercentage: cumulativePercentage ?? this.cumulativePercentage,
      semesters: semesters ?? this.semesters,
      parsedAt: parsedAt ?? this.parsedAt,
      sheetName: sheetName ?? this.sheetName,
    );
  }

  List<Course> get allCourses =>
      semesters.expand((semester) => semester.courses).toList();

  List<Course> get passedCourses =>
      allCourses.where((course) => course.isPassed).toList();

  List<Course> get failedCourses =>
      allCourses.where((course) => !course.isPassed).toList();

  Set<String> get passedCourseCodes =>
      passedCourses.map((course) => course.courseCode).toSet();

  int get totalPassedHours =>
      passedCourses.fold(0, (sum, course) => sum + course.hours);

  double get latestGpa => semesters.isNotEmpty ? semesters.last.gpa : 0.0;

  Semester? get latestSemester => semesters.isNotEmpty ? semesters.last : null;

  bool get hasAcademicRisk => failedCourses.isNotEmpty || latestGpa < 2.0;

  @override
  List<Object?> get props => [
        id,
        name,
        studyLevel,
        department,
        cumulativePercentage,
        semesters,
        parsedAt,
        sheetName,
      ];
}
