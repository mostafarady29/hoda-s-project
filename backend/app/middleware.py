# ═══════════════════════════════════════
# App — Middleware
# ═══════════════════════════════════════
import time
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.responses import JSONResponse

from core.config import settings
from core.logger import logger


def register_middleware(app: FastAPI):
    """Register all middleware."""

    # GZip compression
    app.add_middleware(GZipMiddleware, minimum_size=1000)

    # CORS
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.ALLOWED_ORIGINS,
        allow_credentials=False,
        allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
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
        if content_length and int(content_length) > settings.MAX_FILE_SIZE:
            return JSONResponse(
                status_code=413,
                content={
                    "error": "REQUEST_TOO_LARGE",
                    "detail": f"حجم الطلب كبير جداً. الحد الأقصى {settings.MAX_FILE_SIZE // (1024*1024)} MB",
                },
            )
        return await call_next(request)

    @app.middleware("http")
    async def log_requests(request: Request, call_next):
        logger.debug(f"→ {request.method} {request.url.path}")
        response = await call_next(request)
        logger.debug(f"← {response.status_code} {request.url.path}")
        return response
