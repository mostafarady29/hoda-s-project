"""
Acadexa Backend V2 — Entry Point
Clean Architecture + Domain Driven Design
"""
import uvicorn
import os
from core.config import settings

if __name__ == "__main__":
    print("=" * 60)
    print("🎓 Acadexa Academic Advising System — Backend V2")
    print(f"   Host  : {settings.HOST}")
    print(f"   Port  : {settings.PORT}")
    print(f"   Docs  : http://{settings.HOST}:{settings.PORT}/docs")
    print(f"   Env   : {settings.ENVIRONMENT}")
    print("=" * 60)

    uvicorn.run(
        "app.lifespan:create_app",
        factory=True,
        host=settings.HOST,
        port=settings.PORT,
        reload=settings.ENVIRONMENT == "development",
        log_level=settings.LOG_LEVEL.lower(),
        workers=int(os.getenv("WEB_CONCURRENCY", 1)),
        timeout_keep_alive=30,
    )
