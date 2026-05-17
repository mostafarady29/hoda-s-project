// ===== File: lib/core/cache/analysis_cache_service.dart =====
//
// Cache للـ Expert System analysis results.
// لأن التحليل مكلف (بيشغّل كل القواعد)، بنحفظ نتيجته
// ونرجعها على طول لو الـ student data ما اتغيرتش.
//
// Cache strategy:
//   Key  → studentId
//   Value → AnalysisCacheEntry { result, studentHash, cachedAt }
//   TTL  → 30 دقيقة (قابل للتغيير)
//   Max  → 200 entry (بعدين بيمسح الأقدم)

import 'dart:collection';
import 'dart:convert';

/// نتيجة التحليل اللي بنحفظها — غيّر النوع ده لو عندك
/// AnalysisResult entity مختلف.
typedef AnalysisResultJson = Map<String, dynamic>;

class AnalysisCacheEntry {
  final AnalysisResultJson result;
  final String
      studentHash; // hash من بيانات الطالب → للتحقق إن البيانات ما اتغيرتش
  final DateTime cachedAt;

  const AnalysisCacheEntry({
    required this.result,
    required this.studentHash,
    required this.cachedAt,
  });

  bool isExpired(Duration ttl) => DateTime.now().difference(cachedAt) > ttl;
}

class AnalysisCacheService {
  static const Duration _defaultTtl = Duration(minutes: 30);
  static const int _maxEntries = 200;

  final Duration ttl;

  // LinkedHashMap → يحتفظ بترتيب الإدخال (للـ LRU eviction)
  final LinkedHashMap<String, AnalysisCacheEntry> _cache = LinkedHashMap();

  AnalysisCacheService({this.ttl = _defaultTtl});

  // ─────────────────────────────────────────────
  // Write
  // ─────────────────────────────────────────────

  void put(String studentId, AnalysisResultJson result, String studentHash) {
    // Evict expired entries first
    _evictExpired();

    // Evict oldest if still over max
    while (_cache.length >= _maxEntries) {
      _cache.remove(_cache.keys.first);
    }

    _cache[studentId] = AnalysisCacheEntry(
      result: result,
      studentHash: studentHash,
      cachedAt: DateTime.now(),
    );
  }

  // ─────────────────────────────────────────────
  // Read
  // ─────────────────────────────────────────────

  /// يرجع النتيجة لو موجودة وصالحة وبيانات الطالب ما اتغيرتش.
  /// يرجع null لو expired أو البيانات اتغيرت.
  AnalysisResultJson? get(String studentId, String currentStudentHash) {
    final entry = _cache[studentId];
    if (entry == null) return null;

    // Expired?
    if (entry.isExpired(ttl)) {
      _cache.remove(studentId);
      return null;
    }

    // Data changed?
    if (entry.studentHash != currentStudentHash) {
      _cache.remove(studentId);
      return null;
    }

    // LRU: re-insert to mark as recently used
    _cache.remove(studentId);
    _cache[studentId] = entry;

    return entry.result;
  }

  bool has(String studentId, String currentStudentHash) =>
      get(studentId, currentStudentHash) != null;

  // ─────────────────────────────────────────────
  // Invalidation
  // ─────────────────────────────────────────────

  void invalidate(String studentId) => _cache.remove(studentId);

  void invalidateAll() => _cache.clear();

  // ─────────────────────────────────────────────
  // Stats (للـ debugging)
  // ─────────────────────────────────────────────

  int get size => _cache.length;

  Map<String, dynamic> get stats {
    final now = DateTime.now();
    int expired = 0;
    for (final entry in _cache.values) {
      if (entry.isExpired(ttl)) expired++;
    }
    return {
      'total_entries': _cache.length,
      'expired_entries': expired,
      'valid_entries': _cache.length - expired,
      'max_entries': _maxEntries,
      'ttl_minutes': ttl.inMinutes,
    };
  }

  // ─────────────────────────────────────────────
  // Internal
  // ─────────────────────────────────────────────

  void _evictExpired() {
    final expiredKeys = _cache.entries
        .where((e) => e.value.isExpired(ttl))
        .map((e) => e.key)
        .toList();
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  // ─────────────────────────────────────────────
  // Hash helper — استخدمه لحساب hash بيانات الطالب
  // ─────────────────────────────────────────────

  /// يحسب hash بسيط من بيانات الطالب الخام (Map).
  /// لو تغيرت أي بيانات → hash مختلف → cache miss.
  static String computeHash(Map<String, dynamic> studentRaw) {
    final jsonStr = jsonEncode(studentRaw);
    // Simple djb2-style hash — كافي لأغراض الـ cache
    var hash = 5381;
    for (final c in jsonStr.codeUnits) {
      hash = ((hash << 5) + hash) ^ c;
      hash &= 0x7FFFFFFF; // Keep positive 32-bit
    }
    return hash.toRadixString(16);
  }
}
