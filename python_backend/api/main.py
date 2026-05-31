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
from api.routes import upload, students, curriculum, departments

# ─────────────────────────────────────────────────────────────
# Logging
logging.basicConfig(
    level=getattr(logging, Config.LOG_LEVEL),
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
)
logger = logging.getLogger("acadexa")

# ─────────────────────────────────────────────────────────────
# FastAPI app
app = FastAPI(
    title="Acadexa Backend API",
    description="نظام خبير للإرشاد الأكاديمي - كلية التربية النوعية جامعة كفرالشيخ",
    version="3.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",
)

# ─────────────────────────────────────────────────────────────
# Middlewares
app.add_middleware(GZipMiddleware, minimum_size=1000)

app.add_middleware(
    CORSMiddleware,
    allow_origins=Config.ALLOWED_ORIGINS,
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["X-Job-Id", "X-Processing-Time"],
    max_age=3600,
)


@app.middleware("http")
async def add_process_time_header(request: Request, call_next):
    start_time = time.perf_counter()
    response = await call_next(request)
    process_time = (time.perf_counter() - start_time) * 1000
    response.headers["X-Processing-Time"] = f"{process_time:.2f}ms"
    return response


@app.middleware("http")
async def limit_request_size(request: Request, call_next):
    content_length = request.headers.get("content-length")
    if content_length and int(content_length) > Config.MAX_FILE_SIZE:
        return JSONResponse(
            status_code=413,
            content={"detail": f"حجم الطلب كبير جداً. الحد الأقصى {Config.MAX_FILE_SIZE // (1024*1024)} MB"},
        )
    return await call_next(request)


# ─────────────────────────────────────────────────────────────
# Routers
app.include_router(upload.router, prefix=Config.API_V1_PREFIX, tags=["استيراد وتحليل"])
app.include_router(students.router, prefix=Config.API_V1_PREFIX, tags=["الطلاب"])
app.include_router(curriculum.router, prefix=Config.API_V1_PREFIX, tags=["اللوائح الدراسية"])
app.include_router(departments.router, prefix=Config.API_V1_PREFIX, tags=["الأقسام والبرامج"])


# ─────────────────────────────────────────────────────────────
# Core endpoints
@app.get("/health", tags=["النظام"])
async def health_check():
    return JSONResponse(status_code=200, content={
        "status": "healthy",
        "version": "3.0.0",
        "service": "Acadexa Expert System API",
    })


@app.get("/", tags=["النظام"])
async def root():
    return {
        "message": "🎓 Acadexa Expert System API",
        "version": "3.0.0",
        "docs": "/docs",
        "health": "/health",
        "endpoints": {
            "upload_excel": f"{Config.API_V1_PREFIX}/upload",
            "students": f"{Config.API_V1_PREFIX}/students",
            "analyze": f"{Config.API_V1_PREFIX}/analyze/{{student_id}}",
            "curriculum": f"{Config.API_V1_PREFIX}/plans",
            "departments": f"{Config.API_V1_PREFIX}/departments",
            "curriculum_api": {
                "plans": f"{Config.API_V1_PREFIX}/curriculum/plans",
                "plan_detail": f"{Config.API_V1_PREFIX}/curriculum/plans/{{plan_id}}",
                "courses": f"{Config.API_V1_PREFIX}/curriculum/plans/{{plan_id}}/courses",
                "elective_groups": f"{Config.API_V1_PREFIX}/curriculum/elective-groups",
                "grading_scales": f"{Config.API_V1_PREFIX}/curriculum/grading-scales",
            }
        },
    }


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