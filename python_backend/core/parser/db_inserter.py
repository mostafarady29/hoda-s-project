import uuid
from datetime import datetime
from typing import Dict, List, Tuple
from pathlib import Path
import logging

from core.db.supabase_client import supabase
from core.parser.excel_parser import ExcelParser

logger = logging.getLogger("acadexa.db_inserter")

class DatabaseInserter:
    """يقرأ الـ Excel ويكتب مباشرة في Supabase"""
    
    def __init__(self, file_path: Path, department_name: str = "", department_id: str = None):
        self.parser = ExcelParser(file_path, department_name)
        self.file_path = file_path
        self.department_name = department_name
        self.department_id = department_id
        self.job_id = str(uuid.uuid4())
        self.stats = {"total": 0, "successful": 0, "failed": 0}
        self.errors = []
    
    def process_and_insert(self) -> Tuple[List[Dict], List[Dict]]:
        """المحطة الرئيسية: parse + insert في DB"""
        
        # 1. تسجيل بداية المهمة
        self._create_import_job()
        
        # 2. Parse الـ Excel
        students_data, parse_errors = self.parser.parse_all_students()
        
        self.stats["total"] = len(students_data)
        
        # 3. إدخال كل طالب في DB
        for student_data in students_data:
            try:
                self._insert_student_full(student_data)
                self.stats["successful"] += 1
            except Exception as e:
                self.stats["failed"] += 1
                error_msg = f"Student {student_data.get('student', {}).get('id')}: {str(e)}"
                self.errors.append(error_msg)
                logger.error(error_msg, exc_info=True)
        
        # 4. تحديث حالة المهمة
        self._update_import_job()
        
        return students_data, self.errors
    
    def _create_import_job(self):
        """تسجيل المهمة في جدول import_jobs"""
        try:
            supabase.table("import_jobs").insert({
                "id": self.job_id,
                "filename": self.file_path.name,
                "department_id": self.department_id,
                "status": "processing",
                "file_size_bytes": self.file_path.stat().st_size,
                "created_at": datetime.utcnow().isoformat()
            }).execute()
            logger.info(f"Created import job: {self.job_id}")
        except Exception as e:
            logger.error(f"Failed to create import job: {e}")
    
    def _update_import_job(self):
        """تحديث حالة المهمة بعد الانتهاء"""
        status = "completed" if self.stats["failed"] == 0 else "partial_success"
        
        try:
            supabase.table("import_jobs").update({
                "status": status,
                "total_students": self.stats["total"],
                "successful": self.stats["successful"],
                "failed": self.stats["failed"],
                "error_log": self.errors,
                "updated_at": datetime.utcnow().isoformat()
            }).eq("id", self.job_id).execute()
            logger.info(f"Updated import job {self.job_id}: {status}")
        except Exception as e:
            logger.error(f"Failed to update import job: {e}")
    
    def _insert_student_full(self, student_data: Dict):
        """إدخال طالب + فصوله + مواده في Supabase"""
        
        student_info = student_data["student"]
        student_code = student_info.get("id")
        
        if not student_code:
            raise ValueError("Student ID missing")
        
        # 1. البحث عن study_plan_id المناسب
        study_plan_id = self._resolve_study_plan(student_info.get("department", ""))
        
        # 2. إدخال الطالب في جدول students
        student_result = supabase.table("students").insert({
            "student_code": student_code,
            "name": student_info.get("name", ""),
            "department_id": self.department_id,
            "study_plan_id": study_plan_id,
            "enrollment_year": self._extract_year(student_data),
            "study_level": self._extract_level(student_info.get("study_level", "")),
            "cumulative_percentage": float(student_info.get("cumulative_percentage", "0").replace("%", "")),
            "import_job_id": self.job_id,
            "is_active": True,
            "created_at": datetime.utcnow().isoformat()
        }).execute()
        
        student_db_id = student_result.data[0]["id"]
        
        # 3. إدخال الفصول الدراسية والمواد
        for idx, semester in enumerate(student_data.get("semesters", [])):
            # إدخال الفصل
            semester_result = supabase.table("student_semesters").insert({
                "student_id": student_db_id,
                "semester_number": idx + 1,
                "academic_year": semester.get("academic_year", ""),
                "term": self._convert_term(semester.get("level_semester", "")),
                "total_hours": int(semester.get("semester_hours", 0)) if semester.get("semester_hours") else 0,
                "semester_gpa": float(semester.get("semester_gpa", 0)) if semester.get("semester_gpa") else None,
                "created_at": datetime.utcnow().isoformat()
            }).execute()
            
            semester_db_id = semester_result.data[0]["id"]
            
            # إدخال المواد
            for course in semester.get("courses", []):
                # البحث عن course_id من جدول courses (اللائحة)
                course_id = self._find_course_id(
                    course.get("course_code", ""),
                    study_plan_id
                )
                
                # حساب grade_points من grade_letter
                grade_points = self._calculate_grade_points(course.get("grade_letter", ""))
                passed = course.get("passed", "نعم") in ["نعم", "√", "ناجح", True]
                
                supabase.table("student_courses").insert({
                    "student_id": student_db_id,
                    "semester_id": semester_db_id,
                    "course_code": course.get("course_code", ""),
                    "course_name": course.get("course_name", ""),
                    "course_id": course_id,
                    "credit_hours": int(course.get("hours", 0)) if course.get("hours") else 0,
                    "credit_hours_attempted": int(course.get("hours", 0)) if course.get("hours") else 0,
                    "passed": passed,
                    "grade_letter": course.get("grade_letter", ""),
                    "grade_points": grade_points,
                    "score": float(course.get("score", 0)) if course.get("score") else None,
                    "created_at": datetime.utcnow().isoformat()
                }).execute()
        
        logger.info(f"Inserted student {student_code} with {len(student_data.get('semesters', []))} semesters")
        
        # 4. تشغيل التحليل التلقائي للطالب
        self._trigger_analysis(student_db_id)
        
        return student_db_id
    
    def _resolve_study_plan(self, department_name: str) -> str:
        """تحديد خطة الدراسة المناسبة للطالب"""
        if not self.department_id:
            return None
        
        # استدعاء دالة resolve_student_plan في Supabase
        try:
            result = supabase.rpc(
                "resolve_student_plan",
                {
                    "p_department_id": self.department_id,
                    "p_enrollment_year": datetime.now().year
                }
            ).execute()
            return result.data
        except Exception as e:
            logger.warning(f"Could not resolve study plan: {e}")
            return None
    
    def _find_course_id(self, course_code: str, plan_id: str) -> str:
        """البحث عن course_id من جدول courses"""
        if not course_code or not plan_id:
            return None
        
        try:
            result = supabase.table("courses") \
                .select("id") \
                .eq("plan_id", plan_id) \
                .eq("code", course_code) \
                .execute()
            
            if result.data:
                return result.data[0]["id"]
        except Exception:
            pass
        
        return None
    
    def _calculate_grade_points(self, grade_letter: str) -> float:
        """تحويل grade_letter إلى نقاط"""
        grade_map = {
            "A+": 4.0, "A": 4.0, "A-": 3.7,
            "B+": 3.3, "B": 3.0, "B-": 2.7,
            "C+": 2.3, "C": 2.0, "C-": 1.7,
            "D+": 1.3, "D": 1.0, "D-": 0.7,
            "F": 0.0
        }
        return grade_map.get(grade_letter, 0.0)
    
    def _convert_term(self, level_semester: str) -> str:
        """تحويل 'المستوى الأول - الفصل الأول' إلى fall/spring/summer"""
        if "الأول" in level_semester or "الخريف" in level_semester:
            return "fall"
        elif "الثاني" in level_semester or "الربيع" in level_semester:
            return "spring"
        elif "الصيف" in level_semester:
            return "summer"
        return None
    
    def _extract_level(self, study_level_str: str) -> int:
        """استخراج رقم المستوى من 'المستوى الثالث' -> 3"""
        level_map = {"الأول": 1, "الثاني": 2, "الثالث": 3, "الرابع": 4}
        for key, value in level_map.items():
            if key in study_level_str:
                return value
        return None
    
    def _extract_year(self, student_data: Dict) -> int:
        """استخراج سنة الالتحاق من أول ترم"""
        semesters = student_data.get("semesters", [])
        if semesters:
            academic_year = semesters[0].get("academic_year", "")
            # تنسيق "2022-2023" -> 2022
            if "-" in academic_year:
                return int(academic_year.split("-")[0])
        return datetime.now().year
    
    def _trigger_analysis(self, student_id: str):
        """تشغيل التحليل التلقائي للطالب بعد إضافته"""
        try:
            supabase.rpc("analyze_student_progress", {"p_student_id": student_id}).execute()
            logger.info(f"Triggered analysis for student {student_id}")
        except Exception as e:
            logger.warning(f"Could not trigger analysis: {e}")