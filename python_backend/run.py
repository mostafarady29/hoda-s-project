# ===== File: python_backend/run.py =====
#!/usr/bin/env python3
import uvicorn
import os
import sys
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

if __name__ == "__main__":
    port = int(os.getenv("PORT", 8000))
    host = os.getenv("HOST", "0.0.0.0")
    
    print("🎓 Starting Acadexa Backend API")
    print(f"   Host: {host}")
    print(f"   Port: {port}")
    print(f"   API Docs: http://{host}:{port}/docs")
    
    uvicorn.run(
        "api.main:app",
        host=host,
        port=port,
        reload=True,
        log_level="info"
    )