# ═══════════════════════════════════════
# Domain — Entities: Elective Group
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import Optional, List


@dataclass
class ElectiveGroup:
    """Group of elective courses (مجموعة اختيارية)."""
    id: Optional[str] = None
    plan_id: str = ""
    department_id: Optional[str] = None
    name: str = ""
    code: str = ""

    # Selection method
    selection_by: str = "hours"  # hours or count
    min_hours: int = 0
    max_hours: int = 0
    min_courses: int = 0
    max_courses: int = 0
    hours_per_course: int = 0  # If courses have equal hours

    # Validity
    valid_from_year: Optional[int] = None
    valid_to_year: Optional[int] = None

    # Rules
    allow_retake_after_fail: bool = True
    allow_substitute_after_fail: bool = True
    max_retake_attempts: int = 2

    # Loaded relations
    courses: List["Course"] = field(default_factory=list)
    courses_count: int = 0
