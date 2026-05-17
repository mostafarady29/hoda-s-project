// ===== File: lib/core/services/storage/hive_storage_service.dart =====
//
// Hive-based local persistence.
// بيخزن بيانات الطلاب والـ jobs محلياً للـ offline mode.
//
// Boxes المستخدمة:
//   'jobs'     → ImportStatusModel  (آخر الـ jobs المرفوعة)
//   'students' → ImportedJsonRecord (بيانات الطلاب بعد الجلب)
//   'settings' → dynamic            (إعدادات التطبيق)
//
// pubspec.yaml لازم يحتوي:
//   hive: ^2.2.3
//   hive_flutter: ^1.1.0

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/models/import_status_model.dart';
import '../../../data/models/imported_json_record.dart';

class HiveStorageService {
  static const String _jobsBox = 'acadexa_jobs';
  static const String _studentsBox = 'acadexa_students';
  static const String _settingsBox = 'acadexa_settings';

  // Singleton
  HiveStorageService._();
  static final HiveStorageService _instance = HiveStorageService._();
  static HiveStorageService get instance => _instance;

  bool _initialized = false;

  // ─────────────────────────────────────────────
  // Init
  // ─────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(_jobsBox),
      Hive.openBox(_studentsBox),
      Hive.openBox(_settingsBox),
    ]);
    _initialized = true;
  }

  void _ensureInit() {
    if (!_initialized) {
      throw StateError(
          'HiveStorageService not initialized. Call init() first.');
    }
  }

  // ─────────────────────────────────────────────
  // Jobs
  // ─────────────────────────────────────────────

  /// حفظ أو تحديث job
  Future<void> saveJob(ImportStatusModel job) async {
    _ensureInit();
    final box = Hive.box(_jobsBox);
    await box.put(job.jobId, jsonEncode(job.toJson()));
  }

  /// جلب job بالـ ID
  ImportStatusModel? getJob(String jobId) {
    _ensureInit();
    final box = Hive.box(_jobsBox);
    final raw = box.get(jobId) as String?;
    if (raw == null) return null;
    try {
      return ImportStatusModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// كل الـ jobs المحفوظة مرتبة من الأحدث
  List<ImportStatusModel> getAllJobs() {
    _ensureInit();
    final box = Hive.box(_jobsBox);
    final jobs = <ImportStatusModel>[];
    for (final key in box.keys) {
      final raw = box.get(key) as String?;
      if (raw == null) continue;
      try {
        jobs.add(ImportStatusModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    // Sort newest first
    jobs.sort((a, b) => (b.updatedAt ?? '').compareTo(a.updatedAt ?? ''));
    return jobs;
  }

  Future<void> deleteJob(String jobId) async {
    _ensureInit();
    final box = Hive.box(_jobsBox);
    await box.delete(jobId);
  }

  Future<void> clearAllJobs() async {
    _ensureInit();
    await Hive.box(_jobsBox).clear();
  }

  // ─────────────────────────────────────────────
  // Students
  // ─────────────────────────────────────────────

  /// مفتاح التخزين: jobId + studentId
  String _studentKey(String jobId, String studentId) => '${jobId}__$studentId';

  Future<void> saveStudent(String jobId, ImportedJsonRecord record) async {
    _ensureInit();
    final box = Hive.box(_studentsBox);
    final key = _studentKey(jobId, record.student.id);
    await box.put(key, jsonEncode(record.toJson()));
  }

  ImportedJsonRecord? getStudent(String jobId, String studentId) {
    _ensureInit();
    final box = Hive.box(_studentsBox);
    final raw = box.get(_studentKey(jobId, studentId)) as String?;
    if (raw == null) return null;
    try {
      return ImportedJsonRecord.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// هل الطالب ده محفوظ locally ؟
  bool hasStudent(String jobId, String studentId) {
    _ensureInit();
    return Hive.box(_studentsBox).containsKey(_studentKey(jobId, studentId));
  }

  Future<void> saveStudentsBatch(
      String jobId, List<ImportedJsonRecord> records) async {
    _ensureInit();
    final box = Hive.box(_studentsBox);
    final entries = {
      for (final r in records)
        _studentKey(jobId, r.student.id): jsonEncode(r.toJson())
    };
    await box.putAll(entries);
  }

  /// كل الطلاب الخاصين بـ job معين
  List<ImportedJsonRecord> getStudentsByJob(String jobId) {
    _ensureInit();
    final box = Hive.box(_studentsBox);
    final prefix = '${jobId}__';
    final results = <ImportedJsonRecord>[];
    for (final key in box.keys) {
      if (key.toString().startsWith(prefix)) {
        final raw = box.get(key) as String?;
        if (raw == null) continue;
        try {
          results.add(ImportedJsonRecord.fromJson(
              jsonDecode(raw) as Map<String, dynamic>));
        } catch (_) {}
      }
    }
    return results;
  }

  Future<void> deleteStudentsByJob(String jobId) async {
    _ensureInit();
    final box = Hive.box(_studentsBox);
    final prefix = '${jobId}__';
    final keys =
        box.keys.where((k) => k.toString().startsWith(prefix)).toList();
    await box.deleteAll(keys);
  }

  Future<void> clearAllStudents() async {
    _ensureInit();
    await Hive.box(_studentsBox).clear();
  }

  // ─────────────────────────────────────────────
  // Settings  (key-value generic store)
  // ─────────────────────────────────────────────

  Future<void> saveSetting(String key, dynamic value) async {
    _ensureInit();
    await Hive.box(_settingsBox).put(key, value);
  }

  T? getSetting<T>(String key, {T? defaultValue}) {
    _ensureInit();
    final v = Hive.box(_settingsBox).get(key);
    if (v == null) return defaultValue;
    if (v is T) return v;
    return defaultValue;
  }

  Future<void> deleteSetting(String key) async {
    _ensureInit();
    await Hive.box(_settingsBox).delete(key);
  }

  // ─────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────

  /// مسح كل البيانات (logout / reset)
  Future<void> clearAll() async {
    _ensureInit();
    await Future.wait([
      Hive.box(_jobsBox).clear(),
      Hive.box(_studentsBox).clear(),
      Hive.box(_settingsBox).clear(),
    ]);
  }

  Future<void> close() async {
    if (!_initialized) return;
    await Hive.close();
    _initialized = false;
  }
}
