# ═══════════════════════════════════════
# Jobs — Cleanup Job
# ═══════════════════════════════════════
"""Periodic cleanup of old data."""
from core.logger import logger


async def cleanup_old_analysis(supabase_client, retention_days: int = 30):
    """Remove analysis results older than retention period."""
    from datetime import datetime, timedelta
    cutoff = (datetime.utcnow() - timedelta(days=retention_days)).isoformat()
    try:
        supabase_client.table("analysis_results").delete().lt("analyzed_at", cutoff).execute()
        logger.info(f"Cleaned up analysis results older than {retention_days} days")
    except Exception as e:
        logger.error(f"Cleanup job failed: {e}")


async def cleanup_stuck_jobs(supabase_client):
    """Mark stuck 'processing' jobs as failed."""
    from repositories.import_job_repository import ImportJobRepository
    repo = ImportJobRepository(supabase_client)
    stuck = await repo.find_stuck_jobs()
    for job in stuck:
        await repo.mark_failed(job["id"], "المهمة توقفت — يرجى المحاولة مرة أخرى")
    if stuck:
        logger.info(f"Marked {len(stuck)} stuck jobs as failed")
