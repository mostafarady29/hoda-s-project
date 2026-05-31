# ===== File: api/routes/upload.py (معدل بالكامل) =====

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


@router.post("/upload", summary="رفع ملف Excel")
async def upload_excel(
    background_tasks: BackgroundTasks,
    request: Request,
    file: UploadFile = File(...),
    department_code: str = Form(...),  # إجباري الآن
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
            "message": "تم استلام الملف وجاري المعالجة والحفظ في قاعدة البيانات",
            "department_code": department_code,
            "filename": file.filename
        },
    )


@router.get("/upload/status/{job_id}", summary="حالة المعالجة")
async def get_upload_status(job_id: str):
    """Get processing status - simplified version"""
    # For now, return pending (we can implement proper status tracking later)
    return {
        "job_id": job_id,
        "status": "processing",
        "message": "جاري المعالجة..."
    }


async def process_excel_file(
    job_id: str,
    file_path: Path,
    department_code: str,
    client_ip: str,
    file_size: int,
):
    global _active_jobs
    audit_logger = AuditLogger(Config.LOGS_DIR)

    try:
        print(f"📊 Processing file: {file_path.name} for department: {department_code}")
        
        # Parse and save to Supabase
        parser = ExcelParser(file_path, department_code)
        students_data, errors = parser.parse_all_students()
        stats = parser.get_stats() if hasattr(parser, 'get_stats') else {"students": 0, "courses": 0}
        
        print(f"✅ Import completed: {stats}")
        
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