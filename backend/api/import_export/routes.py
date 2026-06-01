# API — Import/Export Routes (شاشات 16-17)
from fastapi import APIRouter, UploadFile, File, Query
from app.response import success_response

router = APIRouter()


@router.post("/curriculum/json")
async def import_curriculum_json(file: UploadFile = File(...)):
    """شاشة 16: استيراد لائحة من JSON"""
    return success_response(message="تم استيراد اللائحة")


@router.get("/curriculum/{plan_id}/json")
async def export_curriculum_json(plan_id: str):
    """شاشة 17: تصدير لائحة إلى JSON"""
    return success_response(data={})


@router.get("/curriculum/{plan_id}/excel")
async def export_curriculum_excel(plan_id: str):
    """شاشة 17: تصدير لائحة إلى Excel"""
    return success_response(message="سيتم تحميل ملف Excel")


@router.get("/template/json")
async def download_json_template():
    """تحميل قالب JSON"""
    return success_response(data={"name": "", "year": 2024, "courses": []})
