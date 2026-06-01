# API — Prerequisites Routes (شاشات 8-9)
from fastapi import APIRouter, Query
from schemas.prerequisite import PrerequisiteCreate, PrerequisiteBulkCreate
from app.response import success_response

router = APIRouter()


@router.get("/")
async def get_prerequisites(course_id: str = Query(...)):
    """شاشة 8: المتطلبات السابقة لمادة"""
    return success_response(data=[], message="المتطلبات السابقة")


@router.post("/")
async def add_prerequisite(data: PrerequisiteCreate):
    """شاشة 9: إضافة متطلب"""
    return success_response(message="تم إضافة المتطلب")


@router.post("/bulk")
async def set_prerequisites_bulk(data: PrerequisiteBulkCreate):
    return success_response(message="تم تحديث المتطلبات")


@router.delete("/{prereq_id}")
async def remove_prerequisite(prereq_id: str):
    return success_response(message="تم إزالة المتطلب")
