# ═══════════════════════════════════════
# Services — Analysis Service
# ═══════════════════════════════════════
from typing import Dict
from core.logger import logger
from core.exceptions import EntityNotFoundError
from repositories.analysis_repository import AnalysisRepository
from repositories.student_repository import StudentRepository
from repositories.course_repository import CourseRepository


class AnalysisService:
    def __init__(self, repo: AnalysisRepository, student_repo: StudentRepository, course_repo: CourseRepository):
        self.repo = repo
        self.student_repo = student_repo
        self.course_repo = course_repo

    async def analyze_student(self, student_id: str, plan_id: str = None) -> Dict:
        """Run expert system analysis for a student."""
        student = await self.student_repo.find_by_id(student_id)
        if not student:
            raise EntityNotFoundError("الطالب", student_id)

        # Use student's plan if not specified
        if not plan_id:
            plan_id = student.get("plan_id")

        # Get all courses for the plan
        courses = await self.course_repo.find_by_plan(plan_id) if plan_id else []

        # Run expert system (will be implemented in expert_system/)
        from expert_system.engine.inference_engine import InferenceEngine
        engine = InferenceEngine()
        result = await engine.analyze(student, courses, plan_id)

        # Store result
        stored = await self.repo.create(result)
        logger.info(f"Analysis completed for student {student_id}")
        return stored

    async def get_analysis(self, student_id: str) -> Dict:
        result = await self.repo.find_latest_by_student(student_id)
        if not result:
            raise EntityNotFoundError("نتيجة التحليل", student_id)
        return result

    async def get_recommendations(self, student_id: str) -> list:
        result = await self.get_analysis(student_id)
        return result.get("recommendations", [])

    async def get_warnings(self, student_id: str) -> list:
        result = await self.get_analysis(student_id)
        return result.get("warnings", [])
