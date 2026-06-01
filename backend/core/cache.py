# ═══════════════════════════════════════
# Core — Cache (optional Redis)
# ═══════════════════════════════════════
from typing import Optional, Any
from functools import lru_cache
import json

from core.config import settings
from core.logger import logger


class InMemoryCache:
    """Simple in-memory cache fallback when Redis is not available."""

    def __init__(self):
        self._store: dict = {}

    async def get(self, key: str) -> Optional[str]:
        return self._store.get(key)

    async def set(self, key: str, value: str, ttl: int = 3600):
        self._store[key] = value

    async def delete(self, key: str):
        self._store.pop(key, None)

    async def clear(self):
        self._store.clear()


# Singleton cache instance
_cache: Optional[InMemoryCache] = None


def get_cache() -> InMemoryCache:
    """Get cache instance. Uses Redis if configured, else in-memory."""
    global _cache
    if _cache is None:
        if settings.REDIS_URL:
            logger.info("Redis URL configured but Redis client not implemented — using in-memory cache")
        _cache = InMemoryCache()
    return _cache
