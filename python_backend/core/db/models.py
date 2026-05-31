"""
Pydantic models matching the Supabase database schema.
Used for validation and serialization.
"""
from pydantic import BaseModel, Field
from typing import Optional, List, Any
from datetime import datetime
from enum import Enum


# ─── Enums ────────────────────────────────────────────────
class CourseType(str, Enum):
    mandatory = "mandatory"
    elective = "elective"
    field_training = "field_training"
    graduation_project = "graduation_project"


class SemesterTerm(str, Enum):
    fall = "fall"
    spring = "spring"
    summer = "summer"


class PlanStatus(str, Enum):
    draft = "draft"
    active = "active"
    archived = "archived"


class IssueSeverity(str, Enum):
    error = "error"
    warning = "warning"
    info = "info"


class PrerequisiteLogic(str, Enum):
    ALL = "ALL"
    ANY = "ANY"


class GradeLetter(str, Enum):
    A_PLUS = "A+"
    A = "A"
    A_MINUS = "A-"
    B_PLUS = "B+"
    B = "B"
    B_MINUS = "B-"
    C_PLUS = "C+"
    C = "C"
    C_MINUS = "C-"
    D_PLUS = "D+"
    D = "D"
    D_MINUS = "D-"
    F = "F"


# ─── Department ───────────────────────────────────────────
class DepartmentCreate(BaseModel):
    code: str
    name_ar: str
    name_en: str
    short_name: Optional[str] = None
    program_id: Optional[str] = None
    is_program: bool = False
    is_active: bool = True


class DepartmentOut(DepartmentCreate):
    id: str
    created_at: Optional[datetime] = None


# ─── Program ──────────────────────────────────────────────
class ProgramCreate(BaseModel):
    code: str
    name_ar: str
    name_en: str
    program_type: str = "regular"
    department_id: Optional[str] = None
    is_active: bool = True
    description: Optional[str] = None


class ProgramOut(ProgramCreate):
    id: str
    created_at: Optional[datetime] = None


# ─── Study Plan ───────────────────────────────────────────
class StudyPlanCreate(BaseModel):
    department_id: str
    program_id: Optional[str] = None
    academic_year: int
    name: str
    total_credit_hours: int = 150
    min_gpa_to_graduate: float = 0.7
    description: Optional[str] = None
    status: PlanStatus = PlanStatus.draft


class StudyPlanOut(StudyPlanCreate):
    id: str
    version: int = 1
    is_current: bool = False
    default_grading_scale_id: Optional[str] = None
    created_at: Optional[datetime] = None


# ─── Course ───────────────────────────────────────────────
class GradingConfig(BaseModel):
    midterm: int = 20
    coursework: int = 20
    final_theory: int = 30
    final_practical: int = 30
    min_passing: int = 30


class CourseCreate(BaseModel):
    plan_id: str
    code: str
    name_ar: str
    name_en: Optional[str] = None
    credit_hours: int
    theory_hours: int = 0
    practical_hours: int = 0
    lab_hours: int = 0
    field_hours: int = 0
    level: int
    term: SemesterTerm
    course_type: CourseType = CourseType.mandatory
    grading_config: Optional[GradingConfig] = None
    grading_scale_id: Optional[str] = None
    notes: Optional[str] = None
    is_active: bool = True


class CourseOut(CourseCreate):
    id: str
    created_at: Optional[datetime] = None


# ─── Prerequisite ─────────────────────────────────────────
class PrerequisiteCreate(BaseModel):
    course_id: str
    required_course_id: Optional[str] = None
    required_course_code: Optional[str] = None
    logic: PrerequisiteLogic = PrerequisiteLogic.ALL
    min_grade: int = 50
    must_be_prior_term: bool = True


class PrerequisiteOut(PrerequisiteCreate):
    id: str
    created_at: Optional[datetime] = None


# ─── Elective Group ───────────────────────────────────────
class ElectiveGroupCreate(BaseModel):
    plan_id: str
    name: str
    code: str
    select_by_hours: bool = True
    min_hours: Optional[int] = None
    max_hours: Optional[int] = None
    min_courses: Optional[int] = None
    max_courses: Optional[int] = None
    valid_from_year: Optional[int] = None
    valid_to_year: Optional[int] = None


class ElectiveGroupOut(ElectiveGroupCreate):
    id: str
    courses: List[str] = []  # list of course ids
    created_at: Optional[datetime] = None


# ─── Academic Load Rules ──────────────────────────────────
class AcademicLoadRulesCreate(BaseModel):
    plan_id: str
    max_hours_fall_spring: int = 20
    min_hours_fall_spring: int = 12
    max_hours_summer: int = 9
    allow_overload: bool = False
    overload_max_hours: Optional[int] = None
    overload_min_gpa: Optional[float] = None
    level_1_to_2_min_hours: int = 32
    level_2_to_3_min_hours: int = 70
    level_3_to_4_min_hours: int = 110
    requires_civic_literacy: bool = True
    civic_literacy_count: int = 2
    requires_community_course: bool = True


class AcademicLoadRulesOut(AcademicLoadRulesCreate):
    id: str


# ─── Graduation Requirements ──────────────────────────────
class GraduationRequirementsCreate(BaseModel):
    plan_id: str
    required_hours: int = 150
    min_gpa: float = 0.7
    requires_field_training: bool = True
    requires_civic_literacy: bool = True
    civic_literacy_count: int = 2
    requires_community_course: bool = True


class GraduationRequirementsOut(GraduationRequirementsCreate):
    id: str


# ─── Field Training Rules ─────────────────────────────────
class FieldTrainingRulesCreate(BaseModel):
    plan_id: str
    training_levels: int = 4
    hours_per_level: int = 2
    external_supervisor_weight: float = 20
    internal_supervisor_weight: float = 20
    remote_supervisor_weight: float = 20
    final_exam_weight: float = 40
    allow_shift_level_1_2: bool = False
    allow_shift_level_3_4: bool = False
    mandatory_for_graduation: bool = True


class FieldTrainingRulesOut(FieldTrainingRulesCreate):
    id: str


# ─── Grade Scale ──────────────────────────────────────────
class GradeScaleItemCreate(BaseModel):
    grade_scale_id: str
    grade_ar: str
    grade_letter: GradeLetter
    points: float
    min_score: int
    max_score: int
    is_passing: bool = True


class GradeScaleItemOut(GradeScaleItemCreate):
    id: str


class GradingScaleCreate(BaseModel):
    plan_id: Optional[str] = None
    department_id: Optional[str] = None
    program_id: Optional[str] = None
    name_ar: str
    name_en: Optional[str] = None
    is_default: bool = False


class GradingScaleOut(GradingScaleCreate):
    id: str
    items: List[GradeScaleItemOut] = []
    created_at: Optional[datetime] = None


# ─── Plan Structure ───────────────────────────────────────
class PlanStructureCreate(BaseModel):
    plan_id: str
    level: int
    term: SemesterTerm
    prescribed_hours: int = 0
    min_hours: int = 12
    max_hours: int = 20


class PlanStructureOut(PlanStructureCreate):
    id: str


# ─── Student ──────────────────────────────────────────────
class StudentCreate(BaseModel):
    student_code: str
    name: str
    department_id: Optional[str] = None
    program_id: Optional[str] = None
    study_plan_id: Optional[str] = None
    enrollment_year: Optional[int] = None
    study_level: Optional[int] = None
    cumulative_gpa: Optional[float] = None
    cumulative_percentage: Optional[float] = None
    is_active: bool = True
    import_job_id: Optional[str] = None


class StudentOut(StudentCreate):
    id: str
    created_at: Optional[datetime] = None


# ─── Student Semester ─────────────────────────────────────
class StudentSemesterCreate(BaseModel):
    student_id: str
    semester_number: int
    academic_year: Optional[str] = None
    term: Optional[SemesterTerm] = None
    total_hours: int = 0
    semester_gpa: Optional[float] = None


class StudentSemesterOut(StudentSemesterCreate):
    id: str
    created_at: Optional[datetime] = None


# ─── Student Course ───────────────────────────────────────
class StudentCourseCreate(BaseModel):
    student_id: str
    semester_id: str
    course_code: str
    course_name: str
    course_id: Optional[str] = None
    credit_hours: int
    credit_hours_attempted: int
    passed: bool
    grade_letter: Optional[GradeLetter] = None
    grade_points: Optional[float] = None
    score: Optional[float] = None
    is_transfer: bool = False
    is_retake: bool = False
    retake_count: int = 0
    grading_scale_id: Optional[str] = None


class StudentCourseOut(StudentCourseCreate):
    id: str
    created_at: Optional[datetime] = None


# ─── Analysis Result ──────────────────────────────────────
class AnalysisResultOut(BaseModel):
    id: str
    student_id: str
    plan_id: Optional[str] = None
    calculated_gpa: Optional[float] = None
    total_attempted_hours: int = 0
    total_passed_hours: int = 0
    graduation_percentage: Optional[float] = None
    is_eligible_to_graduate: bool = False
    errors_count: int = 0
    warnings_count: int = 0
    info_count: int = 0
    analyzed_at: Optional[datetime] = None
    is_latest: bool = True
    analysis_version: int = 1


class AnalysisIssueOut(BaseModel):
    id: str
    analysis_id: str
    student_id: str
    rule_code: str
    severity: IssueSeverity
    title: str
    description: str
    suggestion: Optional[str] = None
    created_at: Optional[datetime] = None


class AnalysisRecommendationOut(BaseModel):
    id: str
    analysis_id: str
    student_id: str
    recommendation: str
    priority: int = 1
    created_at: Optional[datetime] = None


class FullAnalysisOut(BaseModel):
    result: AnalysisResultOut
    issues: List[AnalysisIssueOut] = []
    recommendations: List[AnalysisRecommendationOut] = []


# ─── Import ───────────────────────────────────────────────
class ImportJobOut(BaseModel):
    id: str
    filename: str
    department_id: Optional[str] = None
    status: str
    total_students: int = 0
    successful: int = 0
    failed: int = 0
    error_log: List[Any] = []
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


# ─── Curriculum complete export ───────────────────────────
class CurriculumExport(BaseModel):
    plan: StudyPlanOut
    departments: List[DepartmentOut] = []
    courses: List[CourseOut] = []
    prerequisites: List[PrerequisiteOut] = []
    elective_groups: List[ElectiveGroupOut] = []
    plan_structure: List[PlanStructureOut] = []
    grading_scales: List[GradingScaleOut] = []
    academic_load_rules: Optional[AcademicLoadRulesOut] = None
    graduation_requirements: Optional[GraduationRequirementsOut] = None
    field_training_rules: Optional[FieldTrainingRulesOut] = None