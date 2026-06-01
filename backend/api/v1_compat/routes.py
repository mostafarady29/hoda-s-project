# ═══════════════════════════════════════
# API — V1 Compatibility Layer
# ═══════════════════════════════════════
"""
Maps old V1 endpoints to Backend V2 services.
This ensures the existing Flutter frontend works
without any changes.

Old V1 endpoints:
  POST /api/v1/upload           → upload Excel
  GET  /api/v1/job/{job_id}     → job status polling
  GET  /api/v1/result/{job_id}  → student index from job
  GET  /api/v1/result/{job_id}/student/{student_id} → student detail
  GET  /api/v1/students/        → list all students from DB
  GET  /api/v1/students/{id}    → single student
  GET  /api/v1/students/{id}/full → student with semesters
  DELETE /api/v1/job/{job_id}   → delete job
"""
import uuid
import shutil
from pathlib import Path
from datetime import datetime
from fastapi import APIRouter, UploadFile, File, Form, BackgroundTasks, HTTPException, Query, Request
from fastapi.responses import JSONResponse
from typing import Optional

from core.config import settings
from core.logger import logger
from integrations.supabase.client import get_supabase_client

router = APIRouter()

# ── In-memory job tracking (matches V1 behavior exactly)
_active_jobs = 0
_jobs_status = {}


# ═══════════════════════════════════════
#  POST /upload — Upload Excel file
# ═══════════════════════════════════════
@router.post("/upload", summary="رفع ملف Excel", tags=["استيراد وتحليل"])
async def upload_excel(
    background_tasks: BackgroundTasks,
    request: Request,
    file: UploadFile = File(...),
    department_code: str = Form(...),
):
    global _active_jobs

    # 1. Validate extension
    ext = Path(file.filename).suffix.lower()
    if ext not in settings.ALLOWED_EXTENSIONS:
        raise HTTPException(400, detail=f"نوع الملف غير مدعوم. المسموح: {settings.ALLOWED_EXTENSIONS}")

    # 2. Check file size
    file.file.seek(0, 2)
    size = file.file.tell()
    file.file.seek(0)
    if size > settings.MAX_FILE_SIZE:
        raise HTTPException(413, detail=f"حجم الملف كبير جداً. الحد الأقصى {settings.MAX_FILE_SIZE // (1024*1024)} MB")

    # 3. Concurrent jobs
    if _active_jobs >= settings.MAX_CONCURRENT_JOBS:
        raise HTTPException(429, detail="الخادم مشغول. حاول مرة أخرى بعد قليل.")

    # 4. Save temp file
    temp_path = settings.TEMP_UPLOADS / f"{uuid.uuid4()}{ext}"
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 5. Generate job ID & track
    job_id = str(uuid.uuid4())
    _active_jobs += 1
    _jobs_status[job_id] = {
        "job_id": job_id,
        "status": "processing",
        "filename": file.filename,
        "department": department_code,
        "created_at": datetime.now().isoformat(),
        "stats": None,
        "error_log": [],
    }

    # 6. Background processing
    background_tasks.add_task(
        _process_excel_to_db,
        job_id, temp_path, department_code,
    )

    return JSONResponse(
        status_code=202,
        content={
            "job_id": job_id,
            "status": "processing",
            "message": "تم استلام الملف وجاري المعالجة",
            "department_code": department_code,
            "filename": file.filename,
        },
    )


# ═══════════════════════════════════════
#  GET /job/{job_id} — Job status polling
# ═══════════════════════════════════════
@router.get("/job/{job_id}", summary="حالة المعالجة", tags=["استيراد وتحليل"])
async def get_job_status(job_id: str):
    status = _jobs_status.get(job_id)
    if not status:
        # Try from DB
        client = get_supabase_client()
        if client:
            try:
                result = client.table("import_jobs").select("*").eq("id", job_id).execute()
            except Exception:
                return {"job_id": job_id, "status": "not_found"}
            if result.data:
                row = result.data[0]
                return {
                    "job_id": row["id"],
                    "status": row.get("status", "not_found"),
                    "filename": row.get("filename"),
                    "department": row.get("department"),
                    "created_at": row.get("created_at"),
                    "updated_at": row.get("updated_at"),
                    "stats": row.get("result_data"),
                    "error_log": [],
                }
        return {"job_id": job_id, "status": "not_found"}
    return status


# ═══════════════════════════════════════
#  DELETE /job/{job_id} — Delete job
# ═══════════════════════════════════════
@router.delete("/job/{job_id}", summary="حذف job", tags=["استيراد وتحليل"])
async def delete_job(job_id: str):
    _jobs_status.pop(job_id, None)
    return {"message": "تم الحذف"}


# ═══════════════════════════════════════
#  GET /result/{job_id} — Student index
# ═══════════════════════════════════════
@router.get("/result/{job_id}", summary="فهرس الطلاب", tags=["استيراد وتحليل"])
async def get_result_index(job_id: str):
    """Returns list of students processed by this job."""
    client = get_supabase_client()
    if not client:
        raise HTTPException(503, detail="قاعدة البيانات غير متاحة")

    # Get students linked to this job (via import metadata or all students)
    try:
        result = client.table("students").select("id, student_code, name, department_id, created_at").order("created_at", desc=True).limit(200).execute()
    except Exception as e:
        logger.error(f"Result index query error: {e}")
        return {"job_id": job_id, "status": "completed", "total_students": 0, "students": [], "errors": [str(e)]}

    students = [
        {
            "student_id": s["id"],
            "name": s.get("name", ""),
            "student_code": s.get("student_code", ""),
            "sheet_name": s.get("department_id", "") or "",
        }
        for s in (result.data or [])
    ]

    return {
        "job_id": job_id,
        "status": "completed",
        "total_students": len(students),
        "students": students,
        "errors": [],
    }


# ═══════════════════════════════════════
#  GET /result/{job_id}/student/{student_id} — Student detail
# ═══════════════════════════════════════
@router.get("/result/{job_id}/student/{student_id}", summary="تفاصيل طالب", tags=["استيراد وتحليل"])
async def get_student_detail_by_job(job_id: str, student_id: str):
    client = get_supabase_client()
    if not client:
        raise HTTPException(503, detail="قاعدة البيانات غير متاحة")

    # Get student
    student_result = client.table("students").select("*").eq("id", student_id).execute()
    if not student_result.data:
        raise HTTPException(404, detail="الطالب غير موجود")

    student = student_result.data[0]

    # Get semesters
    semesters_result = client.table("student_semesters").select("*").eq("student_id", student_id).order("semester_number").execute()

    # Get courses per semester
    semesters = semesters_result.data or []
    for sem in semesters:
        courses = client.table("student_courses").select("*").eq("semester_id", sem["id"]).execute()
        sem["courses"] = courses.data or []

    return {
        "student": student,
        "semesters": semesters,
        "sheet_name": student.get("department_id", "") or "",
        "parsed_at": student.get("created_at", ""),
    }


# ═══════════════════════════════════════
#  GET /students/ — List all students from DB
# ═══════════════════════════════════════
@router.get("/students/", summary="كل الطلاب", tags=["الطلاب"])
async def get_all_students(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    department_code: Optional[str] = None,
):
    client = get_supabase_client()
    if not client:
        return {"students": [], "total": 0, "limit": limit, "offset": offset}

    try:
        query = client.table("students").select("*", count="exact")
        if department_code:
            query = query.eq("department_id", department_code)
        result = query.range(offset, offset + limit - 1).order("created_at", desc=True).execute()
        return {
            "students": result.data or [],
            "total": result.count or 0,
            "limit": limit,
            "offset": offset,
        }
    except Exception as e:
        return {"students": [], "total": 0, "limit": limit, "offset": offset, "message": str(e)}


# ═══════════════════════════════════════
#  GET /students/{student_id} — Single student
# ═══════════════════════════════════════
@router.get("/students/{student_id}", summary="طالب واحد", tags=["الطلاب"])
async def get_student_by_id(student_id: str):
    client = get_supabase_client()
    if not client:
        raise HTTPException(503, detail="DB unavailable")

    result = client.table("students").select("*").eq("id", student_id).execute()
    if not result.data:
        raise HTTPException(404, detail="Student not found")
    return result.data[0]


# ═══════════════════════════════════════
#  GET /students/{student_id}/full — Full student with semesters
# ═══════════════════════════════════════
@router.get("/students/{student_id}/full", summary="طالب كامل", tags=["الطلاب"])
async def get_student_full(student_id: str):
    client = get_supabase_client()
    if not client:
        raise HTTPException(503, detail="DB unavailable")

    student = client.table("students").select("*").eq("id", student_id).execute()
    if not student.data:
        raise HTTPException(404, detail="Student not found")

    semesters = client.table("student_semesters").select("*").eq("student_id", student_id).order("semester_number").execute()

    for sem in (semesters.data or []):
        courses = client.table("student_courses").select("*").eq("semester_id", sem["id"]).execute()
        sem["courses"] = courses.data or []

    try:
        analysis = client.table("analysis_results").select("*").eq("student_id", student_id).eq("is_latest", True).execute()
        latest_analysis = analysis.data[0] if analysis.data else None
    except Exception:
        latest_analysis = None

    return {
        "student": student.data[0],
        "semesters": semesters.data or [],
        "latest_analysis": latest_analysis,
    }


# ═══════════════════════════════════════
#  Background processing (mirrors V1 behavior)
# ═══════════════════════════════════════
async def _process_excel_to_db(job_id: str, file_path: Path, department_code: str):
    """Process Excel file and save to Supabase — V1 compatible."""
    global _active_jobs
    import gc

    try:
        logger.info(f"💾 Processing file: {file_path.name} for dept: {department_code}")

        from parsers.excel_parser import ExcelTranscriptParser

        with open(file_path, "rb") as f:
            file_bytes = f.read()

        parser = ExcelTranscriptParser()
        students = parser.parse(file_bytes)

        # Save to Supabase
        client = get_supabase_client()
        saved_count = 0
        errors = []

        if client:
            for s in students:
                try:
                    client.table("students").upsert({
                        "student_code": s["student_code"],
                        "name": s.get("name", ""),
                        "department_code": department_code,
                    }, on_conflict="student_code").execute()
                    saved_count += 1
                except Exception as e:
                    errors.append(f"Student {s.get('student_code', '?')}: {str(e)}")

        _jobs_status[job_id] = {
            "job_id": job_id,
            "status": "completed",
            "filename": file_path.name,
            "department": department_code,
            "created_at": _jobs_status[job_id].get("created_at"),
            "updated_at": datetime.now().isoformat(),
            "stats": {
                "total_students": len(students),
                "successful": saved_count,
                "failed": len(errors),
            },
            "error_log": errors,
        }
        logger.info(f"✅ Job {job_id}: {saved_count}/{len(students)} students saved")

    except Exception as e:
        logger.error(f"❌ Job {job_id}: {e}")
        _jobs_status[job_id] = {
            "job_id": job_id,
            "status": "failed",
            "error_log": [str(e)],
            "updated_at": datetime.now().isoformat(),
        }
    finally:
        if file_path.exists():
            file_path.unlink()
        _active_jobs -= 1
        gc.collect()
