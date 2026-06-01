# ═══════════════════════════════════════
# Domain — Entities: Study Plan
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import Optional, List
from datetime import datetime


@dataclass
class StudyPlan:
    """Core entity representing an academic study plan (لائحة دراسية)."""
    id: Optional[str] = None
    name: str = ""
    name_en: str = ""
    year: int = 0
    total_graduation_hours: int = 0
    description: str = ""
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    status: str = "draft"  # draft, active, archived
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    created_by: Optional[str] = None

    # Computed/loaded relations
    departments: List["Department"] = field(default_factory=list)
    courses_count: int = 0
    departments_count: int = 0


@dataclass
class PlanSemesterStructure:
    """Credit hour structure per level/semester in a plan."""
    id: Optional[str] = None
    plan_id: str = ""
    level: int = 1  # 1-4
    semester: str = "fall"  # fall, spring, summer
    required_hours: int = 0
    min_hours: int = 12
    max_hours: int = 20


@dataclass
class LevelTransitionRule:
    """Rules for moving between academic levels."""
    id: Optional[str] = None
    plan_id: str = ""
    from_level: int = 1
    to_level: int = 2
    required_hours: int = 0
