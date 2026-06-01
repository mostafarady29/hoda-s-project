# ═══════════════════════════════════════
# API — Analysis Routes
# ═══════════════════════════════════════
from fastapi import APIRouter, Depends
from app.response import success_response
from app.dependencies import get_analysis_service

router = APIRouter()


@router.post("/student/{student_id}")
async def analyze_student(student_id: str, service=Depends(get_analysis_service)):
    """تشغيل التحليل الأكاديمي للطالب"""
    result = await service.analyze_student(student_id)
    return success_response(result, "تم التحليل بنجاح")


@router.get("/student/{student_id}")
async def get_analysis(student_id: str, service=Depends(get_analysis_service)):
    result = await service.get_analysis(student_id)
    return success_response(result)


@router.get("/student/{student_id}/recommendations")
async def get_recommendations(student_id: str, service=Depends(get_analysis_service)):
    recs = await service.get_recommendations(student_id)
    return success_response(recs)


@router.get("/student/{student_id}/warnings")
async def get_warnings(student_id: str, service=Depends(get_analysis_service)):
    warnings = await service.get_warnings(student_id)
    return success_response(warnings)
