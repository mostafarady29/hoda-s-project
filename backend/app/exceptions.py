# ═══════════════════════════════════════
# App — Exception Handlers
# ═══════════════════════════════════════
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

from core.exceptions import (
    AcadexaException,
    EntityNotFoundError,
    ValidationError,
    AuthenticationError,
    AuthorizationError,
    FileProcessingError,
)
from core.logger import logger


def register_exception_handlers(app: FastAPI):
    """Register global exception handlers."""

    @app.exception_handler(EntityNotFoundError)
    async def not_found_handler(request: Request, exc: EntityNotFoundError):
        return JSONResponse(status_code=404, content={"error": exc.code, "detail": exc.message})

    @app.exception_handler(ValidationError)
    async def validation_handler(request: Request, exc: ValidationError):
        return JSONResponse(
            status_code=422,
            content={"error": exc.code, "detail": exc.message, "details": exc.details},
        )

    @app.exception_handler(AuthenticationError)
    async def auth_handler(request: Request, exc: AuthenticationError):
        return JSONResponse(status_code=401, content={"error": exc.code, "detail": exc.message})

    @app.exception_handler(AuthorizationError)
    async def forbidden_handler(request: Request, exc: AuthorizationError):
        return JSONResponse(status_code=403, content={"error": exc.code, "detail": exc.message})

    @app.exception_handler(FileProcessingError)
    async def file_error_handler(request: Request, exc: FileProcessingError):
        return JSONResponse(
            status_code=400,
            content={"error": exc.code, "detail": exc.message, "details": exc.details},
        )

    @app.exception_handler(AcadexaException)
    async def acadexa_handler(request: Request, exc: AcadexaException):
        return JSONResponse(
            status_code=400,
            content={"error": exc.code, "detail": exc.message},
        )

    @app.exception_handler(Exception)
    async def global_handler(request: Request, exc: Exception):
        logger.error(f"Unhandled error on {request.url}: {exc}", exc_info=True)
        from core.config import settings
        return JSONResponse(
            status_code=500,
            content={
                "error": "INTERNAL_ERROR",
                "detail": str(exc) if settings.LOG_LEVEL == "DEBUG" else "خطأ داخلي — تواصل مع الدعم الفني",
            },
        )
