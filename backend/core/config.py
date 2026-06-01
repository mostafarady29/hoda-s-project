# ═══════════════════════════════════════
# Core — Configuration
# ═══════════════════════════════════════
import os
from pathlib import Path
from typing import Optional, List
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import Field


class Settings(BaseSettings):
    """Centralized application settings with validation."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",  # Ignore extra env vars not defined here
    )

    # ── Paths (computed after init)
    BASE_DIR: Path = Path(__file__).parent.parent

    # ── Environment
    ENVIRONMENT: str = Field(default="development", alias="APP_ENV")
    APP_NAME: str = "Acadexa"
    DEBUG: bool = False

    # ── Security
    SECRET_KEY: str = Field(default="acadexa-v2-secret-change-in-production-2026", alias="JWT_SECRET_KEY")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 24 hours
    ALGORITHM: str = Field(default="HS256", alias="JWT_ALGORITHM")

    # ── Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # ── Supabase
    SUPABASE_URL: str = ""
    SUPABASE_ANON_KEY: str = ""
    SUPABASE_SERVICE_ROLE_KEY: str = ""

    # ── CORS
    ALLOWED_ORIGINS: List[str] = ["*"]
    CORS_ORIGINS: str = ""  # JSON string from .env, parsed separately

    # ── File limits
    MAX_FILE_SIZE: int = 50 * 1024 * 1024  # 50 MB
    ALLOWED_EXTENSIONS: set = {".xlsx", ".xls"}

    # ── Concurrency
    MAX_CONCURRENT_JOBS: int = 5

    # ── Job retention
    RESULT_RETENTION_HOURS: int = 24

    # ── Logging
    LOG_LEVEL: str = "INFO"

    # ── API
    API_V1_PREFIX: str = "/api/v1"

    # ── Redis (optional)
    REDIS_URL: str = ""

    @property
    def STORAGE_DIR(self) -> Path:
        return self.BASE_DIR / "storage"

    @property
    def TEMP_UPLOADS(self) -> Path:
        return self.STORAGE_DIR / "temp_uploads"

    @property
    def OUTPUT_DIR(self) -> Path:
        return self.STORAGE_DIR / "output"

    @property
    def LOGS_DIR(self) -> Path:
        return self.BASE_DIR / "logs"

    def model_post_init(self, __context):
        # Ensure directories exist
        for _dir in [self.STORAGE_DIR, self.TEMP_UPLOADS, self.OUTPUT_DIR, self.LOGS_DIR]:
            _dir.mkdir(parents=True, exist_ok=True)


settings = Settings()
