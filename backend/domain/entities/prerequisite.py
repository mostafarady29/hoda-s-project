# ═══════════════════════════════════════
# Domain — Entities: Prerequisite
# ═══════════════════════════════════════
from dataclasses import dataclass
from typing import Optional


@dataclass
class Prerequisite:
    """Prerequisite relationship between courses (متطلب سابق)."""
    id: Optional[str] = None
    course_id: str = ""
    required_course_id: str = ""
    relation_type: str = "all"  # all = must pass ALL, any = pass ANY one
    min_grade: Optional[float] = None  # Minimum grade in prerequisite
    must_be_prior_semester: bool = False  # Must pass in previous semester

    # Loaded relation info
    required_course_code: str = ""
    required_course_name: str = ""
