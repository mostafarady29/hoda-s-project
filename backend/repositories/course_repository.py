# ═══════════════════════════════════════
# Repositories — Course
# ═══════════════════════════════════════
from typing import Optional, List, Dict
from repositories.base_repository import BaseRepository


class CourseRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "courses")

    async def find_by_plan(self, plan_id: str, department_id: str = None, level: int = None) -> List[Dict]:
        query = self._table().select("*").eq("plan_id", plan_id)
        if department_id:
            query = query.eq("department_id", department_id)
        if level:
            query = query.eq("level", level)
        result = query.order("level").order("semester").order("code").execute()
        return result.data or []

    async def find_by_code(self, plan_id: str, code: str) -> Optional[Dict]:
        result = self._table().select("*").eq("plan_id", plan_id).eq("code", code).maybe_single().execute()
        return result.data

    async def find_by_equivalent_code(self, plan_id: str, code: str) -> List[Dict]:
        result = self._table().select("*").eq("plan_id", plan_id).contains("equivalent_codes", [code]).execute()
        return result.data or []

    async def count_by_plan(self, plan_id: str) -> int:
        return await self.count({"plan_id": plan_id})
