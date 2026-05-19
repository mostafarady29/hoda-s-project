// lib/domain/usecases/analyze_student.dart
//
// Use case رئيسي: يحدد اللائحة المناسبة للطالب ثم يشغّل النظام الخبير

import '../entities/analysis_result.dart';
import '../entities/student.dart';
import '../expert_system/engine/inference_engine.dart';
import '../../data/models/study_plan_model.dart';

/// واجهة لتحميل اللوائح (يُنفَّذ في data layer)
abstract class CurriculumRepository {
  /// تحميل لائحة بالـ ID
  Future<StudyPlanModel?> loadCurriculum(String curriculumId);

  /// تحميل لائحة من مسار محدد
  Future<StudyPlanModel?> loadCurriculumFromPath(String path);

  /// كل اللوائح المتاحة
  Future<List<StudyPlanModel>> loadAllCurricula();
}

class AnalyzeStudentUseCase {
  final CurriculumRepository _curriculumRepo;
  final InferenceEngine _engine;

  const AnalyzeStudentUseCase({
    required CurriculumRepository curriculumRepository,
    InferenceEngine? engine,
  })  : _curriculumRepo = curriculumRepository,
        _engine = engine ?? const InferenceEngine();

  /// تحليل طالب واحد — يختار اللائحة تلقائياً
  Future<AnalysisResult> call(Student student,
      {String? forceCurriculumId}) async {
    final curriculum = forceCurriculumId != null
        ? await _curriculumRepo.loadCurriculum(forceCurriculumId)
        : await _detectCurriculum(student);

    if (curriculum == null) {
      throw Exception('لم يتم العثور على لائحة مناسبة للطالب ${student.name}');
    }

    return _engine.analyze(student, curriculum);
  }

  /// تحليل قائمة طلاب (نفس اللائحة لكلهم — مثلاً ورك بوك قسم واحد)
  Future<List<AnalysisResult>> analyzeAll(
    List<Student> students, {
    required String curriculumId,
  }) async {
    final curriculum = await _curriculumRepo.loadCurriculum(curriculumId);
    if (curriculum == null) {
      throw Exception('لائحة غير موجودة: $curriculumId');
    }
    return _engine.analyzeAll(students, curriculum);
  }

  // ── تحديد اللائحة المناسبة للطالب تلقائياً
  Future<StudyPlanModel?> _detectCurriculum(Student student) async {
    // 1. نأخذ أول فصل دراسي لتحديد البرنامج
    if (student.semesters.isEmpty) return null;

    final firstSemester = student.semesters.first;
    final deptName = firstSemester.department.toLowerCase();
    final studentDept = student.department.toLowerCase();

    // 2. هل هو برنامج مميز (حاسب إنجليزي)؟
    if (deptName.contains('حاسب') ||
        deptName.contains('حاسوب') ||
        deptName.contains('computer') ||
        studentDept.contains('tech')) {
      return await _curriculumRepo.loadCurriculum('cs_english');
    }

    // 3. هل هو برنامج مميز (فنون رقمية)؟
    if (deptName.contains('فنية رقمية') ||
        deptName.contains('رقمية') ||
        deptName.contains('digital')) {
      return await _curriculumRepo.loadCurriculum('digital_art');
    }

    // 4. قسم عادي - نحدد السنة والملف المناسب
    final admissionYear = _extractAdmissionYear(student);
    final yearFolder = admissionYear >= 2024 ? '2024' : '2019';

    // تحديد اسم الملف حسب القسم
    String fileName = _getDepartmentFileName(studentDept);

    // بناء المسار الكامل
    final path = 'assets/plans/$yearFolder/$fileName';

    return await _curriculumRepo.loadCurriculumFromPath(path);
  }

  /// استخراج سنة الالتحاق من أول فصل دراسي
  int _extractAdmissionYear(Student student) {
    if (student.semesters.isEmpty) return 2021;
    final firstYear = student.semesters.first.academicYear;
    // "2021-2022" → 2021
    final parts = firstYear.split(RegExp(r'[-/]'));
    if (parts.isNotEmpty) {
      return int.tryParse(parts.first.trim()) ?? 2021;
    }
    return 2021;
  }

  /// تحديد اسم ملف JSON حسب اسم القسم
  String _getDepartmentFileName(String department) {
    final dept = department.toLowerCase();

    if (dept.contains('فنية') || dept.contains('arts')) {
      return 'arts.json';
    }
    if (dept.contains('موسيقية') || dept.contains('music')) {
      return 'music.json';
    }
    if (dept.contains('إعلام') || dept.contains('media')) {
      return 'media.json';
    }
    if (dept.contains('اقتصاد') || dept.contains('home')) {
      return 'home_eco.json';
    }
    // default: تكنولوجيا التعليم
    return 'tech_edu.json';
  }
}
