# ═══════════════════════════════════════
# Integrations — Supabase Storage
# ═══════════════════════════════════════
from typing import Optional
from core.logger import logger


class SupabaseStorage:
    """Wrapper for Supabase Storage operations."""

    def __init__(self, client):
        self.client = client

    async def upload_file(self, bucket: str, path: str, file_data: bytes) -> Optional[str]:
        """Upload a file to Supabase Storage."""
        try:
            result = self.client.storage.from_(bucket).upload(path, file_data)
            return result.path
        except Exception as e:
            logger.error(f"Failed to upload to storage: {e}")
            return None

    async def download_file(self, bucket: str, path: str) -> Optional[bytes]:
        """Download a file from Supabase Storage."""
        try:
            return self.client.storage.from_(bucket).download(path)
        except Exception as e:
            logger.error(f"Failed to download from storage: {e}")
            return None

    async def get_public_url(self, bucket: str, path: str) -> str:
        """Get public URL for a file."""
        return self.client.storage.from_(bucket).get_public_url(path)
