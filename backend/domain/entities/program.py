# ═══════════════════════════════════════
# Domain — Entities: Program
# ═══════════════════════════════════════
from dataclasses import dataclass
from typing import Optional


@dataclass
class Program:
    """Special academic program (برنامج خاص)."""
    id: Optional[str] = None
    plan_id: str = ""
    department_id: str = ""
    name_ar: str = ""
    name_en: str = ""
    code: str = ""
    total_hours: int = 0
    description: str = ""
