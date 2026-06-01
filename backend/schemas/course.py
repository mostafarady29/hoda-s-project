# ═══════════════════════════════════════
# Schemas — Course
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional, List


class CourseCreate(BaseModel):
    plan_id: str
    department_id: Optional[str] = None
    code: str = Field(..., min_length=1)
    name_ar: str = Field(..., min_length=1)
    name_en: str = ""
    credit_hours: int = Field(..., ge=0, le=12)
    theory_hours: int = 0
    practical_hours: int = 0
    lab_hours: int = 0
    field_hours: int = 0
    level: int = Field(1, ge=1, le=6)
    semester: str = "fall"
    course_type: str = "mandatory"
    elective_group_id: Optional[str] = None
    assessment_type: str = "theory_practical"
    midterm_score: int = 0
    coursework_score: int = 0
    theory_exam_score: int = 0
    practical_exam_score: int = 0
    total_score: int = 100
    min_passing_percentage: float = 30.0
    equivalent_codes: List[str] = []
    conflict_course_ids: List[str] = []
    is_shared: bool = False


class CourseUpdate(BaseModel):
    department_id: Optional[str] = None
    code: Optional[str] = None
    name_ar: Optional[str] = None
    name_en: Optional[str] = None
    credit_hours: Optional[int] = None
    theory_hours: Optional[int] = None
    practical_hours: Optional[int] = None
    lab_hours: Optional[int] = None
    field_hours: Optional[int] = None
    level: Optional[int] = None
    semester: Optional[str] = None
    course_type: Optional[str] = None
    elective_group_id: Optional[str] = None
    assessment_type: Optional[str] = None
    midterm_score: Optional[int] = None
    coursework_score: Optional[int] = None
    theory_exam_score: Optional[int] = None
    practical_exam_score: Optional[int] = None
    equivalent_codes: Optional[List[str]] = None
    conflict_course_ids: Optional[List[str]] = None
    is_shared: Optional[bool] = None


class CourseResponse(BaseModel):
    id: str
    plan_id: str
    department_id: Optional[str] = None
    department_name: str = ""
    code: str
    name_ar: str
    name_en: str = ""
    credit_hours: int
    theory_hours: int = 0
    practical_hours: int = 0
    lab_hours: int = 0
    field_hours: int = 0
    level: int
    semester: str
    course_type: str
    elective_group_id: Optional[str] = None
    assessment_type: str = ""
    midterm_score: int = 0
    coursework_score: int = 0
    theory_exam_score: int = 0
    practical_exam_score: int = 0
    total_score: int = 100
    equivalent_codes: List[str] = []
    is_shared: bool = False
