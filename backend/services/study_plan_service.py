# ═══════════════════════════════════════
# Services — Study Plan Service
# ═══════════════════════════════════════
from typing import Optional, List, Dict
from core.logger import logger
from core.exceptions import EntityNotFoundError, ValidationError
from repositories.study_plan_repository import StudyPlanRepository
from repositories.audit_repository import AuditRepository


class StudyPlanService:
    def __init__(self, repo: StudyPlanRepository, audit_repo: AuditRepository):
        self.repo = repo
        self.audit = audit_repo

    async def list_plans(self, page: int = 1, page_size: int = 20, status: str = None) -> tuple:
        filters = {}
        if status:
            filters["status"] = status
        return await self.repo.find_all(filters=filters, page=page, page_size=page_size)

    async def get_plan(self, plan_id: str) -> Dict:
        plan = await self.repo.find_by_id(plan_id)
        if not plan:
            raise EntityNotFoundError("اللائحة الدراسية", plan_id)
        return plan

    async def create_plan(self, data: Dict, user_id: str = None) -> Dict:
        plan = await self.repo.create(data)
        if user_id:
            await self.audit.log_action(user_id, "create", "study_plan", plan["id"], data)
        logger.info(f"Created study plan: {plan['id']}")
        return plan

    async def update_plan(self, plan_id: str, data: Dict, user_id: str = None) -> Dict:
        await self.get_plan(plan_id)
        plan = await self.repo.update(plan_id, data)
        if user_id:
            await self.audit.log_action(user_id, "update", "study_plan", plan_id, data)
        return plan

    async def delete_plan(self, plan_id: str, user_id: str = None) -> bool:
        await self.get_plan(plan_id)
        result = await self.repo.delete(plan_id)
        if user_id:
            await self.audit.log_action(user_id, "delete", "study_plan", plan_id)
        return result

    async def copy_plan(self, plan_id: str, new_data: Dict, user_id: str = None) -> Dict:
        """Copy an entire plan with its courses, prerequisites, etc."""
        plan = await self.repo.duplicate_plan(plan_id, new_data)
        if not plan:
            raise EntityNotFoundError("اللائحة الدراسية", plan_id)
        if user_id:
            await self.audit.log_action(user_id, "copy", "study_plan", plan["id"], {"source": plan_id})
        logger.info(f"Copied plan {plan_id} → {plan['id']}")
        return plan

    async def activate_plan(self, plan_id: str, user_id: str = None) -> Dict:
        plan = await self.repo.activate_plan(plan_id)
        if user_id:
            await self.audit.log_action(user_id, "activate", "study_plan", plan_id)
        return plan

    async def get_active_plans(self) -> List[Dict]:
        return await self.repo.find_active_plans()
