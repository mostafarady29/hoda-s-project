// ===== File: lib/data/models/course_model.dart =====

import '../../domain/entities/course.dart';

class CourseModel {
  final String seq;
  final String courseCode;
  final String courseName;
  final bool isPassed;
  final String gradeLetter;
  final double score;
  final int hours;
  final double points;
  final String cumulative;
  final double minScore;
  final double maxScore;

  const CourseModel({
    required this.seq,
    required this.courseCode,
    required this.courseName,
    required this.isPassed,
    required this.gradeLetter,
    required this.score,
    required this.hours,
    required this.points,
    required this.cumulative,
    required this.minScore,
    required this.maxScore,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      seq: _s(json['seq']),
      courseCode: _s(json['course_code']),
      courseName: _s(json['course_name']),
      isPassed: _parsePassed(json['passed']),
      gradeLetter: _s(json['grade_letter']),
      score: _d(json['score']),
      hours: _i(json['hours']),
      points: _d(json['points']),
      cumulative: _s(json['cumulative']),
      minScore: _d(json['min_score']),
      maxScore: _d(json['max_score']),
    );
  }

  Map<String, dynamic> toJson() => {
        'seq': seq,
        'course_code': courseCode,
        'course_name': courseName,
        'passed': isPassed ? 'نعم' : 'لا',
        'grade_letter': gradeLetter,
        'score': score,
        'hours': hours,
        'points': points,
        'cumulative': cumulative,
        'min_score': minScore,
        'max_score': maxScore,
      };

  Course toEntity() => Course(
        seq: seq,
        courseCode: courseCode,
        courseName: courseName,
        isPassed: isPassed,
        gradeLetter: gradeLetter,
        score: score,
        hours: hours,
        points: points,
        cumulative: cumulative,
        minScore: minScore,
        maxScore: maxScore,
      );

  factory CourseModel.fromEntity(Course entity) => CourseModel(
        seq: entity.seq,
        courseCode: entity.courseCode,
        courseName: entity.courseName,
        isPassed: entity.isPassed,
        gradeLetter: entity.gradeLetter,
        score: entity.score,
        hours: entity.hours,
        points: entity.points,
        cumulative: entity.cumulative,
        minScore: entity.minScore,
        maxScore: entity.maxScore,
      );

  static String _s(dynamic v) => v?.toString().trim() ?? '';

  static int _i(dynamic v) =>
      v == null ? 0 : (int.tryParse(v.toString().trim()) ?? 0);

  static double _d(dynamic v) =>
      v == null ? 0.0 : (double.tryParse(v.toString().trim()) ?? 0.0);

  static bool _parsePassed(dynamic v) {
    final s = v?.toString().trim().toLowerCase() ?? '';
    if (s == 'نعم' || s == 'yes' || s == 'true' || s == '1') return true;
    if (s == 'راسب' || s == 'no' || s == 'false' || s == '0') return false;
    final num = double.tryParse(s);
    return num != null && num > 0;
  }
}
