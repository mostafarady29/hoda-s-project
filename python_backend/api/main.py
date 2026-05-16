# ===== File: python_backend/api/main.py =====
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from config import Config
from .routes import upload

# Setup logging
logging.basicConfig(
    level=getattr(logging, Config.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Acadexa Backend API",
    description="Academic Records Processing System",
    version="2.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(
    upload.router,
    prefix=f"{Config.API_V1_PREFIX}",
    tags=["Excel Processing"]
)

@app.get("/health")
async def health_check(request: Request):
    """Health check endpoint"""
    return JSONResponse(
        status_code=200,
        content={
            "status": "healthy",
            "version": "2.0.0",
            "message": "Acadexa API is running"
        }
    )

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "🎓 Acadexa Academic Records API",
        "version": "2.0.0",
        "endpoints": {
            "upload": f"{Config.API_V1_PREFIX}/upload",
            "job_status": f"{Config.API_V1_PREFIX}/job/{{job_id}}",
            "result": f"{Config.API_V1_PREFIX}/result/{{job_id}}",
            "docs": "/docs",
            "health": "/health"
        }
    }

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Global error handler"""
    logger.error(f"Global error: {str(exc)}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "detail": str(exc) if Config.LOG_LEVEL == "DEBUG" else "Contact support"
        }
    )