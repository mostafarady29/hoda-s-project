# ═══════════════════════════════════════
# Domain — Entities: Department & Program
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import Optional, List


@dataclass
class Department:
    """Academic department (قسم أكاديمي)."""
    id: Optional[str] = None
    plan_id: str = ""
    name_ar: str = ""
    name_en: str = ""
    code: str = ""
    abbreviation: str = ""
    description: str = ""
    is_program: bool = False  # True = برنامج خاص, False = قسم عادي
    has_independent_plan: bool = False
    courses_count: int = 0
    total_hours: int = 0
