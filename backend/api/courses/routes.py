# ═══════════════════════════════════════
# API — Courses Routes (شاشات 6-7)
# ═══════════════════════════════════════
from fastapi import APIRouter, Depends, Query
from typing import Optional
from schemas.course import CourseCreate, CourseUpdate
from app.response import success_response, paginated_response
from app.dependencies import get_course_service

router = APIRouter()


@router.get("/")
async def list_courses(
    plan_id: str = Query(...),
    department_id: Optional[str] = None,
    level: Optional[int] = None,
    page: int = Query(1, ge=1),
    page_size: int = Query(50, ge=1, le=200),
    service=Depends(get_course_service),
):
    """شاشة 6: قائمة المواد"""
    data, total = await service.list_courses(plan_id, department_id, level, page, page_size)
    return paginated_response(data, total, page, page_size)


@router.post("/")
async def create_course(data: CourseCreate, service=Depends(get_course_service)):
    """شاشة 7: إضافة مادة"""
    course = await service.create_course(data.model_dump())
    return success_response(course, "تم إنشاء المادة")


@router.get("/{course_id}")
async def get_course(course_id: str, service=Depends(get_course_service)):
    course = await service.get_course(course_id)
    return success_response(course)


@router.put("/{course_id}")
async def update_course(course_id: str, data: CourseUpdate, service=Depends(get_course_service)):
    """شاشة 7: تعديل مادة"""
    course = await service.update_course(course_id, data.model_dump(exclude_unset=True))
    return success_response(course, "تم تحديث المادة")


@router.delete("/{course_id}")
async def delete_course(course_id: str, service=Depends(get_course_service)):
    await service.delete_course(course_id)
    return success_response(message="تم حذف المادة")
