# ═══════════════════════════════════════
# Services — Transcript Service
# ═══════════════════════════════════════
from typing import Dict
from core.logger import logger
from repositories.transcript_repository import TranscriptRepository
from repositories.student_repository import StudentRepository
from repositories.import_job_repository import ImportJobRepository


class TranscriptService:
    def __init__(self, repo: TranscriptRepository, student_repo: StudentRepository, job_repo: ImportJobRepository):
        self.repo = repo
        self.student_repo = student_repo
        self.job_repo = job_repo

    async def upload_transcript(self, filename: str, file_data: bytes, department: str = "") -> Dict:
        """Create import job for uploaded transcript file."""
        job = await self.job_repo.create_job(filename, department)
        logger.info(f"Created transcript import job: {job['id']} for {filename}")
        # Background processing will be handled by jobs/transcript_job.py
        return job

    async def get_job_status(self, job_id: str) -> Dict:
        job = await self.job_repo.find_by_id(job_id)
        if not job:
            from core.exceptions import EntityNotFoundError
            raise EntityNotFoundError("المهمة", job_id)
        return job

    async def get_student_transcript(self, student_id: str) -> Dict:
        transcript = await self.repo.find_by_student(student_id)
        if not transcript:
            from core.exceptions import EntityNotFoundError
            raise EntityNotFoundError("السجل الأكاديمي", student_id)
        return transcript
