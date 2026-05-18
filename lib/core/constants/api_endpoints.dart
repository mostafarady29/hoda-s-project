// ===== File: lib/core/constants/api_endpoints.dart =====

/// كل الـ endpoints بتاعة الباك اند في مكان واحد.
/// غيّر [_baseUrl] فقط لما تعمل deployment.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base URL
  // Development   → http://10.0.2.2:8000  (Android emulator → localhost)
  // Development   → http://localhost:8000  (Web / iOS simulator)
  // Production    → https://acadexa-production.up.railway.app
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://acadexa-production.up.railway.app',
  );

  static String get baseUrl => _baseUrl;

  // ── Health
  static String get health => '$_baseUrl/health';

  // ── API v1 prefix
  static const String _v1 = '/api/v1';

  // ── Upload Excel workbook
  // POST  body: multipart/form-data  { file, department }
  // Response 202: { job_id, status, message }
  static String get upload => '$_baseUrl$_v1/upload';

  // ── Job status (polling)
  // GET  → { job_id, status, stats?, error_log? }
  static String jobStatus(String jobId) => '$_baseUrl$_v1/job/$jobId';

  // ── Delete job
  // DELETE
  static String deleteJob(String jobId) => '$_baseUrl$_v1/job/$jobId';

  // ── Result index (list of all students in workbook)
  // GET  → { job_id, status, department, total_students, students:[{student_id,name,sheet_name}], errors:[] }
  static String resultIndex(String jobId) => '$_baseUrl$_v1/result/$jobId';

  // ── Single student full detail
  // GET  → { student:{id,name,...}, semesters:[...], sheet_name, parsed_at }
  static String studentDetail(String jobId, String studentId) =>
      '$_baseUrl$_v1/result/$jobId/student/$studentId';

  // ── Batch students (up to 50 IDs)
  // GET  ?ids=id1,id2,id3
  // Response: { job_id, found, not_found:[], students:{id: {...}} }
  static String studentsBatch(String jobId, List<String> ids) =>
      '$_baseUrl$_v1/result/$jobId/students/batch?ids=${ids.join(",")}';
}
