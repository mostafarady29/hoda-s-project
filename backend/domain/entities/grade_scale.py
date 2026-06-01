# ═══════════════════════════════════════
# Domain — Entities: Grade Scale
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import Optional, List


@dataclass
class GradeScale:
    """GPA grade scale entry (جدول التقديرات — مادة 36)."""
    id: Optional[str] = None
    plan_id: str = ""
    grade_ar: str = ""       # ممتاز، جيد جداً، etc.
    grade_letter: str = ""   # A+, A, B+, etc.
    points: float = 0.0      # GPA points
    min_score: int = 0
    max_score: int = 100
    order: int = 0


@dataclass
class SpecialGradeSymbol:
    """Special grade symbols not counted in GPA (رموز خاصة)."""
    id: Optional[str] = None
    plan_id: str = ""
    symbol: str = ""         # Ic, W, AU, S, TC, EX
    name_ar: str = ""
    description: str = ""
    counts_in_gpa: bool = False
