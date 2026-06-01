# ═══════════════════════════════════════
# Schemas — Analysis
# ═══════════════════════════════════════
from pydantic import BaseModel
from typing import Optional, List


class AnalysisRequest(BaseModel):
    student_id: str
    plan_id: Optional[str] = None


class RecommendationSchema(BaseModel):
    type: str
    priority: str
    title: str
    message: str
    related_courses: List[str] = []


class WarningSchema(BaseModel):
    type: str
    severity: str
    message: str
    details: str = ""


class AnalysisResponse(BaseModel):
    student_id: str
    plan_id: str
    cumulative_gpa: float
    total_earned_hours: int
    remaining_hours: int
    current_level: int
    can_graduate: bool
    graduation_blockers: List[str] = []
    recommendations: List[RecommendationSchema] = []
    warnings: List[WarningSchema] = []
    passed_courses_count: int = 0
    remaining_courses_count: int = 0
