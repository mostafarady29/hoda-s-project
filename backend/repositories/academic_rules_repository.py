# ═══════════════════════════════════════
# Repositories — Academic Rules
# ═══════════════════════════════════════
from typing import Optional, Dict
from repositories.base_repository import BaseRepository


class AcademicRulesRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "academic_rules")

    async def find_by_plan(self, plan_id: str) -> Optional[Dict]:
        result = self._table().select("*").eq("plan_id", plan_id).maybe_single().execute()
        return result.data

    async def upsert_for_plan(self, plan_id: str, data: Dict) -> Optional[Dict]:
        existing = await self.find_by_plan(plan_id)
        data["plan_id"] = plan_id
        if existing:
            return await self.update(existing["id"], data)
        return await self.create(data)
