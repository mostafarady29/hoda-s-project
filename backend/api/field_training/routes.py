# API — Field Training Routes (شاشة 15)
from fastapi import APIRouter, Query
from schemas.field_training import FieldTrainingCreate, FieldTrainingUpdate
from app.response import success_response

router = APIRouter()


@router.get("/")
async def get_field_training(plan_id: str = Query(...)):
    """شاشة 15: إعدادات التدريب الميداني"""
    return success_response(data={})


@router.put("/")
async def set_field_training(data: FieldTrainingCreate):
    """شاشة 15: حفظ إعدادات التدريب"""
    return success_response(message="تم حفظ إعدادات التدريب الميداني")
