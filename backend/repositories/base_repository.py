# ═══════════════════════════════════════
# Repositories — Base Repository
# ═══════════════════════════════════════
from typing import Optional, List, Dict, Any, TypeVar, Generic
from core.logger import logger

T = TypeVar("T")


class BaseRepository:
    """
    Base repository providing common Supabase CRUD operations.
    All repositories inherit from this.
    """

    def __init__(self, client, table_name: str):
        self.client = client
        self.table_name = table_name

    def _table(self):
        """Get Supabase table reference."""
        if self.client is None:
            raise RuntimeError(f"Supabase client not initialized for table: {self.table_name}")
        return self.client.table(self.table_name)

    async def find_by_id(self, record_id: str) -> Optional[Dict]:
        """Find a single record by ID."""
        try:
            result = self._table().select("*").eq("id", record_id).single().execute()
            return result.data
        except Exception as e:
            logger.error(f"find_by_id error on {self.table_name}: {e}")
            return None

    async def find_all(
        self,
        filters: Dict[str, Any] = None,
        order_by: str = "created_at",
        ascending: bool = False,
        page: int = 1,
        page_size: int = 20,
    ) -> tuple[List[Dict], int]:
        """Find all records with optional filters and pagination."""
        try:
            query = self._table().select("*", count="exact")

            if filters:
                for key, value in filters.items():
                    if value is not None:
                        query = query.eq(key, value)

            query = query.order(order_by, desc=not ascending)

            # Pagination
            start = (page - 1) * page_size
            end = start + page_size - 1
            query = query.range(start, end)

            result = query.execute()
            return result.data or [], result.count or 0
        except Exception as e:
            logger.error(f"find_all error on {self.table_name}: {e}")
            return [], 0

    async def create(self, data: Dict) -> Optional[Dict]:
        """Create a new record."""
        try:
            result = self._table().insert(data).execute()
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error(f"create error on {self.table_name}: {e}")
            raise

    async def update(self, record_id: str, data: Dict) -> Optional[Dict]:
        """Update a record by ID."""
        try:
            result = self._table().update(data).eq("id", record_id).execute()
            return result.data[0] if result.data else None
        except Exception as e:
            logger.error(f"update error on {self.table_name}: {e}")
            raise

    async def delete(self, record_id: str) -> bool:
        """Delete a record by ID."""
        try:
            self._table().delete().eq("id", record_id).execute()
            return True
        except Exception as e:
            logger.error(f"delete error on {self.table_name}: {e}")
            return False

    async def bulk_create(self, records: List[Dict]) -> List[Dict]:
        """Create multiple records at once."""
        try:
            result = self._table().insert(records).execute()
            return result.data or []
        except Exception as e:
            logger.error(f"bulk_create error on {self.table_name}: {e}")
            raise

    async def count(self, filters: Dict[str, Any] = None) -> int:
        """Count records with optional filters."""
        try:
            query = self._table().select("id", count="exact")
            if filters:
                for key, value in filters.items():
                    if value is not None:
                        query = query.eq(key, value)
            result = query.execute()
            return result.count or 0
        except Exception as e:
            logger.error(f"count error on {self.table_name}: {e}")
            return 0
