# ═══════════════════════════════════════
# Repositories — Study Plan
# ═══════════════════════════════════════
from typing import Optional, List, Dict
from repositories.base_repository import BaseRepository


class StudyPlanRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "study_plans")

    async def find_active_plans(self) -> List[Dict]:
        """Get all active study plans."""
        result = self._table().select("*").eq("status", "active").order("year", desc=True).execute()
        return result.data or []

    async def find_by_year(self, year: int) -> List[Dict]:
        result = self._table().select("*").eq("year", year).execute()
        return result.data or []

    async def activate_plan(self, plan_id: str) -> Optional[Dict]:
        return await self.update(plan_id, {"status": "active"})

    async def archive_plan(self, plan_id: str) -> Optional[Dict]:
        return await self.update(plan_id, {"status": "archived"})

    async def duplicate_plan(self, plan_id: str, new_data: Dict) -> Optional[Dict]:
        """Copy a plan with new metadata."""
        original = await self.find_by_id(plan_id)
        if not original:
            return None
        original.pop("id", None)
        original.pop("created_at", None)
        original.pop("updated_at", None)
        original.update(new_data)
        original["status"] = "draft"
        return await self.create(original)
