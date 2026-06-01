# ═══════════════════════════════════════
# Domain — Entities: Student & Transcript
# ═══════════════════════════════════════
from dataclasses import dataclass, field
from typing import Optional, List
from datetime import datetime


@dataclass
class Student:
    """Student entity parsed from academic transcript."""
    id: Optional[str] = None
    student_code: str = ""
    name_ar: str = ""
    name_en: str = ""
    department_id: Optional[str] = None
    department_name: str = ""
    plan_id: Optional[str] = None
    enrollment_year: Optional[int] = None
    current_level: int = 1
    cumulative_gpa: float = 0.0
    total_earned_hours: int = 0
    total_attempted_hours: int = 0
    status: str = "active"  # active, graduated, dismissed, suspended
    job_id: Optional[str] = None
    created_at: Optional[datetime] = None


@dataclass
class Transcript:
    """Academic transcript record (سجل أكاديمي)."""
    id: Optional[str] = None
    student_id: str = ""
    job_id: str = ""

    # Parsed data
    semesters: List["SemesterRecord"] = field(default_factory=list)
    cumulative_gpa: float = 0.0
    total_hours: int = 0
    total_points: float = 0.0

    created_at: Optional[datetime] = None


@dataclass
class SemesterRecord:
    """Single semester within a transcript."""
    semester_name: str = ""
    year: str = ""
    semester_type: str = "fall"  # fall, spring, summer
    courses: List["CourseRecord"] = field(default_factory=list)
    semester_gpa: float = 0.0
    semester_hours: int = 0
    cumulative_gpa: float = 0.0
    cumulative_hours: int = 0


@dataclass
class CourseRecord:
    """Single course record within a semester."""
    code: str = ""
    name: str = ""
    credit_hours: int = 0
    grade: str = ""
    points: float = 0.0
    status: str = ""  # passed, failed, withdrawn, incomplete
