# ═══════════════════════════════════════
# Schemas — Grading
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional, List


class GradeScaleCreate(BaseModel):
    plan_id: str
    grade_ar: str
    grade_letter: str
    points: float = Field(..., ge=0.0, le=4.0)
    min_score: int = Field(..., ge=0)
    max_score: int = Field(..., le=100)
    order: int = 0


class GradeScaleUpdate(BaseModel):
    grade_ar: Optional[str] = None
    grade_letter: Optional[str] = None
    points: Optional[float] = None
    min_score: Optional[int] = None
    max_score: Optional[int] = None


class GradeScaleResponse(BaseModel):
    id: str
    plan_id: str
    grade_ar: str
    grade_letter: str
    points: float
    min_score: int
    max_score: int
    order: int = 0


class GradeScaleBulkCreate(BaseModel):
    """Bulk upsert for the entire grading table (شاشة 13)."""
    plan_id: str
    grades: List[GradeScaleCreate]


class SpecialSymbolCreate(BaseModel):
    plan_id: str
    symbol: str
    name_ar: str
    description: str = ""
    counts_in_gpa: bool = False
