# API — Elective Groups Routes (شاشات 10-11)
from fastapi import APIRouter, Query
from schemas.elective_group import ElectiveGroupCreate, ElectiveGroupUpdate
from app.response import success_response

router = APIRouter()


@router.get("/")
async def list_elective_groups(plan_id: str = Query(...)):
    """شاشة 10: المجموعات الاختيارية"""
    return success_response(data=[])


@router.post("/")
async def create_elective_group(data: ElectiveGroupCreate):
    """شاشة 11: إضافة مجموعة"""
    return success_response(message="تم إنشاء المجموعة الاختيارية")


@router.put("/{group_id}")
async def update_elective_group(group_id: str, data: ElectiveGroupUpdate):
    return success_response(message="تم تحديث المجموعة")


@router.delete("/{group_id}")
async def delete_elective_group(group_id: str):
    return success_response(message="تم حذف المجموعة")


@router.post("/{group_id}/courses/{course_id}")
async def add_course_to_group(group_id: str, course_id: str):
    return success_response(message="تم إضافة المادة للمجموعة")


@router.delete("/{group_id}/courses/{course_id}")
async def remove_course_from_group(group_id: str, course_id: str):
    return success_response(message="تم إزالة المادة من المجموعة")
