// ===== File: lib/features/data_import/presentation/cubit/student_cubit.dart =====

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../domain/entities/student.dart';
import '../../../../domain/usecases/get_student_detail.dart';
import '../../../../data/models/student_index_model.dart';

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────
sealed class StudentState extends Equatable {
  const StudentState();
  @override
  List<Object?> get props => [];
}

class StudentInitial extends StudentState {
  const StudentInitial();
}

class StudentsListLoaded extends StudentState {
  final String jobId;
  final StudentIndexModel index;
  final String searchQuery;

  const StudentsListLoaded({
    required this.jobId,
    required this.index,
    this.searchQuery = '',
  });

  List<StudentIndexItemModel> get filtered {
    if (searchQuery.isEmpty) return index.students;
    final q = searchQuery.toLowerCase();
    return index.students
        .where(
            (s) => s.name.toLowerCase().contains(q) || s.studentId.contains(q))
        .toList();
  }

  @override
  List<Object?> get props => [jobId, index, searchQuery];
}

class StudentDetailLoading extends StudentState {
  final String studentId;
  const StudentDetailLoading({required this.studentId});
  @override
  List<Object?> get props => [studentId];
}

class StudentDetailLoaded extends StudentState {
  final Student student;
  const StudentDetailLoaded({required this.student});
  @override
  List<Object?> get props => [student.id];
}

class StudentError extends StudentState {
  final String message;
  const StudentError({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────
class StudentCubit extends Cubit<StudentState> {
  final GetStudentDetailUseCase _getStudentDetail;

  StudentCubit({required GetStudentDetailUseCase getStudentDetail})
      : _getStudentDetail = getStudentDetail,
        super(const StudentInitial());

  /// تحميل قائمة الطلاب بعد اكتمال الرفع
  void loadStudentsList(String jobId, StudentIndexModel index) {
    emit(StudentsListLoaded(jobId: jobId, index: index));
  }

  /// تصفية الطلاب بالاسم أو الرقم
  void search(String query) {
    final current = state;
    if (current is StudentsListLoaded) {
      emit(StudentsListLoaded(
        jobId: current.jobId,
        index: current.index,
        searchQuery: query,
      ));
    }
  }

  /// تحميل تفاصيل طالب واحد
  Future<void> loadStudentDetail(String jobId, String studentId) async {
    emit(StudentDetailLoading(studentId: studentId));
    try {
      final student = await _getStudentDetail(jobId, studentId);
      emit(StudentDetailLoaded(student: student));
    } catch (e) {
      emit(StudentError(message: e.toString()));
    }
  }

  /// رجوع لقائمة الطلاب
  void backToList(String jobId, StudentIndexModel index) {
    emit(StudentsListLoaded(jobId: jobId, index: index));
  }
}
