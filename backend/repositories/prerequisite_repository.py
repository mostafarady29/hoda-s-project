# ═══════════════════════════════════════
# Repositories — Prerequisite
# ═══════════════════════════════════════
from typing import List, Dict
from repositories.base_repository import BaseRepository


class PrerequisiteRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "prerequisites")

    async def find_by_course(self, course_id: str) -> List[Dict]:
        result = self._table().select("*").eq("course_id", course_id).execute()
        return result.data or []

    async def delete_by_course(self, course_id: str) -> bool:
        try:
            self._table().delete().eq("course_id", course_id).execute()
            return True
        except Exception:
            return False
