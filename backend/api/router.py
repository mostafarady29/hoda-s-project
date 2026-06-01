# ═══════════════════════════════════════
# API — Main Router
# ═══════════════════════════════════════
from fastapi import APIRouter

from api.auth.routes import router as auth_router
from api.users.routes import router as users_router
from api.study_plans.routes import router as study_plans_router
from api.departments.routes import router as departments_router
from api.courses.routes import router as courses_router
from api.prerequisites.routes import router as prerequisites_router
from api.elective_groups.routes import router as elective_groups_router
from api.grading.routes import router as grading_router
from api.academic_rules.routes import router as academic_rules_router
from api.field_training.routes import router as field_training_router
from api.import_export.routes import router as import_export_router
from api.transcript.routes import router as transcript_router
from api.analysis.routes import router as analysis_router
from api.dashboard.routes import router as dashboard_router
from api.v1_compat.routes import router as v1_compat_router

api_router = APIRouter()

# ── V1 Compatibility (Flutter frontend endpoints) — MUST be first
api_router.include_router(v1_compat_router, tags=["V1 التوافق"])

# ── V2 Clean Architecture endpoints
api_router.include_router(auth_router, prefix="/auth", tags=["المصادقة"])
api_router.include_router(users_router, prefix="/users", tags=["المستخدمون"])
api_router.include_router(study_plans_router, prefix="/study-plans", tags=["اللوائح الدراسية"])
api_router.include_router(departments_router, prefix="/departments", tags=["الأقسام والبرامج"])
api_router.include_router(courses_router, prefix="/courses", tags=["المواد الدراسية"])
api_router.include_router(prerequisites_router, prefix="/prerequisites", tags=["المتطلبات السابقة"])
api_router.include_router(elective_groups_router, prefix="/elective-groups", tags=["المجموعات الاختيارية"])
api_router.include_router(grading_router, prefix="/grading", tags=["جدول التقديرات"])
api_router.include_router(academic_rules_router, prefix="/academic-rules", tags=["القواعد الأكاديمية"])
api_router.include_router(field_training_router, prefix="/field-training", tags=["التدريب الميداني"])
api_router.include_router(import_export_router, prefix="/import-export", tags=["الاستيراد والتصدير"])
api_router.include_router(transcript_router, prefix="/transcripts", tags=["السجلات الأكاديمية"])
api_router.include_router(analysis_router, prefix="/analysis", tags=["التحليل الأكاديمي"])
api_router.include_router(dashboard_router, prefix="/dashboard", tags=["لوحة التحكم"])

