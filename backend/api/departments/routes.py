# ═══════════════════════════════════════
# API — Departments Routes (شاشات 4-5)
# ═══════════════════════════════════════
from fastapi import APIRouter, Depends, Query
from schemas.department import DepartmentCreate, DepartmentUpdate
from app.response import success_response
from app.dependencies import get_department_service

router = APIRouter()


@router.get("/")
async def list_departments(plan_id: str = Query(...), service=Depends(get_department_service)):
    """شاشة 4: إدارة الأقسام"""
    departments = await service.list_departments(plan_id)
    return success_response(departments)


@router.post("/")
async def create_department(data: DepartmentCreate, service=Depends(get_department_service)):
    """شاشة 5: إضافة قسم"""
    dept = await service.create_department(data.model_dump())
    return success_response(dept, "تم إنشاء القسم")


@router.put("/{dept_id}")
async def update_department(dept_id: str, data: DepartmentUpdate, service=Depends(get_department_service)):
    dept = await service.update_department(dept_id, data.model_dump(exclude_unset=True))
    return success_response(dept, "تم تحديث القسم")


@router.delete("/{dept_id}")
async def delete_department(dept_id: str, service=Depends(get_department_service)):
    await service.delete_department(dept_id)
    return success_response(message="تم حذف القسم")
