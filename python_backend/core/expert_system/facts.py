"""
Expert System — Facts (Working Memory).
Holds all data about a student's record and the curriculum.
"""
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Set


@dataclass
class CourseFact:
    """A single course in the student's record."""
    course_code: str
    course_name: str
    credit_hours: int
    passed: bool
    grade_letter: Optional[str]
    grade_points: Optional[float]
    score: Optional[float]
    semester_number: int
    is_retake: bool = False
    is_transfer: bool = False
    course_id: Optional[str] = None


@dataclass
class SemesterFact:
    """A semester in the student's record."""
    semester_number: int
    academic_year: Optional[str]
    term: Optional[str]  # fall / spring / summer
    level_semester: Optional[str]  # e.g. "المستوى الأول - الفصل الأول"
    total_hours: int
    semester_gpa: Optional[float]
    courses: List[CourseFact] = field(default_factory=list)


@dataclass
class StudentFacts:
    """The complete working memory for one student."""
    student_id: str
    student_code: str
    student_name: str
    department_id: Optional[str]
    study_plan_id: Optional[str]
    study_level: Optional[int]
    enrollment_year: Optional[int]
    cumulative_gpa: float
    cumulative_percentage: Optional[float]

    semesters: List[SemesterFact] = field(default_factory=list)

    # Derived collections (populated by FactManager)
    all_courses: List[CourseFact] = field(default_factory=list)
    passed_codes: Set[str] = field(default_factory=set)
    failed_codes: Set[str] = field(default_factory=set)
    all_codes: Set[str] = field(default_factory=set)
    total_passed_hours: int = 0
    total_attempted_hours: int = 0
    calculated_gpa: float = 0.0


@dataclass
class CurriculumFacts:
    """The curriculum (study plan + rules)."""
    plan_id: str
    total_credit_hours: int
    min_gpa_to_graduate: float

    courses_by_code: Dict[str, Dict] = field(default_factory=dict)    # code -> course row
    courses_by_id: Dict[str, Dict] = field(default_factory=dict)      # id -> course row
    prerequisites: Dict[str, List[Dict]] = field(default_factory=dict) # course_id -> [prereqs]
    equivalents: Dict[str, List[str]] = field(default_factory=dict)    # course_id -> [codes]
    elective_groups: List[Dict] = field(default_factory=list)
    plan_structure: List[Dict] = field(default_factory=list)
    grade_scale_items: List[Dict] = field(default_factory=list)
    load_rules: Optional[Dict] = None
    grad_requirements: Optional[Dict] = None
    field_training_rules: Optional[Dict] = None

    # Reverse map: equivalent_code -> canonical course_id
    equiv_reverse: Dict[str, str] = field(default_factory=dict)