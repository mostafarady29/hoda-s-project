from .upload import router as upload_router
from .students import router as students_router
from .curriculum import router as curriculum_router
from .departments import router as departments_router

# Export all routers
__all__ = [
    "upload_router", 
    "students_router", 
    "curriculum_router", 
    "departments_router",
    "curriculum_api_router"
]