# ═══════════════════════════════════════
# Schemas — Users
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional


class UserCreate(BaseModel):
    email: str
    password: str = Field(..., min_length=8)
    name: str
    role: str = "viewer"
    department_id: Optional[str] = None


class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    role: str
    department_id: Optional[str] = None
    is_active: bool = True
