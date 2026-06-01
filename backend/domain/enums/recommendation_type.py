# ═══════════════════════════════════════
# Domain — Enums: Recommendation Type
# ═══════════════════════════════════════
from enum import Enum


class RecommendationType(str, Enum):
    COURSE_SUGGESTION = "course_suggestion"
    LOAD_WARNING = "load_warning"
    GRADUATION_PATH = "graduation_path"
    GPA_IMPROVEMENT = "gpa_improvement"
    PREREQUISITE_ALERT = "prerequisite_alert"
    ELECTIVE_SUGGESTION = "elective_suggestion"
    FIELD_TRAINING_REMINDER = "field_training_reminder"
