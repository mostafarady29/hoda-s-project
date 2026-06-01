from fastapi import APIRouter
from app.response import success_response

router = APIRouter()


@router.get("/")
async def list_users():
    return success_response(data=[], message="المستخدمون")
