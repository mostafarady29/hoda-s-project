# Services — remaining stubs
# These mirror the curriculum management screens

from typing import Dict, List
from core.exceptions import EntityNotFoundError
from repositories.prerequisite_repository import PrerequisiteRepository


class PrerequisiteService:
    def __init__(self, repo: PrerequisiteRepository):
        self.repo = repo

    async def get_by_course(self, course_id: str) -> List[Dict]:
        return await self.repo.find_by_course(course_id)

    async def set_prerequisites(self, course_id: str, data: List[Dict]) -> List[Dict]:
        await self.repo.delete_by_course(course_id)
        for d in data:
            d["course_id"] = course_id
        return await self.repo.bulk_create(data) if data else []


class ElectiveGroupService:
    def __init__(self, repo):
        self.repo = repo

    async def list_by_plan(self, plan_id: str) -> List[Dict]:
        return await self.repo.find_by_plan(plan_id)

    async def create_group(self, data: Dict) -> Dict:
        return await self.repo.create(data)

    async def update_group(self, group_id: str, data: Dict) -> Dict:
        return await self.repo.update(group_id, data)

    async def delete_group(self, group_id: str) -> bool:
        return await self.repo.delete(group_id)


class GradingService:
    def __init__(self, repo):
        self.repo = repo

    async def get_scale(self, plan_id: str) -> List[Dict]:
        return await self.repo.find_by_plan(plan_id)

    async def set_scale(self, plan_id: str, grades: List[Dict]) -> List[Dict]:
        return await self.repo.replace_for_plan(plan_id, grades)


class AcademicRulesService:
    def __init__(self, repo):
        self.repo = repo

    async def get_rules(self, plan_id: str) -> Dict:
        rules = await self.repo.find_by_plan(plan_id)
        if not rules:
            raise EntityNotFoundError("القواعد الأكاديمية", plan_id)
        return rules

    async def set_rules(self, plan_id: str, data: Dict) -> Dict:
        return await self.repo.upsert_for_plan(plan_id, data)


class FieldTrainingService:
    def __init__(self, repo):
        self.repo = repo

    async def get_settings(self, plan_id: str) -> Dict:
        settings = await self.repo.find_by_plan(plan_id)
        if not settings:
            raise EntityNotFoundError("إعدادات التدريب الميداني", plan_id)
        return settings

    async def set_settings(self, plan_id: str, data: Dict) -> Dict:
        return await self.repo.upsert_for_plan(plan_id, data)


class AuditService:
    def __init__(self, repo):
        self.repo = repo

    async def get_logs(self, entity: str, entity_id: str) -> List[Dict]:
        return await self.repo.find_by_entity(entity, entity_id)
