# ═══════════════════════════════════════
# Repositories — Import Job
# ═══════════════════════════════════════
"""
Replaces the old in-memory _jobs_status dict.
Now jobs are persisted in Supabase's import_jobs table.
"""
from typing import Optional, List, Dict
from datetime import datetime
from repositories.base_repository import BaseRepository


class ImportJobRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "import_jobs")

    async def create_job(self, filename: str, department: str = "") -> Dict:
        return await self.create({
            "filename": filename,
            "department": department,
            "status": "pending",
            "progress": 0,
            "error_message": None,
            "started_at": None,
            "completed_at": None,
        })

    async def update_progress(self, job_id: str, progress: int, status: str = "processing") -> None:
        data = {"progress": progress, "status": status}
        if status == "processing" and progress == 0:
            data["started_at"] = datetime.utcnow().isoformat()
        if status in ("completed", "failed", "partial_success"):
            data["completed_at"] = datetime.utcnow().isoformat()
        await self.update(job_id, data)

    async def mark_failed(self, job_id: str, error_message: str) -> None:
        await self.update(job_id, {
            "status": "failed",
            "error_message": error_message,
            "completed_at": datetime.utcnow().isoformat(),
        })

    async def mark_completed(self, job_id: str, stats: dict = None) -> None:
        await self.update(job_id, {
            "status": "completed",
            "progress": 100,
            "stats": stats or {},
            "completed_at": datetime.utcnow().isoformat(),
        })

    async def find_pending_jobs(self) -> List[Dict]:
        result = self._table().select("*").eq("status", "pending").order("created_at").execute()
        return result.data or []

    async def find_stuck_jobs(self) -> List[Dict]:
        """Find jobs stuck in 'processing' (e.g., after server restart)."""
        result = self._table().select("*").eq("status", "processing").execute()
        return result.data or []
