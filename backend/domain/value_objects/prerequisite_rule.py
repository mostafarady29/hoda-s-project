# ═══════════════════════════════════════
# Domain — Value Objects: Prerequisite Rule
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import List


@dataclass(frozen=True)
class PrerequisiteRule:
    """Encapsulates prerequisite logic (AND/OR groups)."""
    course_ids: tuple = ()
    logic: str = "all"  # "all" = AND, "any" = OR
    min_grade: float = 0.0

    def is_satisfied(self, passed_course_ids: List[str]) -> bool:
        """Check if the prerequisite rule is satisfied by passed courses."""
        if self.logic == "all":
            return all(cid in passed_course_ids for cid in self.course_ids)
        else:
            return any(cid in passed_course_ids for cid in self.course_ids)
