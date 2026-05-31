"""
Student repository — all database operations for students, semesters, courses.
"""
from typing import Optional, List, Dict, Any, Tuple
from core.db.supabase_client import get_supabase
from core.db.models import StudentCreate, StudentSemesterCreate, StudentCourseCreate
import logging

logger = logging.getLogger("acadexa.student_repo")


class StudentRepository:

    # ─── Students ─────────────────────────────────────────────────────────────

    def upsert_student(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Insert or update student by student_code."""
        sb = get_supabase()
        # Check if exists
        existing = sb.table("students").select("id").eq(
            "student_code", data["student_code"]
        ).execute()

        if existing.data:
            student_id = existing.data[0]["id"]
            result = sb.table("students").update(data).eq("id", student_id).execute()
            return result.data[0] if result.data else {"id": student_id}
        else:
            result = sb.table("students").insert(data).execute()
            return result.data[0] if result.data else {}

    def get_student_by_code(self, code: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("students").select("*").eq("student_code", code).execute()
        return res.data[0] if res.data else None

    def get_student_by_id(self, student_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("students").select("*").eq("id", student_id).execute()
        return res.data[0] if res.data else None

    def list_students(
        self,
        department_id: Optional[str] = None,
        plan_id: Optional[str] = None,
        is_active: bool = True,
        limit: int = 100,
        offset: int = 0,
    ) -> List[Dict]:
        sb = get_supabase()
        q = sb.table("student_full_summary").select("*").eq("is_active", is_active)
        if department_id:
            q = q.eq("department_id", department_id)
        if plan_id:
            q = q.eq("study_plan_id", plan_id)
        q = q.range(offset, offset + limit - 1)
        res = q.execute()
        return res.data or []

    def search_students(self, query: str, department_id: Optional[str] = None) -> List[Dict]:
        sb = get_supabase()
        q = sb.table("students").select("id,student_code,name,department_id,study_level,cumulative_gpa,is_active")
        # Filter by name or code using ilike
        q = q.or_(f"name.ilike.%{query}%,student_code.ilike.%{query}%")
        if department_id:
            q = q.eq("department_id", department_id)
        res = q.limit(50).execute()
        return res.data or []

    def count_students(self, department_id: Optional[str] = None) -> int:
        sb = get_supabase()
        q = sb.table("students").select("id", count="exact").eq("is_active", True)
        if department_id:
            q = q.eq("department_id", department_id)
        res = q.execute()
        return res.count or 0

    # ─── Semesters ────────────────────────────────────────────────────────────

    def upsert_semester(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Insert or update semester by student_id + semester_number."""
        sb = get_supabase()
        existing = sb.table("student_semesters").select("id").eq(
            "student_id", data["student_id"]
        ).eq("semester_number", data["semester_number"]).execute()

        if existing.data:
            semester_id = existing.data[0]["id"]
            res = sb.table("student_semesters").update(data).eq("id", semester_id).execute()
            return res.data[0] if res.data else {"id": semester_id}
        else:
            res = sb.table("student_semesters").insert(data).execute()
            return res.data[0] if res.data else {}

    def get_student_semesters(self, student_id: str) -> List[Dict]:
        sb = get_supabase()
        res = (
            sb.table("student_semesters")
            .select("*")
            .eq("student_id", student_id)
            .order("semester_number")
            .execute()
        )
        return res.data or []

    # ─── Courses ──────────────────────────────────────────────────────────────

    def insert_student_course(self, data: Dict[str, Any]) -> Dict[str, Any]:
        sb = get_supabase()
        res = sb.table("student_courses").insert(data).execute()
        return res.data[0] if res.data else {}

    def get_student_courses(self, student_id: str) -> List[Dict]:
        sb = get_supabase()
        res = (
            sb.table("student_courses")
            .select("*")
            .eq("student_id", student_id)
            .execute()
        )
        return res.data or []

    def get_courses_for_semester(self, semester_id: str) -> List[Dict]:
        sb = get_supabase()
        res = (
            sb.table("student_courses")
            .select("*")
            .eq("semester_id", semester_id)
            .execute()
        )
        return res.data or []

    def delete_student_courses(self, student_id: str) -> None:
        """Delete all courses for a student (used before re-import)."""
        sb = get_supabase()
        sb.table("student_courses").delete().eq("student_id", student_id).execute()

    def delete_student_semesters(self, student_id: str) -> None:
        sb = get_supabase()
        sb.table("student_semesters").delete().eq("student_id", student_id).execute()

    # ─── Full student record ──────────────────────────────────────────────────

    def get_full_student_record(self, student_id: str) -> Optional[Dict]:
        """Get student + all semesters + all courses."""
        student = self.get_student_by_id(student_id)
        if not student:
            return None

        semesters = self.get_student_semesters(student_id)
        for sem in semesters:
            sem["courses"] = self.get_courses_for_semester(sem["id"])

        student["semesters"] = semesters
        return student

    def bulk_insert_students(self, students: List[Dict]) -> Tuple[int, int]:
        """Bulk upsert students. Returns (success, failed) counts."""
        sb = get_supabase()
        success = 0
        failed = 0
        for s in students:
            try:
                self.upsert_student(s)
                success += 1
            except Exception as e:
                logger.error(f"Failed to upsert student {s.get('student_code')}: {e}")
                failed += 1
        return success, failed