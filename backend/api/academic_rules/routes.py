# API — Academic Rules Routes (شاشة 14)
from fastapi import APIRouter, Query
from schemas.academic_rules import AcademicRulesCreate, AcademicRulesUpdate
from app.response import success_response

router = APIRouter()


@router.get("/")
async def get_academic_rules(plan_id: str = Query(...)):
    """شاشة 14: قواعد العبء الدراسي"""
    return success_response(data={})


@router.put("/")
async def set_academic_rules(data: AcademicRulesCreate):
    """شاشة 14: حفظ القواعد"""
    return success_response(message="تم حفظ القواعد الأكاديمية")
