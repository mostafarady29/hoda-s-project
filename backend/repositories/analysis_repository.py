# ═══════════════════════════════════════
# Repositories — Analysis
# ═══════════════════════════════════════
from typing import Optional, List, Dict
from repositories.base_repository import BaseRepository


class AnalysisRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "analysis_results")

    async def find_latest_by_student(self, student_id: str) -> Optional[Dict]:
        result = (
            self._table().select("*")
            .eq("student_id", student_id)
            .order("analyzed_at", desc=True)
            .limit(1)
            .execute()
        )
        return result.data[0] if result.data else None

    async def find_by_student(self, student_id: str) -> List[Dict]:
        result = self._table().select("*").eq("student_id", student_id).order("analyzed_at", desc=True).execute()
        return result.data or []
