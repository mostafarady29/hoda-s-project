#!/usr/bin/env python3
import uvicorn
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

if __name__ == "__main__":
    from config import Config

    print("=" * 60)
    print("🎓 Acadexa Academic Records API v3.0")
    print(f"   Host  : {Config.HOST}")
    print(f"   Port  : {Config.PORT}")
    print(f"   Docs  : http://{Config.HOST}:{Config.PORT}/docs")
    print(f"   Env   : {os.getenv('ENVIRONMENT', 'development')}")
    print("=" * 60)

    uvicorn.run(
        "api.main:app",
        host=Config.HOST,
        port=Config.PORT,
        reload=os.getenv("ENVIRONMENT", "development") == "development",
        log_level=Config.LOG_LEVEL.lower(),
        workers=int(os.getenv("WEB_CONCURRENCY", 1)),
        timeout_keep_alive=30,
    )