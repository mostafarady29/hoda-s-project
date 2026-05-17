# ===== File: python_backend/config.py =====

import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()


class Config:
    # ── Paths
    BASE_DIR = Path(__file__).parent
    STORAGE_DIR = BASE_DIR / "storage"
    TEMP_UPLOADS = STORAGE_DIR / "temp_uploads"
    OUTPUT_DIR = STORAGE_DIR / "output"
    LOGS_DIR = BASE_DIR / "logs"
    JOBS_DIR = STORAGE_DIR / "jobs"

    # Create all dirs on import
    for _dir in [TEMP_UPLOADS, OUTPUT_DIR, LOGS_DIR, JOBS_DIR]:
        _dir.mkdir(parents=True, exist_ok=True)

    # ── Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "acadexa-secret-key-change-in-production")

    # ── CORS
    # على Railway/Flutter Web لازم نقبل كل الأصول
    ALLOWED_ORIGINS: list = ["*"]

    # ── File limits
    MAX_FILE_SIZE: int = int(os.getenv("MAX_FILE_SIZE", 50 * 1024 * 1024))   # 50 MB
    ALLOWED_EXTENSIONS: set = {".xlsx", ".xls"}

    # ── Concurrency
    MAX_CONCURRENT_JOBS: int = int(os.getenv("MAX_CONCURRENT_JOBS", 5))

    # ── Job retention
    JOB_RETENTION_HOURS: int = int(os.getenv("RESULT_RETENTION_HOURS", 24))
    JOB_RETENTION_DAYS: int = 7

    # ── Logging
    LOG_LEVEL: str = os.getenv("LOG_LEVEL", "INFO")

    # ── API
    API_V1_PREFIX: str = "/api/v1"

    # ── Server (Railway injects PORT automatically)
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", 8000))

    # ── JSON safety limit
    MAX_JSON_SIZE: int = 5 * 1024 * 1024   # 5 MB per response