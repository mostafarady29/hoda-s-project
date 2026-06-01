# ═══════════════════════════════════════
# Schemas — Auth
# ═══════════════════════════════════════
from pydantic import BaseModel, Field
from typing import Optional


class LoginRequest(BaseModel):
    email: str
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    user_id: str
    name: str = ""
