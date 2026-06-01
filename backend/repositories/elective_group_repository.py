# ═══════════════════════════════════════
# Repositories — Elective Group
# ═══════════════════════════════════════
from typing import List, Dict
from repositories.base_repository import BaseRepository


class ElectiveGroupRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "elective_groups")

    async def find_by_plan(self, plan_id: str) -> List[Dict]:
        result = self._table().select("*").eq("plan_id", plan_id).order("name").execute()
        return result.data or []

    async def find_by_department(self, plan_id: str, department_id: str) -> List[Dict]:
        result = (
            self._table().select("*")
            .eq("plan_id", plan_id)
            .eq("department_id", department_id)
            .execute()
        )
        return result.data or []
