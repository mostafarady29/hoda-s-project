# ═══════════════════════════════════════
# Repositories — Audit Log
# ═══════════════════════════════════════
from typing import List, Dict
from datetime import datetime
from repositories.base_repository import BaseRepository


class AuditRepository(BaseRepository):
    def __init__(self, client):
        super().__init__(client, "audit_logs")

    async def log_action(
        self, user_id: str, action: str, entity: str, entity_id: str, details: dict = None
    ) -> None:
        await self.create({
            "user_id": user_id,
            "action": action,
            "entity": entity,
            "entity_id": entity_id,
            "details": details or {},
            "timestamp": datetime.utcnow().isoformat(),
        })

    async def find_by_entity(self, entity: str, entity_id: str) -> List[Dict]:
        result = (
            self._table().select("*")
            .eq("entity", entity)
            .eq("entity_id", entity_id)
            .order("timestamp", desc=True)
            .execute()
        )
        return result.data or []
