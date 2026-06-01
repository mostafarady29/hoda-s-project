# ═══════════════════════════════════════
# Services — Import/Export Service
# ═══════════════════════════════════════
import json
from typing import Dict
from core.logger import logger
from repositories.import_job_repository import ImportJobRepository
from repositories.study_plan_repository import StudyPlanRepository


class ImportExportService:
    def __init__(self, job_repo: ImportJobRepository, plan_repo: StudyPlanRepository):
        self.job_repo = job_repo
        self.plan_repo = plan_repo

    async def import_curriculum_json(self, json_data: dict) -> Dict:
        """Import a full curriculum from JSON (شاشة 16)."""
        logger.info(f"Importing curriculum: {json_data.get('name', 'unknown')}")
        # Create the plan
        plan_data = {
            "name": json_data.get("name", ""),
            "year": json_data.get("year", 2024),
            "total_graduation_hours": json_data.get("total_graduation_hours", 0),
            "status": "draft",
        }
        plan = await self.plan_repo.create(plan_data)
        # TODO: Import courses, prerequisites, elective groups, etc.
        return {"plan_id": plan["id"], "status": "imported", "message": "تم استيراد اللائحة بنجاح"}

    async def export_curriculum_json(self, plan_id: str, options: dict = None) -> Dict:
        """Export a plan to JSON format (شاشة 17)."""
        plan = await self.plan_repo.find_by_id(plan_id)
        if not plan:
            from core.exceptions import EntityNotFoundError
            raise EntityNotFoundError("اللائحة", plan_id)
        # TODO: Include courses, prerequisites, etc. based on options
        return {
            "name": plan.get("name"),
            "year": plan.get("year"),
            "total_graduation_hours": plan.get("total_graduation_hours"),
            "courses": [],
            "prerequisites": [],
            "elective_groups": [],
        }
