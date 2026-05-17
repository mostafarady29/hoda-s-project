# ===== File: python_backend/api/main.py =====

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse
import logging
import time
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from config import Config
from .routes import upload

# ─────────────────────────────────────────────
# Logging
# ─────────────────────────────────────────────
logging.basicConfig(
    level=getattr(logging, Config.LOG_LEVEL),
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("acadexa")

# ─────────────────────────────────────────────
# FastAPI app
# ─────────────────────────────────────────────
app = FastAPI(
    title="Acadexa Backend API",
    description="نظام معالجة السجلات الأكاديمية - كلية التربية النوعية جامعة كفرالشيخ",
    version="2.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# ─────────────────────────────────────────────
# Middlewares
# ─────────────────────────────────────────────

# 1. GZip compression (reduces response size ~60%)
app.add_middleware(GZipMiddleware, minimum_size=1000)

# 2. CORS — مفتوح للكل في dev, محدود في production
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],          # Railway + Flutter Web + Mobile
    allow_credentials=False,      # لازم False لما allow_origins="*"
    allow_methods=["GET", "POST", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["X-Job-Id", "X-Processing-Time"],
    max_age=3600,
)

# 3. Request timing middleware
@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.perf_counter()
    response = await call_next(request)
    process_time = (time.perf_counter() - start_time) * 1000
    response.headers["X-Processing-Time"] = f"{process_time:.2f}ms"
    return response

# 4. Request size limit middleware
@app.middleware("http")
async def limit_request_size(request: Request, call_next):
    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > Config.MAX_FILE_SIZE:
        return JSONResponse(
            status_code=413,
            content={"detail": f"حجم الطلب كبير جداً. الحد الأقصى {Config.MAX_FILE_SIZE // (1024*1024)} MB"},
        )
    return await call_next(request)


# ─────────────────────────────────────────────
# Routers
# ─────────────────────────────────────────────
app.include_router(
    upload.router,
    prefix=Config.API_V1_PREFIX,
    tags=["معالجة ملفات Excel"],
)


# ─────────────────────────────────────────────
# Core endpoints
# ─────────────────────────────────────────────
@app.get("/health", tags=["النظام"], summary="فحص حالة الخادم")
async def health_check():
    return JSONResponse(
        status_code=200,
        content={
            "status": "healthy",
            "version": "2.1.0",
            "service": "Acadexa Academic Records API",
        },
    )


@app.get("/", tags=["النظام"], summary="الصفحة الرئيسية")
async def root():
    return {
        "message": "🎓 Acadexa Academic Records API",
        "version": "2.1.0",
        "docs": "/docs",
        "health": "/health",
        "endpoints": {
            "upload_excel":     f"{Config.API_V1_PREFIX}/upload          [POST]",
            "job_status":       f"{Config.API_V1_PREFIX}/job/{{job_id}}    [GET]",
            "result_index":     f"{Config.API_V1_PREFIX}/result/{{job_id}} [GET]",
            "student_detail":   f"{Config.API_V1_PREFIX}/result/{{job_id}}/student/{{student_id}} [GET]",
            "students_batch":   f"{Config.API_V1_PREFIX}/result/{{job_id}}/students/batch?ids=id1,id2 [GET]",
            "delete_job":       f"{Config.API_V1_PREFIX}/job/{{job_id}}    [DELETE]",
        },
    }


# ─────────────────────────────────────────────
# Global error handler
# ─────────────────────────────────────────────
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.error(f"Unhandled error on {request.url}: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": "خطأ داخلي في الخادم",
            "detail": str(exc) if Config.LOG_LEVEL == "DEBUG" else "تواصل مع الدعم الفني",
        },
    )