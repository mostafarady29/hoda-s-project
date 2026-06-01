# ═══════════════════════════════════════
# Domain — Enums: Semester Type
# ═══════════════════════════════════════
from enum import Enum


class SemesterType(str, Enum):
    FALL = "fall"
    SPRING = "spring"
    SUMMER = "summer"
