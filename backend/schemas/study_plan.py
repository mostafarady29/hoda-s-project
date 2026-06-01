# ═══════════════════════════════════════
# Schemas — Study Plan
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


class StudyPlanCreate(BaseModel):
    name: str = Field(..., min_length=3, max_length=200)
    name_en: str = ""
    year: int = Field(..., ge=2000, le=2100)
    total_graduation_hours: int = Field(..., ge=1, le=300)
    description: str = ""
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    status: str = "draft"


class StudyPlanUpdate(BaseModel):
    name: Optional[str] = None
    name_en: Optional[str] = None
    year: Optional[int] = None
    total_graduation_hours: Optional[int] = None
    description: Optional[str] = None
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    status: Optional[str] = None


class StudyPlanResponse(BaseModel):
    id: str
    name: str
    name_en: str = ""
    year: int
    total_graduation_hours: int
    description: str = ""
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    status: str
    courses_count: int = 0
    departments_count: int = 0
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class CopyPlanRequest(BaseModel):
    new_name: str = Field(..., min_length=3)
    new_year: int = Field(..., ge=2000, le=2100)
    copy_courses: bool = True
    copy_prerequisites: bool = True
    copy_elective_groups: bool = True
    copy_plan_structure: bool = True
    copy_grade_scale: bool = True


class PlanSemesterStructureSchema(BaseModel):
    level: int = Field(..., ge=1, le=6)
    semester: str
    required_hours: int = 0
    min_hours: int = 12
    max_hours: int = 20


class LevelTransitionRuleSchema(BaseModel):
    from_level: int
    to_level: int
    required_hours: int
