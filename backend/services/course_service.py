# ═══════════════════════════════════════
# Services — Course Service
# ═══════════════════════════════════════
from typing import Optional, List, Dict
from core.logger import logger
from core.exceptions import EntityNotFoundError
from repositories.course_repository import CourseRepository
from repositories.prerequisite_repository import PrerequisiteRepository
from repositories.audit_repository import AuditRepository


class CourseService:
    def __init__(self, repo: CourseRepository, prereq_repo: PrerequisiteRepository, audit_repo: AuditRepository):
        self.repo = repo
        self.prereq_repo = prereq_repo
        self.audit = audit_repo

    async def list_courses(self, plan_id: str, department_id: str = None, level: int = None, page: int = 1, page_size: int = 50) -> tuple:
        filters = {"plan_id": plan_id}
        if department_id:
            filters["department_id"] = department_id
        if level:
            filters["level"] = level
        return await self.repo.find_all(filters=filters, order_by="code", ascending=True, page=page, page_size=page_size)

    async def get_course(self, course_id: str) -> Dict:
        course = await self.repo.find_by_id(course_id)
        if not course:
            raise EntityNotFoundError("المادة", course_id)
        course["prerequisites"] = await self.prereq_repo.find_by_course(course_id)
        return course

    async def create_course(self, data: Dict, user_id: str = None) -> Dict:
        course = await self.repo.create(data)
        if user_id:
            await self.audit.log_action(user_id, "create", "course", course["id"])
        return course

    async def update_course(self, course_id: str, data: Dict, user_id: str = None) -> Dict:
        await self.get_course(course_id)
        course = await self.repo.update(course_id, data)
        if user_id:
            await self.audit.log_action(user_id, "update", "course", course_id, data)
        return course

    async def delete_course(self, course_id: str, user_id: str = None) -> bool:
        await self.get_course(course_id)
        await self.prereq_repo.delete_by_course(course_id)
        result = await self.repo.delete(course_id)
        if user_id:
            await self.audit.log_action(user_id, "delete", "course", course_id)
        return result

    async def set_prerequisites(self, course_id: str, prereq_ids: List[str], relation_type: str = "all") -> List[Dict]:
        await self.prereq_repo.delete_by_course(course_id)
        records = [{"course_id": course_id, "required_course_id": pid, "relation_type": relation_type} for pid in prereq_ids]
        return await self.prereq_repo.bulk_create(records) if records else []
