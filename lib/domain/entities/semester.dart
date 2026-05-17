import 'package:equatable/equatable.dart';
import 'course.dart';

class Semester extends Equatable {
  final String department;
  final String levelSemester;
  final String academicYear;
  final int totalPassedHours;
  final double gpa;
  final String grade;
  final int semesterHours;
  final double semesterGpa;
  final int levelHours;
  final double levelGpa;
  final List<Course> courses;

  const Semester({
    required this.department,
    required this.levelSemester,
    required this.academicYear,
    required this.totalPassedHours,
    required this.gpa,
    required this.grade,
    required this.semesterHours,
    required this.semesterGpa,
    required this.levelHours,
    required this.levelGpa,
    required this.courses,
  });

  factory Semester.empty() => const Semester(
        department: '',
        levelSemester: '',
        academicYear: '',
        totalPassedHours: 0,
        gpa: 0.0,
        grade: '',
        semesterHours: 0,
        semesterGpa: 0.0,
        levelHours: 0,
        levelGpa: 0.0,
        courses: [],
      );

  Semester copyWith({
    String? department,
    String? levelSemester,
    String? academicYear,
    int? totalPassedHours,
    double? gpa,
    String? grade,
    int? semesterHours,
    double? semesterGpa,
    int? levelHours,
    double? levelGpa,
    List<Course>? courses,
  }) {
    return Semester(
      department: department ?? this.department,
      levelSemester: levelSemester ?? this.levelSemester,
      academicYear: academicYear ?? this.academicYear,
      totalPassedHours: totalPassedHours ?? this.totalPassedHours,
      gpa: gpa ?? this.gpa,
      grade: grade ?? this.grade,
      semesterHours: semesterHours ?? this.semesterHours,
      semesterGpa: semesterGpa ?? this.semesterGpa,
      levelHours: levelHours ?? this.levelHours,
      levelGpa: levelGpa ?? this.levelGpa,
      courses: courses ?? this.courses,
    );
  }

  List<Course> get passedCourses =>
      courses.where((course) => course.isPassed).toList();

  List<Course> get failedCourses =>
      courses.where((course) => !course.isPassed).toList();

  int get passedHours =>
      passedCourses.fold(0, (sum, course) => sum + course.hours);

  int get failedHours =>
      failedCourses.fold(0, (sum, course) => sum + course.hours);

  bool get hasFailures => failedCourses.isNotEmpty;

  @override
  List<Object?> get props => [
        department,
        levelSemester,
        academicYear,
        totalPassedHours,
        gpa,
        grade,
        semesterHours,
        semesterGpa,
        levelHours,
        levelGpa,
        courses,
      ];
}
