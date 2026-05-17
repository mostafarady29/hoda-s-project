# ===== File: python_backend/run.py =====
#!/usr/bin/env python3
"""
Entry point — works locally and on Railway.
Railway sets PORT env var automatically.
"""
import uvicorn
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

if __name__ == "__main__":
    from config import Config

    print("=" * 50)
    print("🎓 Acadexa Backend API v2.1.0")
    print(f"   Host  : {Config.HOST}")
    print(f"   Port  : {Config.PORT}")
    print(f"   Docs  : http://{Config.HOST}:{Config.PORT}/docs")
    print(f"   Env   : {os.getenv('ENVIRONMENT', 'development')}")
    print("=" * 50)

    uvicorn.run(
        "api.main:app",
        host=Config.HOST,
        port=Config.PORT,
        # reload=False in production (Railway)
        reload=os.getenv("ENVIRONMENT", "development") == "development",
        log_level=Config.LOG_LEVEL.lower(),
        # Workers — Railway free tier: 1 is fine
        workers=int(os.getenv("WEB_CONCURRENCY", 1)),
        # Timeouts
        timeout_keep_alive=30,
    )