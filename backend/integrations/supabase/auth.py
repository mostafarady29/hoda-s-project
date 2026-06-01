# ═══════════════════════════════════════
# Integrations — Supabase Auth
# ═══════════════════════════════════════
from typing import Optional
from core.logger import logger


class SupabaseAuth:
    """Wrapper for Supabase Auth operations."""

    def __init__(self, client):
        self.client = client

    async def sign_up(self, email: str, password: str) -> Optional[dict]:
        try:
            result = self.client.auth.sign_up({"email": email, "password": password})
            return result
        except Exception as e:
            logger.error(f"Supabase sign up failed: {e}")
            return None

    async def sign_in(self, email: str, password: str) -> Optional[dict]:
        try:
            result = self.client.auth.sign_in_with_password({"email": email, "password": password})
            return result
        except Exception as e:
            logger.error(f"Supabase sign in failed: {e}")
            return None
