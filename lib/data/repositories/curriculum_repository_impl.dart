// lib/data/repositories/curriculum_repository_impl.dart
//
// يحمّل اللوائح من assets/plans/*.json
// (مش محتاجة إنترنت أو باك اند)

import 'dart:convert';
import 'package:flutter/services.dart';

import '../../data/models/study_plan_model.dart';
import '../../domain/usecases/analyze_student.dart';

class CurriculumRepositoryImpl implements CurriculumRepository {
  // Cache في الذاكرة (مش بنحمل نفس الملف مرتين)
  final Map<String, StudyPlanModel> _cache = {};

  @override
  Future<StudyPlanModel?> loadCurriculum(String curriculumId) async {
    if (_cache.containsKey(curriculumId)) return _cache[curriculumId];

    // نبحث عن المسار المناسب حسب الـ ID
    final path = _getPathFromId(curriculumId);
    if (path == null) return null;

    return await loadCurriculumFromPath(path);
  }

  @override
  Future<StudyPlanModel?> loadCurriculumFromPath(String path) async {
    if (_cache.containsKey(path)) return _cache[path];

    try {
      final jsonStr = await rootBundle.loadString(path);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final model = StudyPlanModel.fromJson(json);
      _cache[path] = model;
      return model;
    } catch (e) {
      print('Error loading curriculum from $path: $e');
      return null;
    }
  }

  @override
  Future<List<StudyPlanModel>> loadAllCurricula() async {
    final results = <StudyPlanModel>[];

    // جميع مسارات اللوائح الموجودة
    final allPaths = [
      // لائحة 2019 - الأقسام الخمسة
      'assets/plans/2019/arts.json',
      'assets/plans/2019/music.json',
      'assets/plans/2019/media.json',
      'assets/plans/2019/home_eco.json',
      'assets/plans/2019/tech_edu.json',
      // لائحة 2024 - الأقسام الخمسة
      'assets/plans/2024/arts.json',
      'assets/plans/2024/music.json',
      'assets/plans/2024/media.json',
      'assets/plans/2024/home_eco.json',
      'assets/plans/2024/tech_edu.json',
      // البرامج المميزة
      'assets/plans/special/computer_en.json',
      'assets/plans/special/art_digital.json',
    ];

    for (final path in allPaths) {
      final model = await loadCurriculumFromPath(path);
      if (model != null) results.add(model);
    }
    return results;
  }

  /// تحديد المسار من معرف اللائحة
  String? _getPathFromId(String curriculumId) {
    final id = curriculumId.toLowerCase();

    // برامج مميزة
    if (id.contains('cs_english') || id.contains('computer')) {
      return 'assets/plans/special/computer_en.json';
    }
    if (id.contains('digital_art') || id.contains('art_digital')) {
      return 'assets/plans/special/art_digital.json';
    }

    // لائحة 2024
    if (id.contains('2024')) {
      if (id.contains('arts')) return 'assets/plans/2024/arts.json';
      if (id.contains('music')) return 'assets/plans/2024/music.json';
      if (id.contains('media')) return 'assets/plans/2024/media.json';
      if (id.contains('home_eco')) return 'assets/plans/2024/home_eco.json';
      return 'assets/plans/2024/tech_edu.json';
    }

    // لائحة 2019 (default)
    if (id.contains('arts')) return 'assets/plans/2019/arts.json';
    if (id.contains('music')) return 'assets/plans/2019/music.json';
    if (id.contains('media')) return 'assets/plans/2019/media.json';
    if (id.contains('home_eco')) return 'assets/plans/2019/home_eco.json';
    return 'assets/plans/2019/tech_edu.json';
  }

  void clearCache() => _cache.clear();
}
