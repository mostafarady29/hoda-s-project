from fastapi import APIRouter, Depends
from schemas.auth import LoginRequest, TokenResponse
from app.response import success_response

router = APIRouter()


@router.post("/login", response_model=TokenResponse)
async def login(data: LoginRequest):
    from app.dependencies import get_study_plan_service
    # TODO: wire to auth_service
    return {"access_token": "dev-token", "token_type": "bearer", "role": "super_admin", "user_id": "dev", "name": "Dev User"}
