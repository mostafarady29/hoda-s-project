// lib/features/academic_advisor/presentation/screens/student_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/student.dart';
import '../../../../features/data_import/presentation/cubit/student_cubit.dart';

class StudentProfileScreen extends StatefulWidget {
  final String jobId;
  final String studentId;

  const StudentProfileScreen({
    super.key,
    required this.jobId,
    required this.studentId,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late Future<Student> _studentFuture;

  @override
  void initState() {
    super.initState();
    _loadStudent();
  }

  Future<void> _loadStudent() async {
    final cubit = context.read<StudentCubit>();
    await cubit.loadStudentDetail(widget.jobId, widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف الطالب'),
      ),
      body: BlocBuilder<StudentCubit, StudentState>(
        builder: (context, state) {
          if (state is StudentDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentDetailLoaded) {
            final student = state.student;
            return _StudentDetailContent(student: student);
          }
          if (state is StudentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStudent,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _StudentDetailContent extends StatelessWidget {
  final Student student;

  const _StudentDetailContent({required this.student});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('الرقم الجامعي: ${student.id}'),
                  Text('القسم: ${student.department}'),
                  Text('المستوى: ${student.studyLevel}'),
                  Text('النسبة المئوية: ${student.cumulativePercentage}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'الفصول الدراسية',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...student.semesters.map((semester) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ExpansionTile(
                  title: Text(semester.levelSemester),
                  subtitle: Text(
                      'السنة: ${semester.academicYear} | GPA: ${semester.gpa}'),
                  children: semester.courses
                      .map((course) => ListTile(
                            title: Text(course.courseName),
                            subtitle: Text(
                                'الكود: ${course.courseCode} | الساعات: ${course.hours}'),
                            trailing: Text(
                              course.gradeLetter,
                              style: TextStyle(
                                color:
                                    course.isPassed ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              )),
        ],
      ),
    );
  }
}
