# ═══════════════════════════════════════
# Domain — Enums: Course Type
# ═══════════════════════════════════════
from enum import Enum


class CourseType(str, Enum):
    MANDATORY = "mandatory"
    ELECTIVE = "elective"
    GRADUATION_PROJECT = "graduation_project"
    FIELD_TRAINING = "field_training"
