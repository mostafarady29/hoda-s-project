# ===== File: python_backend/api/routes/upload.py =====
from fastapi import APIRouter, UploadFile, File, HTTPException, BackgroundTasks, Request
from fastapi.responses import JSONResponse
from pathlib import Path
import shutil
import time
import json
from datetime import datetime
import sys

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from config import Config
from services.job_manager import JobManager, JobStatus
from core.parser.excel_parser import ExcelParser
from core.security.validators import ExcelValidator
from core.security.audit_logger import AuditLogger

router = APIRouter()

# Initialize services
job_manager = JobManager(Config.STORAGE_DIR)
audit_logger = AuditLogger(Config.LOGS_DIR)

# Track concurrent jobs
_active_jobs = 0
_max_concurrent = 5

@router.post("/upload")
async def upload_excel(
    background_tasks: BackgroundTasks,
    request: Request,
    file: UploadFile = File(...),
    department: str = ""
):
    """Upload Excel file for processing"""
    global _active_jobs
    
    # Validate file extension
    file_extension = Path(file.filename).suffix.lower()
    if file_extension not in Config.ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Allowed: {Config.ALLOWED_EXTENSIONS}"
        )
    
    # Validate file size
    file.file.seek(0, 2)
    file_size = file.file.tell()
    file.file.seek(0)
    
    if file_size > Config.MAX_FILE_SIZE:
        raise HTTPException(
            status_code=400,
            detail=f"File too large. Max size: {Config.MAX_FILE_SIZE // 1024 // 1024}MB"
        )
    
    # Save uploaded file
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    temp_file_path = Config.TEMP_UPLOADS / f"{timestamp}_{file.filename}"
    
    try:
        with open(temp_file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to save file: {str(e)}")
    
    # Create job
    client_ip = request.client.host if request.client else "unknown"
    job_id = job_manager.create_job(file.filename, temp_file_path, department)
    
    # Start background processing
    _active_jobs += 1
    background_tasks.add_task(
        process_excel_file,
        job_id,
        temp_file_path,
        department,
        client_ip
    )
    
    return JSONResponse(
        status_code=202,
        content={
            "job_id": job_id,
            "status": JobStatus.PENDING,
            "message": "File uploaded successfully. Processing in background."
        }
    )

@router.get("/job/{job_id}")
async def get_job_status(job_id: str):
    """Check job status"""
    job = job_manager.get_job(job_id)
    
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    
    response = {
        "job_id": job_id,
        "status": job["status"],
        "created_at": job["created_at"],
        "updated_at": job["updated_at"]
    }
    
    if job["status"] == JobStatus.COMPLETED:
        response["result_url"] = f"/api/v1/result/{job_id}"
        response["stats"] = job.get("stats", {})
    
    elif job["status"] == JobStatus.FAILED:
        response["error"] = job.get("error_log", ["Unknown error"])[-1:]
    
    elif job["status"] == JobStatus.PARTIAL_SUCCESS:
        response["stats"] = job.get("stats", {})
        response["warnings"] = job.get("error_log", [])[:5]
    
    return response

@router.get("/result/{job_id}")
async def get_result(job_id: str, request: Request):
    """Get parsed result"""
    job = job_manager.get_job(job_id)
    
    if not job:
        raise HTTPException(status_code=404, detail="Job not found")
    
    if job["status"] not in [JobStatus.COMPLETED, JobStatus.PARTIAL_SUCCESS]:
        raise HTTPException(
            status_code=409,
            detail=f"Result not ready. Current status: {job['status']}"
        )
    
    result_file = Path(job["result_file"]) if job.get("result_file") else None
    
    if not result_file or not result_file.exists():
        raise HTTPException(status_code=404, detail="Result file not found")
    
    try:
        with open(result_file, 'r', encoding='utf-8') as f:
            result_data = json.load(f)
        
        return result_data
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to read result: {str(e)}")

async def process_excel_file(job_id: str, file_path: Path, department: str, client_ip: str):
    """Process Excel file in background"""
    global _active_jobs
    start_time = time.time()
    
    try:
        # Update status
        job_manager.update_job(job_id, status=JobStatus.PROCESSING)
        
        # Parse Excel
        parser = ExcelParser(file_path, department)
        students_data, parsing_errors = parser.parse_all_students()
        
        # Prepare result
        result = {
            "department": department or "unknown",
            "total_students": len(students_data),
            "students": students_data,
            "parsing_summary": {
                "total_sheets_processed": len(students_data) + len(parsing_errors),
                "successful_parses": len(students_data),
                "failed_parses": len(parsing_errors),
                "has_errors": len(parsing_errors) > 0
            },
            "errors": parsing_errors if parsing_errors else None
        }
        
        # Save result
        result_file = Config.OUTPUT_DIR / f"{job_id}_result.json"
        with open(result_file, 'w', encoding='utf-8') as f:
            json.dump(result, f, indent=2, ensure_ascii=False)
        
        # Determine status
        if len(students_data) == 0:
            status = JobStatus.FAILED
        elif len(parsing_errors) > 0:
            status = JobStatus.PARTIAL_SUCCESS
        else:
            status = JobStatus.COMPLETED
        
        # Update job
        job_manager.update_job(
            job_id,
            status=status,
            result_file=str(result_file),
            stats={
                "total_students": len(students_data),
                "successful": len(students_data),
                "failed": len(parsing_errors)
            },
            error_log=parsing_errors[:20]
        )
        
        # Cleanup temp file
        if file_path.exists():
            file_path.unlink()
            
    except Exception as e:
        error_msg = str(e)
        job_manager.update_job(
            job_id,
            status=JobStatus.FAILED,
            error_log=[error_msg]
        )
    
    finally:
        _active_jobs -= 1
        duration_ms = (time.time() - start_time) * 1000