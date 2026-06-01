# ═══════════════════════════════════════
# Schemas — Transcript
# ═══════════════════════════════════════
from pydantic import BaseModel
from typing import Optional, List


class TranscriptUploadResponse(BaseModel):
    job_id: str
    message: str = "جاري معالجة الملف"


class TranscriptJobStatus(BaseModel):
    job_id: str
    status: str
    progress: int = 0
    total_students: int = 0
    processed_students: int = 0
    error_message: Optional[str] = None
    started_at: Optional[str] = None
    completed_at: Optional[str] = None
