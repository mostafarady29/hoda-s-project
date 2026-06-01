# ═══════════════════════════════════════
# Repositories — Grading
# ═══════════════════════════════════════
from typing import List, Dict
from repositories.base_repository import BaseRepository


class GradingRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "grade_scales")

    async def find_by_plan(self, plan_id: str) -> List[Dict]:
        result = self._table().select("*").eq("plan_id", plan_id).order("order").execute()
        return result.data or []

    async def replace_for_plan(self, plan_id: str, grades: List[Dict]) -> List[Dict]:
        """Delete all existing grades for plan and insert new ones."""
        self._table().delete().eq("plan_id", plan_id).execute()
        for g in grades:
            g["plan_id"] = plan_id
        return await self.bulk_create(grades)
