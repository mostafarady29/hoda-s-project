# ═══════════════════════════════════════
# Schemas — Department
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional


class DepartmentCreate(BaseModel):
    plan_id: str
    name_ar: str = Field(..., min_length=2)
    name_en: str = ""
    code: str = Field(..., min_length=1, max_length=10)
    abbreviation: str = ""
    description: str = ""
    is_program: bool = False
    has_independent_plan: bool = False


class DepartmentUpdate(BaseModel):
    name_ar: Optional[str] = None
    name_en: Optional[str] = None
    code: Optional[str] = None
    abbreviation: Optional[str] = None
    description: Optional[str] = None
    is_program: Optional[bool] = None
    has_independent_plan: Optional[bool] = None


class DepartmentResponse(BaseModel):
    id: str
    plan_id: str
    name_ar: str
    name_en: str = ""
    code: str
    abbreviation: str = ""
    description: str = ""
    is_program: bool = False
    has_independent_plan: bool = False
    courses_count: int = 0
    total_hours: int = 0
