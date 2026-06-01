# ═══════════════════════════════════════
# Schemas — Elective Group
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional, List


class ElectiveGroupCreate(BaseModel):
    plan_id: str
    department_id: Optional[str] = None
    name: str = Field(..., min_length=2)
    code: str = Field(..., min_length=1)
    selection_by: str = "hours"
    min_hours: int = 0
    max_hours: int = 0
    min_courses: int = 0
    max_courses: int = 0
    hours_per_course: int = 0
    valid_from_year: Optional[int] = None
    valid_to_year: Optional[int] = None
    allow_retake_after_fail: bool = True
    allow_substitute_after_fail: bool = True
    max_retake_attempts: int = 2
    course_ids: List[str] = []


class ElectiveGroupUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    selection_by: Optional[str] = None
    min_hours: Optional[int] = None
    max_hours: Optional[int] = None
    min_courses: Optional[int] = None
    max_courses: Optional[int] = None
    allow_retake_after_fail: Optional[bool] = None
    allow_substitute_after_fail: Optional[bool] = None
    max_retake_attempts: Optional[int] = None


class ElectiveGroupResponse(BaseModel):
    id: str
    plan_id: str
    department_id: Optional[str] = None
    name: str
    code: str
    selection_by: str
    min_hours: int = 0
    max_hours: int = 0
    min_courses: int = 0
    max_courses: int = 0
    hours_per_course: int = 0
    valid_from_year: Optional[int] = None
    valid_to_year: Optional[int] = None
    allow_retake_after_fail: bool = True
    allow_substitute_after_fail: bool = True
    max_retake_attempts: int = 2
    courses_count: int = 0
