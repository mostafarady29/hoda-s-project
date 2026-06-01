# ═══════════════════════════════════════
# Repositories — Program
# ═══════════════════════════════════════
from typing import List, Dict
from repositories.base_repository import BaseRepository


class ProgramRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "programs")

    async def find_by_department(self, department_id: str) -> List[Dict]:
        result = self._table().select("*").eq("department_id", department_id).execute()
        return result.data or []
