# ═══════════════════════════════════════
# API — Transcript Routes
# ═══════════════════════════════════════
from fastapi import APIRouter, UploadFile, File, Depends
from schemas.transcript import TranscriptUploadResponse, TranscriptJobStatus
from app.response import success_response
from app.dependencies import get_transcript_service

router = APIRouter()


@router.post("/upload", response_model=TranscriptUploadResponse)
async def upload_transcript(
    file: UploadFile = File(...),
    service=Depends(get_transcript_service),
):
    """رفع ملف Excel للسجلات الأكاديمية"""
    contents = await file.read()
    job = await service.upload_transcript(file.filename, contents)
    return {"job_id": job["id"], "message": "جاري معالجة الملف"}


@router.get("/{transcript_id}")
async def get_transcript(transcript_id: str):
    return success_response(data={})


@router.get("/job/{job_id}")
async def get_job_status(job_id: str, service=Depends(get_transcript_service)):
    job = await service.get_job_status(job_id)
    return success_response(job)


@router.post("/reprocess")
async def reprocess_transcripts():
    return success_response(message="جاري إعادة المعالجة")
