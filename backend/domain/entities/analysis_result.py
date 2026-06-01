# ═══════════════════════════════════════
# Domain — Entities: Analysis Result
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import Optional, List
from datetime import datetime


@dataclass
class AnalysisResult:
    """Result of expert system analysis for a student."""
    id: Optional[str] = None
    student_id: str = ""
    plan_id: str = ""
    analyzed_at: Optional[datetime] = None

    # Summary
    cumulative_gpa: float = 0.0
    total_earned_hours: int = 0
    remaining_hours: int = 0
    current_level: int = 1
    estimated_graduation_semester: str = ""

    # Detailed results
    recommendations: List["Recommendation"] = field(default_factory=list)
    warnings: List["Warning"] = field(default_factory=list)
    passed_courses: List[str] = field(default_factory=list)
    failed_courses: List[str] = field(default_factory=list)
    remaining_courses: List[str] = field(default_factory=list)
    available_electives: List[str] = field(default_factory=list)

    # Graduation readiness
    can_graduate: bool = False
    graduation_blockers: List[str] = field(default_factory=list)


@dataclass
class Recommendation:
    """Expert system recommendation."""
    type: str = ""  # course_suggestion, load_warning, graduation_path, etc.
    priority: str = "medium"  # low, medium, high, critical
    title: str = ""
    message: str = ""
    related_courses: List[str] = field(default_factory=list)


@dataclass
class Warning:
    """Academic warning from analysis."""
    type: str = ""  # gpa_low, overload, prerequisite_missing, etc.
    severity: str = "warning"  # info, warning, critical
    message: str = ""
    details: str = ""
