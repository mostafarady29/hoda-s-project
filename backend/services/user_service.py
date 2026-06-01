# ═══════════════════════════════════════
# Services — User Service
# ═══════════════════════════════════════
from typing import Dict, List
from core.security import hash_password
from core.exceptions import EntityNotFoundError, DuplicateEntityError


class UserService:
    def __init__(self, supabase_client):
        self.client = supabase_client

    async def create_user(self, data: Dict) -> Dict:
        # Check duplicate
        existing = self.client.table("users").select("id").eq("email", data["email"]).maybe_single().execute()
        if existing.data:
            raise DuplicateEntityError("المستخدم", "email", data["email"])
        data["password_hash"] = hash_password(data.pop("password"))
        result = self.client.table("users").insert(data).execute()
        return result.data[0] if result.data else None

    async def list_users(self) -> List[Dict]:
        result = self.client.table("users").select("id, email, name, role, is_active").execute()
        return result.data or []
