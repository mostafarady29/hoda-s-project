# ===== File: python_backend/api/routes/__init__.py =====
from .upload import router as upload_router

# Export all routers
__all__ = ["upload_router"]