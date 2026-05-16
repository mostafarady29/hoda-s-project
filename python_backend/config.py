# ===== File: python_backend/config.py =====
import os
from pathlib import Path
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Base paths
    BASE_DIR = Path(__file__).parent
    STORAGE_DIR = BASE_DIR / "storage"
    TEMP_UPLOADS = STORAGE_DIR / "temp_uploads"
    OUTPUT_DIR = STORAGE_DIR / "output"
    LOGS_DIR = BASE_DIR / "logs"
    JOBS_DIR = STORAGE_DIR / "jobs"
    
    # Create directories
    for dir_path in [TEMP_UPLOADS, OUTPUT_DIR, LOGS_DIR, JOBS_DIR]:
        dir_path.mkdir(parents=True, exist_ok=True)
    
    # Security
    SECRET_KEY = os.getenv("SECRET_KEY", "acadexa-secret-key-change-in-production")
    ALLOWED_ORIGINS = os.getenv("ALLOWED_ORIGINS", "*").split(",")
    
    # File settings
    MAX_FILE_SIZE = 50 * 1024 * 1024  # 50MB
    ALLOWED_EXTENSIONS = {".xlsx", ".xls"}
    
    # Job settings
    JOB_TIMEOUT = 600  # 10 minutes for 400 students
    MAX_CONCURRENT_JOBS = int(os.getenv("MAX_CONCURRENT_JOBS", 5))
    
    # Job retention (days) - 7 days
    JOB_RETENTION_DAYS = 7  
    
    # Rate limiting
    RATE_LIMIT_REQUESTS = 10  # requests per minute per IP
    RATE_LIMIT_PERIOD = 60  # seconds
    
    # Logging
    LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
    
    # CORS
    CORS_ORIGINS = [
        "http://localhost:3000",
        "http://localhost:8080",
        "http://localhost:5000",
        "https://*.flutterweb.app",
        "https://acadexa-api.onrender.com",
        "https://acadexa-api.railway.app"
    ]
    
    # API
    API_V1_PREFIX = "/api/v1"
    
    # Result retention (hours) - compatibility
    RESULT_RETENTION_HOURS = int(os.getenv("RESULT_RETENTION_HOURS", 24))