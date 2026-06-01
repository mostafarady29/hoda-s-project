# ═══════════════════════════════════════
# Services — Dashboard Service
# ═══════════════════════════════════════
from typing import Dict
from repositories.student_repository import StudentRepository
from repositories.study_plan_repository import StudyPlanRepository
from repositories.analysis_repository import AnalysisRepository


class DashboardService:
    def __init__(self, student_repo: StudentRepository, plan_repo: StudyPlanRepository, analysis_repo: AnalysisRepository):
        self.student_repo = student_repo
        self.plan_repo = plan_repo
        self.analysis_repo = analysis_repo

    async def get_overview(self) -> Dict:
        total_students = await self.student_repo.count()
        total_plans = await self.plan_repo.count()
        active_plans = await self.plan_repo.count({"status": "active"})

        return {
            "total_students": total_students,
            "total_plans": total_plans,
            "active_plans": active_plans,
        }
