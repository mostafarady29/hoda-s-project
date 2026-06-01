# ═══════════════════════════════════════
# Repositories — Department
# ═══════════════════════════════════════
from typing import List, Dict
from repositories.base_repository import BaseRepository


class DepartmentRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "departments")

    async def find_by_plan(self, plan_id: str) -> List[Dict]:
        result = self._table().select("*").eq("plan_id", plan_id).order("code").execute()
        return result.data or []

    async def find_programs(self, plan_id: str) -> List[Dict]:
        result = self._table().select("*").eq("plan_id", plan_id).eq("is_program", True).execute()
        return result.data or []
