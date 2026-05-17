import 'package:equatable/equatable.dart';

class Course extends Equatable {
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

  const Course({
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

  factory Course.empty() => const Course(
        seq: '',
        courseCode: '',
        courseName: '',
        isPassed: false,
        gradeLetter: '',
        score: 0.0,
        hours: 0,
        points: 0.0,
        cumulative: '',
        minScore: 0.0,
        maxScore: 0.0,
      );

  Course copyWith({
    String? seq,
    String? courseCode,
    String? courseName,
    bool? isPassed,
    String? gradeLetter,
    double? score,
    int? hours,
    double? points,
    String? cumulative,
    double? minScore,
    double? maxScore,
  }) {
    return Course(
      seq: seq ?? this.seq,
      courseCode: courseCode ?? this.courseCode,
      courseName: courseName ?? this.courseName,
      isPassed: isPassed ?? this.isPassed,
      gradeLetter: gradeLetter ?? this.gradeLetter,
      score: score ?? this.score,
      hours: hours ?? this.hours,
      points: points ?? this.points,
      cumulative: cumulative ?? this.cumulative,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
    );
  }

  bool get isFailed => !isPassed;
  bool get hasValidCode => courseCode.trim().isNotEmpty;
  bool get isGraded => score > 0;
  bool get isRetakeCandidate => !isPassed && hasValidCode;
  double get scorePercentage {
    if (maxScore <= minScore) return score;
    return ((score - minScore) / (maxScore - minScore)) * 100;
  }

  @override
  List<Object?> get props => [
        seq,
        courseCode,
        courseName,
        isPassed,
        gradeLetter,
        score,
        hours,
        points,
        cumulative,
        minScore,
        maxScore,
      ];
}
