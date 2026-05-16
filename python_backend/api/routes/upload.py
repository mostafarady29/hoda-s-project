# ===== File: python_backend/api/routes/upload.py =====

from fastapi import APIRouter, UploadFile, File, HTTPException, BackgroundTasks, Request
from pathlib import Path
import shutil
import json
from datetime import datetime
import sys
import gc

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from config import Config
from services.job_manager import JobManager, JobStatus
from core.parser.excel_parser import ExcelParser

router = APIRouter()

job_manager = JobManager(Config.STORAGE_DIR)

_active_jobs = 0
_max_concurrent = Config.MAX_CONCURRENT_JOBS


@router.post("/upload")
async def upload_excel(
    background_tasks: BackgroundTasks,
    request: Request,
    file: UploadFile = File(...),
    department: str = ""
):

    global _active_jobs

    ext = Path(file.filename).suffix.lower()

    if ext not in Config.ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Invalid file type")

    file.file.seek(0, 2)
    size = file.file.tell()
    file.file.seek(0)

    if size > Config.MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large")

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    temp_path = Config.TEMP_UPLOADS / f"{timestamp}_{file.filename}"

    with open(temp_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    job_id = job_manager.create_job(file.filename, temp_path, department)

    client_ip = request.client.host if request.client else "unknown"

    _active_jobs += 1

    background_tasks.add_task(
        process_excel_file,
        job_id,
        temp_path,
        department,
        client_ip
    )

    return {
        "job_id": job_id,
        "status": JobStatus.PENDING
    }


@router.get("/job/{job_id}")
async def get_job_status(job_id: str):

    job = job_manager.get_job(job_id)

    if not job:
        raise HTTPException(status_code=404, detail="Job not found")

    return job


@router.get("/result/{job_id}")
async def get_result(job_id: str):

    job = job_manager.get_job(job_id)

    if not job:
        raise HTTPException(status_code=404)

    if job["status"] not in [JobStatus.COMPLETED, JobStatus.PARTIAL_SUCCESS]:
        raise HTTPException(status_code=409, detail="Not ready")

    index_file = Config.OUTPUT_DIR / job_id / "index.json"

    if not index_file.exists():
        raise HTTPException(status_code=404)

    with open(index_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    return {
        "job_id": job_id,
        "department": data.get("department"),
        "total_students": data.get("total_students"),
        "students": data.get("students"),
        "errors": data.get("errors", [])
    }


# =========================
# Background processing
# =========================

async def process_excel_file(job_id: str, file_path: Path, department: str, client_ip: str):

    global _active_jobs

    try:
        job_manager.update_job(job_id, status=JobStatus.PROCESSING)

        parser = ExcelParser(file_path, department)
        students_data, parsing_errors = parser.parse_all_students()

        job_dir = Config.OUTPUT_DIR / job_id
        students_dir = job_dir / "students"
        students_dir.mkdir(parents=True, exist_ok=True)

        index = []

        for s in students_data:

            student_id = s["student"]["id"]

            with open(students_dir / f"{student_id}.json", "w", encoding="utf-8") as f:
                json.dump(s, f, ensure_ascii=False)

            index.append({
                "student_id": student_id,
                "name": s["student"]["name"],
                "sheet_name": s["sheet_name"]
            })

        index_file = job_dir / "index.json"

        with open(index_file, "w", encoding="utf-8") as f:
            json.dump({
                "job_id": job_id,
                "department": department,
                "total_students": len(students_data),
                "students": index,
                "errors": parsing_errors
            }, f, ensure_ascii=False, indent=2)

        status = JobStatus.COMPLETED if not parsing_errors else JobStatus.PARTIAL_SUCCESS

        job_manager.update_job(
            job_id,
            status=status,
            result_file=str(index_file),
            stats={
                "total_students": len(students_data),
                "failed": len(parsing_errors)
            }
        )

        del students_data
        del parsing_errors
        gc.collect()

        if file_path.exists():
            file_path.unlink()

    except Exception as e:
        job_manager.update_job(
            job_id,
            status=JobStatus.FAILED,
            error_log=[str(e)]
        )

    finally:
        _active_jobs -= 1
        gc.collect()