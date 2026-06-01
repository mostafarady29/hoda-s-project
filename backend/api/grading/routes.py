# API — Grading Routes (شاشة 13)
from fastapi import APIRouter, Query
from typing import List
from schemas.grading import GradeScaleCreate, GradeScaleBulkCreate
from app.response import success_response

router = APIRouter()


@router.get("/scale")
async def get_grade_scale(plan_id: str = Query(...)):
    """شاشة 13: جدول التقديرات"""
    return success_response(data=[])


@router.post("/scale/bulk")
async def set_grade_scale(data: GradeScaleBulkCreate):
    """شاشة 13: حفظ جدول التقديرات كامل"""
    return success_response(message="تم حفظ جدول التقديرات")


@router.put("/scale/{grade_id}")
async def update_grade(grade_id: str, data: GradeScaleCreate):
    return success_response(message="تم تحديث التقدير")
