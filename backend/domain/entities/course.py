# ═══════════════════════════════════════
# Domain — Entities: Course
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import Optional, List


@dataclass
class Course:
    """
    Core entity representing an academic course (مادة دراسية).
    Covers all fields from the 18-screen curriculum management system.
    """
    id: Optional[str] = None
    plan_id: str = ""
    department_id: Optional[str] = None
    code: str = ""
    name_ar: str = ""
    name_en: str = ""
    credit_hours: int = 0

    # Hour distribution
    theory_hours: int = 0
    practical_hours: int = 0
    lab_hours: int = 0
    field_hours: int = 0

    # Placement
    level: int = 1
    semester: str = "fall"  # fall, spring, summer

    # Type
    course_type: str = "mandatory"  # mandatory, elective, graduation_project, field_training
    elective_group_id: Optional[str] = None

    # Grade distribution
    assessment_type: str = "theory_practical"  # theory_only, practical_only, theory_practical
    midterm_score: int = 0
    coursework_score: int = 0
    theory_exam_score: int = 0
    practical_exam_score: int = 0
    total_score: int = 100
    min_passing_percentage: float = 30.0

    # Equivalent codes (for matching across plans)
    equivalent_codes: List[str] = field(default_factory=list)

    # Conflicting courses (cannot register together)
    conflict_course_ids: List[str] = field(default_factory=list)

    # Shared across all departments?
    is_shared: bool = False

    # Relations (loaded)
    prerequisites: List["Prerequisite"] = field(default_factory=list)
    department_name: str = ""
