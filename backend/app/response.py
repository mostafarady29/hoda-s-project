# ═══════════════════════════════════════
# App — Standard Response Helpers
# ═══════════════════════════════════════
from typing import Any, Optional, List
from pydantic import BaseModel


class ApiResponse(BaseModel):
    """Standard API response wrapper."""
    success: bool = True
    message: str = ""
    data: Optional[Any] = None
    meta: Optional[dict] = None


class PaginatedResponse(BaseModel):
    """Paginated response wrapper."""
    success: bool = True
    data: List[Any] = []
    total: int = 0
    page: int = 1
    page_size: int = 20
    total_pages: int = 0


def success_response(data: Any = None, message: str = "تم بنجاح", meta: dict = None) -> dict:
    return {"success": True, "message": message, "data": data, "meta": meta}


def error_response(message: str, code: str = "ERROR", details: Any = None) -> dict:
    return {"success": False, "error": code, "message": message, "details": details}


def paginated_response(data: list, total: int, page: int = 1, page_size: int = 20) -> dict:
    total_pages = (total + page_size - 1) // page_size
    return {
        "success": True,
        "data": data,
        "meta": {
            "total": total,
            "page": page,
            "page_size": page_size,
            "total_pages": total_pages,
        },
    }
