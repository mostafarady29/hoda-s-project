# ═══════════════════════════════════════
# API — Study Plans Routes (شاشات 1-3)
# ═══════════════════════════════════════
from fastapi import APIRouter, Depends, Query
from typing import Optional
from schemas.study_plan import StudyPlanCreate, StudyPlanUpdate, StudyPlanResponse, CopyPlanRequest
from app.response import success_response, paginated_response
from app.dependencies import get_study_plan_service
from services.study_plan_service import StudyPlanService

router = APIRouter()


@router.get("/")
async def list_plans(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status: Optional[str] = None,
    service: StudyPlanService = Depends(get_study_plan_service),
):
    """شاشة 1: قائمة اللوائح"""
    data, total = await service.list_plans(page=page, page_size=page_size, status=status)
    return paginated_response(data, total, page, page_size)


@router.post("/")
async def create_plan(
    data: StudyPlanCreate,
    service: StudyPlanService = Depends(get_study_plan_service),
):
    """شاشة 2: إضافة لائحة جديدة"""
    plan = await service.create_plan(data.model_dump())
    return success_response(plan, "تم إنشاء اللائحة بنجاح")


@router.get("/{plan_id}")
async def get_plan(plan_id: str, service: StudyPlanService = Depends(get_study_plan_service)):
    plan = await service.get_plan(plan_id)
    return success_response(plan)


@router.put("/{plan_id}")
async def update_plan(
    plan_id: str,
    data: StudyPlanUpdate,
    service: StudyPlanService = Depends(get_study_plan_service),
):
    """شاشة 2: تعديل لائحة"""
    plan = await service.update_plan(plan_id, data.model_dump(exclude_unset=True))
    return success_response(plan, "تم تحديث اللائحة")


@router.delete("/{plan_id}")
async def delete_plan(plan_id: str, service: StudyPlanService = Depends(get_study_plan_service)):
    await service.delete_plan(plan_id)
    return success_response(message="تم حذف اللائحة")


@router.post("/{plan_id}/copy")
async def copy_plan(
    plan_id: str,
    data: CopyPlanRequest,
    service: StudyPlanService = Depends(get_study_plan_service),
):
    """شاشة 3: نسخ لائحة"""
    plan = await service.copy_plan(plan_id, {"name": data.new_name, "year": data.new_year})
    return success_response(plan, "تم نسخ اللائحة بنجاح")


@router.post("/{plan_id}/activate")
async def activate_plan(plan_id: str, service: StudyPlanService = Depends(get_study_plan_service)):
    plan = await service.activate_plan(plan_id)
    return success_response(plan, "تم تفعيل اللائحة")
