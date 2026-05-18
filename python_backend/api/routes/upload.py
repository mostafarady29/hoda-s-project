from fastapi import APIRouter, UploadFile, File, HTTPException, BackgroundTasks, Request, Query, Form
from fastapi.responses import JSONResponse
from pathlib import Path
import shutil
import json
from datetime import datetime
import sys
import gc
import asyncio

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

from config import Config
from services.job_manager import JobManager, JobStatus
from core.parser.excel_parser import ExcelParser
from core.security.audit_logger import AuditLogger

router = APIRouter()

job_manager = JobManager(Config.STORAGE_DIR)
audit_logger = AuditLogger(Config.LOGS_DIR)

_active_jobs = 0


@router.post("/upload", summary="رفع ملف Excel")
async def upload_excel(
    background_tasks: BackgroundTasks,
    request: Request,
    file: UploadFile = File(...),
    department: str = Form(default=""),
):
    global _active_jobs

    ext = Path(file.filename).suffix.lower()
    if ext not in Config.ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="نوع الملف غير مدعوم. المسموح: xlsx, xls")

    file.file.seek(0, 2)
    size = file.file.tell()
    file.file.seek(0)

    if size > Config.MAX_FILE_SIZE:
        raise HTTPException(
            status_code=413,
            detail=f"حجم الملف كبير جداً. الحد الأقصى {Config.MAX_FILE_SIZE // (1024*1024)} MB",
        )

    if _active_jobs >= Config.MAX_CONCURRENT_JOBS:
        raise HTTPException(
            status_code=429,
            detail="الخادم مشغول. حاول مرة أخرى بعد قليل.",
        )

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    safe_name = "".join(c for c in file.filename if c.isalnum() or c in "._-")
    temp_path = Config.TEMP_UPLOADS / f"{timestamp}_{safe_name}"

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
        client_ip,
        size,
    )

    return JSONResponse(
        status_code=202,
        content={
            "job_id": job_id,
            "status": JobStatus.PENDING,
            "message": "تم استلام الملف وجارٍ المعالجة",
        },
    )


@router.get("/job/{job_id}", summary="حالة المهمة")
async def get_job_status(job_id: str):
    job = job_manager.get_job(job_id)

    if not job:
        raise HTTPException(status_code=404, detail="المهمة غير موجودة")

    response = {
        "job_id": job_id,
        "status": job["status"],
        "filename": job.get("filename"),
        "department": job.get("department"),
        "created_at": job.get("created_at"),
        "updated_at": job.get("updated_at"),
    }

    if job["status"] in [
        JobStatus.COMPLETED,
        JobStatus.PARTIAL_SUCCESS,
        JobStatus.FAILED,
    ]:
        response["stats"] = job.get("stats", {})
        if job.get("error_log"):
            response["error_log"] = job["error_log"]

    return response


@router.get("/result/{job_id}", summary="نتيجة المعالجة - قائمة الطلاب")
async def get_result(job_id: str):
    job = job_manager.get_job(job_id)

    if not job:
        raise HTTPException(status_code=404, detail="المهمة غير موجودة")

    if job["status"] == JobStatus.FAILED:
        raise HTTPException(
            status_code=422,
            detail={
                "message": "فشلت عملية المعالجة",
                "errors": job.get("error_log", []),
            },
        )

    if job["status"] not in [JobStatus.COMPLETED, JobStatus.PARTIAL_SUCCESS]:
        raise HTTPException(
            status_code=409,
            detail=f"المهمة لم تكتمل بعد. الحالة الحالية: {job['status']}",
        )

    index_file = Config.OUTPUT_DIR / job_id / "index.json"

    if not index_file.exists():
        raise HTTPException(status_code=404, detail="ملف النتائج غير موجود")

    with open(index_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    return {
        "job_id": job_id,
        "status": job["status"],
        "department": data.get("department"),
        "total_students": data.get("total_students", 0),
        "students": data.get("students", []),
        "errors": data.get("errors", []),
    }


@router.get("/result/{job_id}/student/{student_id}", summary="بيانات طالب واحد بالتفصيل")
async def get_student_detail(job_id: str, student_id: str):
    if ".." in student_id or "/" in student_id or "\\" in student_id:
        raise HTTPException(status_code=400, detail="student_id غير صالح")

    job = job_manager.get_job(job_id)

    if not job:
        raise HTTPException(status_code=404, detail="المهمة غير موجودة")

    if job["status"] not in [JobStatus.COMPLETED, JobStatus.PARTIAL_SUCCESS]:
        raise HTTPException(status_code=409, detail="المهمة لم تكتمل بعد")

    student_file = Config.OUTPUT_DIR / job_id / "students" / f"{student_id}.json"

    if not student_file.exists():
        raise HTTPException(
            status_code=404,
            detail=f"الطالب {student_id} غير موجود في هذه المهمة",
        )

    with open(student_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    return data


@router.get("/result/{job_id}/students/batch", summary="جلب بيانات مجموعة طلاب دفعة واحدة")
async def get_students_batch(
    job_id: str,
    ids: str = Query(..., description="student IDs مفصولة بفاصلة"),
):
    job = job_manager.get_job(job_id)

    if not job:
        raise HTTPException(status_code=404, detail="المهمة غير موجودة")

    if job["status"] not in [JobStatus.COMPLETED, JobStatus.PARTIAL_SUCCESS]:
        raise HTTPException(status_code=409, detail="المهمة لم تكتمل بعد")

    student_ids = [sid.strip() for sid in ids.split(",") if sid.strip()]

    if len(student_ids) > 50:
        raise HTTPException(status_code=400, detail="الحد الأقصى للدفعة الواحدة 50 طالب")

    results = {}
    not_found = []

    students_dir = Config.OUTPUT_DIR / job_id / "students"

    for student_id in student_ids:
        if ".." in student_id or "/" in student_id:
            continue

        student_file = students_dir / f"{student_id}.json"

        if student_file.exists():
            with open(student_file, "r", encoding="utf-8") as f:
                results[student_id] = json.load(f)
        else:
            not_found.append(student_id)

    return {
        "job_id": job_id,
        "found": len(results),
        "not_found": not_found,
        "students": results,
    }


@router.delete("/job/{job_id}", summary="حذف مهمة ونتائجها")
async def delete_job(job_id: str):
    job = job_manager.get_job(job_id)

    if not job:
        raise HTTPException(status_code=404, detail="المهمة غير موجودة")

    import shutil as _shutil

    job_output = Config.OUTPUT_DIR / job_id

    if job_output.exists():
        _shutil.rmtree(job_output)

    job_manager.delete_job(job_id)

    return {"message": f"تم حذف المهمة {job_id} بنجاح"}


async def process_excel_file(
    job_id: str,
    file_path: Path,
    department: str,
    client_ip: str,
    file_size: int,
):
    global _active_jobs

    try:
        job_manager.update_job(job_id, status=JobStatus.PROCESSING)

        loop = asyncio.get_event_loop()

        students_data, parsing_errors = await loop.run_in_executor(
            None,
            _parse_excel_sync,
            file_path,
            department,
        )

        job_dir = Config.OUTPUT_DIR / job_id
        students_dir = job_dir / "students"
        students_dir.mkdir(parents=True, exist_ok=True)

        index = []

        for s in students_data:
            student_id = s["student"]["id"]

            student_file = students_dir / f"{student_id}.json"

            with open(student_file, "w", encoding="utf-8") as f:
                json.dump(s, f, ensure_ascii=False)

            index.append(
                {
                    "student_id": student_id,
                    "name": s["student"]["name"],
                    "sheet_name": s["sheet_name"],
                }
            )

        index_file = job_dir / "index.json"

        with open(index_file, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "job_id": job_id,
                    "department": department,
                    "total_students": len(students_data),
                    "students": index,
                    "errors": parsing_errors,
                },
                f,
                ensure_ascii=False,
                indent=2,
            )

        status = JobStatus.COMPLETED if not parsing_errors else JobStatus.PARTIAL_SUCCESS

        job_manager.update_job(
            job_id,
            status=status,
            result_file=str(index_file),
            stats={
                "total_students": len(students_data),
                "successful": len(students_data),
                "failed": len(parsing_errors),
            },
        )

        audit_logger.log_upload(
            job_id=job_id,
            filename=file_path.name,
            file_size=file_size,
            student_count=len(students_data),
            department=department,
            ip_address=client_ip,
        )

        del students_data
        del parsing_errors
        gc.collect()

    except Exception as e:
        job_manager.update_job(
            job_id,
            status=JobStatus.FAILED,
            error_log=[str(e)],
            stats={
                "total_students": 0,
                "successful": 0,
                "failed": 0,
            },
        )

    finally:
        try:
            if file_path.exists():
                file_path.unlink()
        except Exception:
            pass

        _active_jobs -= 1
        gc.collect()


def _parse_excel_sync(file_path: Path, department: str):
    parser = ExcelParser(file_path, department)
    return parser.parse_all_students()