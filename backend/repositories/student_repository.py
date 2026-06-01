# ═══════════════════════════════════════
# Repositories — Student
# ═══════════════════════════════════════
from typing import Optional, List, Dict
from repositories.base_repository import BaseRepository


class StudentRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "students")

    async def find_by_code(self, student_code: str) -> Optional[Dict]:
        result = self._table().select("*").eq("student_code", student_code).maybe_single().execute()
        return result.data

    async def find_by_department(self, department_id: str) -> List[Dict]:
        result = self._table().select("*").eq("department_id", department_id).execute()
        return result.data or []

    async def find_by_job(self, job_id: str) -> List[Dict]:
        result = self._table().select("*").eq("job_id", job_id).execute()
        return result.data or []

    async def upsert_by_code(self, student_code: str, data: Dict) -> Optional[Dict]:
        existing = await self.find_by_code(student_code)
        if existing:
            return await self.update(existing["id"], data)
        data["student_code"] = student_code
        return await self.create(data)
