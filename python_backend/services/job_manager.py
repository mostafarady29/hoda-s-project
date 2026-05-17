# ===== File: python_backend/services/job_manager.py =====

import uuid
import json
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Optional, List
from enum import Enum
import threading
import logging

logger = logging.getLogger("acadexa.job_manager")


class JobStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    PARTIAL_SUCCESS = "partial_success"


class JobManager:
    """
    Thread-safe job manager.
    Persists jobs to disk so they survive restarts.
    On Railway, storage is ephemeral — that's fine for 24h retention.
    """

    def __init__(self, storage_dir: Path):
        self.storage_dir = storage_dir
        self.jobs_dir = storage_dir / "jobs"
        self.jobs_dir.mkdir(parents=True, exist_ok=True)

        self._jobs: Dict[str, Dict] = {}
        self._lock = threading.Lock()

        # Load existing jobs from disk (survives hot-reload)
        self._load_from_disk()

    # ──────────────────────────────────────────
    # Public API
    # ──────────────────────────────────────────

    def create_job(self, filename: str, file_path: Path, department: str = "") -> str:
        job_id = str(uuid.uuid4())
        job_data = {
            "job_id": job_id,
            "status": JobStatus.PENDING,
            "filename": filename,
            "department": department,
            "original_file": str(file_path),
            "created_at": datetime.utcnow().isoformat(),
            "updated_at": datetime.utcnow().isoformat(),
            "result_file": None,
            "error_log": [],
            "stats": {},
        }
        with self._lock:
            self._jobs[job_id] = job_data
            self._save(job_id, job_data)
        return job_id

    def update_job(self, job_id: str, **kwargs):
        with self._lock:
            if job_id not in self._jobs:
                return
            self._jobs[job_id].update(kwargs)
            self._jobs[job_id]["updated_at"] = datetime.utcnow().isoformat()
            self._save(job_id, self._jobs[job_id])

    def get_job(self, job_id: str) -> Optional[Dict]:
        with self._lock:
            return self._jobs.get(job_id)

    def delete_job(self, job_id: str):
        with self._lock:
            self._jobs.pop(job_id, None)
            job_file = self.jobs_dir / f"{job_id}.json"
            if job_file.exists():
                job_file.unlink()

    def list_jobs(self) -> List[Dict]:
        with self._lock:
            return list(self._jobs.values())

    def cleanup_old_jobs(self, retention_hours: int = 24):
        """Remove jobs older than retention_hours. Call from a scheduler."""
        cutoff = datetime.utcnow() - timedelta(hours=retention_hours)
        to_delete = []

        with self._lock:
            for job_id, job in self._jobs.items():
                try:
                    updated = datetime.fromisoformat(job["updated_at"])
                    if updated < cutoff and job["status"] in [
                        JobStatus.COMPLETED,
                        JobStatus.FAILED,
                        JobStatus.PARTIAL_SUCCESS,
                    ]:
                        to_delete.append(job_id)
                except Exception:
                    pass

        for job_id in to_delete:
            self.delete_job(job_id)
            logger.info(f"Cleaned up old job: {job_id}")

        return len(to_delete)

    # ──────────────────────────────────────────
    # Private helpers
    # ──────────────────────────────────────────

    def _save(self, job_id: str, data: Dict):
        try:
            file_path = self.jobs_dir / f"{job_id}.json"
            with open(file_path, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
        except Exception as e:
            logger.error(f"Failed to save job {job_id}: {e}")

    def _load_from_disk(self):
        """Load all existing job files on startup."""
        try:
            for job_file in self.jobs_dir.glob("*.json"):
                with open(job_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                job_id = data.get("job_id")
                if job_id:
                    # Mark stuck processing jobs as failed
                    if data.get("status") == JobStatus.PROCESSING:
                        data["status"] = JobStatus.FAILED
                        data["error_log"] = ["الخادم أعيد تشغيله أثناء المعالجة"]
                        self._save(job_id, data)
                    self._jobs[job_id] = data
            logger.info(f"Loaded {len(self._jobs)} jobs from disk")
        except Exception as e:
            logger.error(f"Error loading jobs from disk: {e}")