// ===== File: lib/features/data_import/presentation/cubit/upload_cubit.dart =====

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../domain/usecases/upload_excel.dart';
import '../../../../domain/usecases/get_job_status.dart';
import '../../../../domain/usecases/get_students_index.dart';
import '../../../../data/models/import_status_model.dart';
import '../../../../data/models/student_index_model.dart';

// ─────────────────────────────────────────────
// States
// ─────────────────────────────────────────────
sealed class UploadState extends Equatable {
  const UploadState();
  @override
  List<Object?> get props => [];
}

class UploadInitial extends UploadState {
  const UploadInitial();
}

class UploadInProgress extends UploadState {
  const UploadInProgress();
}

class UploadPolling extends UploadState {
  final String jobId;
  final ImportStatusModel status;
  final int waitingTimeSeconds; // ✅ جديد: وقت الانتظار بالثواني

  const UploadPolling({
    required this.jobId,
    required this.status,
    this.waitingTimeSeconds = 0,
  });

  @override
  List<Object?> get props => [jobId, status.status, waitingTimeSeconds];
}

class UploadCompleted extends UploadState {
  final String jobId;
  final StudentIndexModel index;
  const UploadCompleted({required this.jobId, required this.index});
  @override
  List<Object?> get props => [jobId];
}

class UploadFailure extends UploadState {
  final String message;
  const UploadFailure({required this.message});
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────
// Cubit
// ─────────────────────────────────────────────
class UploadCubit extends Cubit<UploadState> {
  final UploadExcelUseCase _uploadExcel;
  final GetJobStatusUseCase _getJobStatus;
  final GetStudentsIndexUseCase _getStudentsIndex;

  // ✅ زيادة الوقت للمعالجة الطويلة (30 دقيقة)
  static const Duration _pollInterval =
      Duration(seconds: 3); // 2s → 3s (أقل ضغط)
  static const Duration _timeout = Duration(minutes: 30); // 10m → 30 دقيقة

  Timer? _pollTimer;
  DateTime? _startTime;
  String? _currentJobId;

  UploadCubit({
    required UploadExcelUseCase uploadExcel,
    required GetJobStatusUseCase getJobStatus,
    required GetStudentsIndexUseCase getStudentsIndex,
  })  : _uploadExcel = uploadExcel,
        _getJobStatus = getJobStatus,
        _getStudentsIndex = getStudentsIndex,
        super(const UploadInitial());

  // ── Cross-platform file picker + upload
  Future<void> pickAndUpload(String department) async {
    if (state is UploadInProgress || state is UploadPolling) return;

    try {
      // 1. Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null) return;

      final pickedFile = result.files.first;

      // 2. Check file size (50MB max)
      if (pickedFile.size > 50 * 1024 * 1024) {
        emit(const UploadFailure(
            message: 'حجم الملف كبير جداً (الحد الأقصى 50 MB)'));
        return;
      }

      // 3. Upload based on platform
      emit(const UploadInProgress());

      String jobId;

      if (kIsWeb) {
        if (pickedFile.bytes == null) {
          emit(const UploadFailure(message: 'فشل قراءة الملف على المتصفح'));
          return;
        }
        jobId = await _uploadExcel.fromBytes(pickedFile.bytes!, department);
      } else {
        if (pickedFile.path == null) {
          emit(const UploadFailure(message: 'فشل قراءة مسار الملف'));
          return;
        }
        final file = File(pickedFile.path!);
        jobId = await _uploadExcel(file, department);
      }

      _currentJobId = jobId;
      _startTime = DateTime.now();
      _startPolling(jobId);
    } catch (e) {
      emit(UploadFailure(message: e.toString()));
    }
  }

  // ── Legacy method (keep for compatibility)
  Future<void> upload(File file, String department) async {
    if (state is UploadInProgress || state is UploadPolling) return;

    emit(const UploadInProgress());

    try {
      final jobId = await _uploadExcel(file, department);
      _currentJobId = jobId;
      _startTime = DateTime.now();
      _startPolling(jobId);
    } catch (e) {
      emit(UploadFailure(message: e.toString()));
    }
  }

  // ── Polling loop via Timer
  void _startPolling(String jobId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll(jobId));
  }

  Future<void> _poll(String jobId) async {
    // ✅ حساب وقت الانتظار
    final waitingSeconds = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : 0;

    // ✅ Timeout check بعد 30 دقيقة
    if (_startTime != null &&
        DateTime.now().difference(_startTime!) > _timeout) {
      _stopPolling();
      final minutes = _timeout.inMinutes;
      emit(UploadFailure(
        message:
            'انتهت مهلة الانتظار ($minutes دقيقة). الملف كبير جداً أو الخادم بطيء جداً.',
      ));
      return;
    }

    try {
      final status = await _getJobStatus(jobId);

      if (status.isDone) {
        _stopPolling();
        await _fetchIndex(jobId);
        return;
      }

      if (status.isFailed) {
        _stopPolling();
        emit(UploadFailure(
          message: status.errorLog.isNotEmpty
              ? status.errorLog.join('\n')
              : 'فشلت المعالجة بعد ${(waitingSeconds / 60).floor()} دقيقة',
        ));
        return;
      }

      // ✅ Still running - emit مع وقت الانتظار
      if (!isClosed) {
        emit(UploadPolling(
          jobId: jobId,
          status: status,
          waitingTimeSeconds: waitingSeconds,
        ));
      }
    } catch (_) {
      // Network hiccup — keep polling (don't emit error)
    }
  }

  Future<void> _fetchIndex(String jobId) async {
    try {
      final index = await _getStudentsIndex(jobId);
      if (!isClosed) emit(UploadCompleted(jobId: jobId, index: index));
    } catch (e) {
      if (!isClosed) emit(UploadFailure(message: e.toString()));
    }
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void reset() {
    _stopPolling();
    _currentJobId = null;
    emit(const UploadInitial());
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}
