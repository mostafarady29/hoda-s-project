# ═══════════════════════════════════════
# App — Dependencies (FastAPI DI)
# ═══════════════════════════════════════
"""
Dependency injection providers for FastAPI routes.
Each function creates a service with its required repositories.
"""
from fastapi import Depends
from integrations.supabase.client import get_supabase_client

from repositories.study_plan_repository import StudyPlanRepository
from repositories.course_repository import CourseRepository
from repositories.department_repository import DepartmentRepository
from repositories.program_repository import ProgramRepository
from repositories.prerequisite_repository import PrerequisiteRepository
from repositories.elective_group_repository import ElectiveGroupRepository
from repositories.grading_repository import GradingRepository
from repositories.academic_rules_repository import AcademicRulesRepository
from repositories.field_training_repository import FieldTrainingRepository
from repositories.student_repository import StudentRepository
from repositories.transcript_repository import TranscriptRepository
from repositories.analysis_repository import AnalysisRepository
from repositories.audit_repository import AuditRepository
from repositories.import_job_repository import ImportJobRepository

from services.study_plan_service import StudyPlanService
from services.course_service import CourseService
from services.department_service import DepartmentService
from services.transcript_service import TranscriptService
from services.analysis_service import AnalysisService
from services.dashboard_service import DashboardService
from services.import_export_service import ImportExportService


async def init_services():
    """Called during app startup."""
    from core.logger import logger
    client = get_supabase_client()
    if client:
        logger.info("✅ All services initialized")
    else:
        logger.warning("⚠️ Running without Supabase — endpoints will fail")


async def shutdown_services():
    """Called during app shutdown."""
    from core.logger import logger
    logger.info("🛑 Services shutdown complete")


def _get_client():
    return get_supabase_client()


def get_study_plan_service() -> StudyPlanService:
    client = _get_client()
    return StudyPlanService(
        repo=StudyPlanRepository(client),
        audit_repo=AuditRepository(client),
    )


def get_course_service() -> CourseService:
    client = _get_client()
    return CourseService(
        repo=CourseRepository(client),
        prereq_repo=PrerequisiteRepository(client),
        audit_repo=AuditRepository(client),
    )


def get_department_service() -> DepartmentService:
    client = _get_client()
    return DepartmentService(
        repo=DepartmentRepository(client),
        program_repo=ProgramRepository(client),
    )


def get_transcript_service() -> TranscriptService:
    client = _get_client()
    return TranscriptService(
        repo=TranscriptRepository(client),
        student_repo=StudentRepository(client),
        job_repo=ImportJobRepository(client),
    )


def get_analysis_service() -> AnalysisService:
    client = _get_client()
    return AnalysisService(
        repo=AnalysisRepository(client),
        student_repo=StudentRepository(client),
        course_repo=CourseRepository(client),
    )


def get_dashboard_service() -> DashboardService:
    client = _get_client()
    return DashboardService(
        student_repo=StudentRepository(client),
        plan_repo=StudyPlanRepository(client),
        analysis_repo=AnalysisRepository(client),
    )


def get_import_export_service() -> ImportExportService:
    client = _get_client()
    return ImportExportService(
        job_repo=ImportJobRepository(client),
        plan_repo=StudyPlanRepository(client),
    )
