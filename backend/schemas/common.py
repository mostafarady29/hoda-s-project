# ═══════════════════════════════════════
# Schemas — Common
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional, List, Any
from datetime import datetime


class PaginationParams(BaseModel):
    page: int = Field(default=1, ge=1)
    page_size: int = Field(default=20, ge=1, le=100)


class IdResponse(BaseModel):
    id: str


class MessageResponse(BaseModel):
    message: str


class TimestampMixin(BaseModel):
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
