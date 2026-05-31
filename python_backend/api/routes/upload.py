from fastapi import APIRouter, UploadFile, File, HTTPException, BackgroundTasks, Request, Form
from fastapi.responses import JSONResponse
from pathlib import Path
import shutil
import uuid
from datetime import datetime
import sys
import gc
import asyncio

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from config import Config
from core.parser.excel_parser import ExcelParser
from core.security.validators import ExcelValidator
from core.security.audit_logger import AuditLogger

router = APIRouter()

# Simplified job tracking (in-memory, since we're saving directly to Supabase)
_active_jobs = 0
_jobs_status = {}  # Simple job status tracking


@router.post("/upload", summary="رفع ملف Excel (JSON output only)")
async def upload_excel(
    background_tasks: BackgroundTasks,
    request: Request,
    file: UploadFile = File(...),
    department_code: str = Form(...),
):
    global _active_jobs

    # 1. Validate file extension
    ext = Path(file.filename).suffix.lower()
    if ext not in Config.ALLOWED_EXTENSIONS:
        raise HTTPException(400, detail=f"نوع الملف غير مدعوم. المسموح: {Config.ALLOWED_EXTENSIONS}")
    
    # 2. Check file size
    file.file.seek(0, 2)
    size = file.file.tell()
    file.file.seek(0)
    
    if size > Config.MAX_FILE_SIZE:
        raise HTTPException(413, detail=f"حجم الملف كبير جداً. الحد الأقصى {Config.MAX_FILE_SIZE // (1024*1024)} MB")

    # 3. Check concurrent jobs limit
    if _active_jobs >= Config.MAX_CONCURRENT_JOBS:
        raise HTTPException(429, detail="الخادم مشغول. حاول مرة أخرى بعد قليل.")

    # 4. Save temp file
    temp_path = Config.TEMP_UPLOADS / f"{uuid.uuid4()}{ext}"
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 5. Validate Excel structure
    is_valid, errors = ExcelValidator.validate_file(temp_path)
    if not is_valid:
        temp_path.unlink()
        raise HTTPException(400, detail={"errors": errors})

    # 6. Generate job ID
    job_id = str(uuid.uuid4())
    client_ip = request.client.host if request.client else "unknown"

    _active_jobs += 1
    _jobs_status[job_id] = {"status": "processing", "started_at": datetime.now().isoformat()}

    # 7. Process in background
    background_tasks.add_task(
        process_excel_file,
        job_id,
        temp_path,
        department_code,
        client_ip,
        size,
    )

    return JSONResponse(
        status_code=202,
        content={
            "job_id": job_id,
            "status": "processing",
            "message": "تم استلام الملف وجاري المعالجة",
            "department_code": department_code,
            "filename": file.filename
        },
    )


@router.post("/upload-to-db", summary="رفع ملف Excel وحفظه في قاعدة البيانات")
async def upload_to_database(
    background_tasks: BackgroundTasks,
    request: Request,
    file: UploadFile = File(...),
    department_code: str = Form(...),
):
    """
    Upload Excel file and save directly to Supabase database.
    This is the recommended endpoint for production use.
    """
    global _active_jobs

    # 1. Validate file extension
    ext = Path(file.filename).suffix.lower()
    if ext not in Config.ALLOWED_EXTENSIONS:
        raise HTTPException(400, detail=f"نوع الملف غير مدعوم. المسموح: {Config.ALLOWED_EXTENSIONS}")
    
    # 2. Check file size
    file.file.seek(0, 2)
    size = file.file.tell()
    file.file.seek(0)
    
    if size > Config.MAX_FILE_SIZE:
        raise HTTPException(413, detail=f"حجم الملف كبير جداً. الحد الأقصى {Config.MAX_FILE_SIZE // (1024*1024)} MB")

    # 3. Check concurrent jobs limit
    if _active_jobs >= Config.MAX_CONCURRENT_JOBS:
        raise HTTPException(429, detail="الخادم مشغول. حاول مرة أخرى بعد قليل.")

    # 4. Save temp file
    temp_path = Config.TEMP_UPLOADS / f"{uuid.uuid4()}{ext}"
    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # 5. Validate Excel structure
    is_valid, errors = ExcelValidator.validate_file(temp_path)
    if not is_valid:
        temp_path.unlink()
        raise HTTPException(400, detail={"errors": errors})

    # 6. Generate job ID
    job_id = str(uuid.uuid4())
    client_ip = request.client.host if request.client else "unknown"

    _active_jobs += 1
    _jobs_status[job_id] = {"status": "processing", "started_at": datetime.now().isoformat()}

    # 7. Process in background (saving to DB)
    background_tasks.add_task(
        process_excel_to_db,
        job_id,
        temp_path,
        department_code,
        client_ip,
        size,
    )

    return JSONResponse(
        status_code=202,
        content={
            "job_id": job_id,
            "status": "processing",
            "message": "تم استلام الملف وجاري المعالجة والحفظ في قاعدة البيانات",
            "department_code": department_code,
            "filename": file.filename
        },
    )


@router.get("/upload/status/{job_id}", summary="حالة المعالجة")
async def get_upload_status(job_id: str):
    """Get processing status for a job"""
    status = _jobs_status.get(job_id, {"status": "not_found"})
    return status


async def process_excel_file(
    job_id: str,
    file_path: Path,
    department_code: str,
    client_ip: str,
    file_size: int,
):
    """Process Excel file and output JSON (legacy mode)"""
    global _active_jobs
    audit_logger = AuditLogger(Config.LOGS_DIR)

    try:
        print(f"📊 Processing file (JSON mode): {file_path.name} for department: {department_code}")
        
        # Parse Excel
        parser = ExcelParser(file_path, department_code)
        students_data, errors = parser.parse_all_students()
        stats = parser.get_stats()
        
        print(f"✅ Parse completed: {stats['students']} students, {stats['courses']} courses")
        
        _jobs_status[job_id] = {
            "status": "completed",
            "stats": stats,
            "errors": errors,
            "completed_at": datetime.now().isoformat()
        }
        
        # Log success
        audit_logger.log_upload(
            job_id=job_id,
            filename=file_path.name,
            file_size=file_size,
            student_count=stats.get("students", 0),
            department=department_code,
            ip_address=client_ip,
        )
        
    except Exception as e:
        print(f"❌ Error processing file: {e}")
        _jobs_status[job_id] = {
            "status": "failed",
            "error": str(e),
            "completed_at": datetime.now().isoformat()
        }
        audit_logger.log_error(
            job_id=job_id,
            sheet_name="all",
            error_type="processing_error",
            error_message=str(e)
        )
        
    finally:
        # Clean up temp file
        if file_path.exists():
            file_path.unlink()
        
        _active_jobs -= 1
        gc.collect()


async def process_excel_to_db(
    job_id: str,
    file_path: Path,
    department_code: str,
    client_ip: str,
    file_size: int,
):
    """Process Excel file and save directly to Supabase database"""
    global _active_jobs
    audit_logger = AuditLogger(Config.LOGS_DIR)

    try:
        print(f"💾 Processing file (DB mode): {file_path.name} for department: {department_code}")
        
        # Parse Excel and save to Supabase
        parser = ExcelParser(file_path, department_code)
        students_data, errors = parser.parse_all_students()
        stats = parser.get_stats()
        
        print(f"✅ DB Save completed: {stats['students']} students, {stats['courses']} courses saved")
        
        _jobs_status[job_id] = {
            "status": "completed",
            "stats": stats,
            "errors": errors,
            "completed_at": datetime.now().isoformat()
        }
        
        # Log success
        audit_logger.log_upload(
            job_id=job_id,
            filename=file_path.name,
            file_size=file_size,
            student_count=stats.get("students", 0),
            department=department_code,
            ip_address=client_ip,
        )
        
    except Exception as e:
        print(f"❌ Error processing file to DB: {e}")
        _jobs_status[job_id] = {
            "status": "failed",
            "error": str(e),
            "completed_at": datetime.now().isoformat()
        }
        audit_logger.log_error(
            job_id=job_id,
            sheet_name="all",
            error_type="db_save_error",
            error_message=str(e)
        )
        
    finally:
        # Clean up temp file
        if file_path.exists():
            file_path.unlink()
        
        _active_jobs -= 1
        gc.collect()