# API — Dashboard Routes
from fastapi import APIRouter, Depends
from app.response import success_response
from app.dependencies import get_dashboard_service

router = APIRouter()


@router.get("/overview")
async def get_dashboard_overview(service=Depends(get_dashboard_service)):
    overview = await service.get_overview()
    return success_response(overview)
