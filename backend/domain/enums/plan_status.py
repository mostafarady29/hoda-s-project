# ═══════════════════════════════════════
# Domain — Enums: Plan Status
# ═══════════════════════════════════════
from enum import Enum


class PlanStatus(str, Enum):
    DRAFT = "draft"
    ACTIVE = "active"
    ARCHIVED = "archived"
