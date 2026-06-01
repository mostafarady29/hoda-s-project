# ═══════════════════════════════════════
# Schemas — Academic Rules
# ═══════════════════════════════════════
from pydantic import BaseModel
from typing import Optional


class AcademicRulesCreate(BaseModel):
    plan_id: str
    # Load limits
    max_fall_spring_hours: int = 20
    min_fall_spring_hours: int = 12
    max_summer_hours: int = 9
    # Override rules
    allow_overload_last_semester: bool = False
    overload_max_hours: int = 21
    overload_min_gpa_letter: str = "B"
    allow_summer_overload_for_graduation: bool = False
    summer_overload_max_hours: int = 12
    # Graduation requirements
    min_graduation_gpa: float = 0.7
    requires_literacy_campaign: bool = True
    literacy_citizens_count: int = 2
    requires_community_course: bool = True


class AcademicRulesUpdate(BaseModel):
    max_fall_spring_hours: Optional[int] = None
    min_fall_spring_hours: Optional[int] = None
    max_summer_hours: Optional[int] = None
    allow_overload_last_semester: Optional[bool] = None
    overload_max_hours: Optional[int] = None
    overload_min_gpa_letter: Optional[str] = None
    min_graduation_gpa: Optional[float] = None
    requires_literacy_campaign: Optional[bool] = None
    literacy_citizens_count: Optional[int] = None
    requires_community_course: Optional[bool] = None


class AcademicRulesResponse(BaseModel):
    id: str
    plan_id: str
    max_fall_spring_hours: int = 20
    min_fall_spring_hours: int = 12
    max_summer_hours: int = 9
    allow_overload_last_semester: bool = False
    overload_max_hours: int = 21
    overload_min_gpa_letter: str = "B"
    allow_summer_overload_for_graduation: bool = False
    summer_overload_max_hours: int = 12
    min_graduation_gpa: float = 0.7
    requires_literacy_campaign: bool = True
    literacy_citizens_count: int = 2
    requires_community_course: bool = True
