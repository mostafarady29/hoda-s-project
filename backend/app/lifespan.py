# ═══════════════════════════════════════
# App — Lifespan & App Factory
# ═══════════════════════════════════════
from contextlib import asynccontextmanager
from fastapi import FastAPI

from core.config import settings
from core.logger import logger
from app.middleware import register_middleware
from app.exceptions import register_exception_handlers
from app.dependencies import init_services, shutdown_services
from api.router import api_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events."""
    logger.info("🚀 Starting Acadexa Backend V2...")
    await init_services()
    yield
    logger.info("🛑 Shutting down Acadexa Backend V2...")
    await shutdown_services()


def create_app() -> FastAPI:
    """Application factory."""
    app = FastAPI(
        title="Acadexa Backend API V2",
        description="نظام خبير للإرشاد الأكاديمي — Clean Architecture + DDD",
        version="2.0.0",
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )

    # Register middleware
    register_middleware(app)

    # Register exception handlers
    register_exception_handlers(app)

    # Include all API routes
    app.include_router(api_router, prefix=settings.API_V1_PREFIX)

    # Health check
    @app.get("/health", tags=["النظام"])
    async def health_check():
        return {
            "status": "healthy",
            "version": "2.0.0",
            "service": "Acadexa Expert System API V2",
        }

    @app.get("/", tags=["النظام"])
    async def root():
        return {
            "message": "🎓 Acadexa Expert System API V2",
            "version": "2.0.0",
            "docs": "/docs",
            "health": "/health",
        }

    return app
