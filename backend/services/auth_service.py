# ═══════════════════════════════════════
# Services — Auth Service
# ═══════════════════════════════════════
from typing import Dict
from core.security import hash_password, verify_password, create_access_token
from core.exceptions import AuthenticationError


class AuthService:
    def __init__(self, supabase_client):
        self.client = supabase_client

    async def login(self, email: str, password: str) -> Dict:
        """Authenticate user and return token."""
        # Look up user in users table
        result = self.client.table("users").select("*").eq("email", email).maybe_single().execute()
        user = result.data
        if not user:
            raise AuthenticationError("البريد الإلكتروني أو كلمة المرور غير صحيحة")

        if not verify_password(password, user.get("password_hash", "")):
            raise AuthenticationError("البريد الإلكتروني أو كلمة المرور غير صحيحة")

        token = create_access_token({"sub": user["id"], "role": user.get("role", "viewer"), "email": email})
        return {
            "access_token": token,
            "token_type": "bearer",
            "role": user.get("role", "viewer"),
            "user_id": user["id"],
            "name": user.get("name", ""),
        }
