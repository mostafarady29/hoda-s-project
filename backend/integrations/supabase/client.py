# ═══════════════════════════════════════
# Integrations — Supabase Client
# ═══════════════════════════════════════
from supabase import create_client, Client
from core.config import settings
from core.logger import logger

_client: Client = None


def get_supabase_client() -> Client:
    """Get or create Supabase client singleton."""
    global _client
    if _client is None:
        if not settings.SUPABASE_URL or not settings.SUPABASE_SERVICE_ROLE_KEY:
            logger.warning("⚠️ Supabase credentials not configured — using mock mode")
            return None
        _client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_SERVICE_ROLE_KEY,
        )
        logger.info("✅ Supabase client initialized")
    return _client
