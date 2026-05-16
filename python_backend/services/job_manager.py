# ===== File: python_backend/services/job_manager.py =====

import uuid
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Optional
from enum import Enum
import threading


class JobStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    PARTIAL_SUCCESS = "partial_success"


class JobManager:

    def __init__(self, storage_dir: Path):
        self.storage_dir = storage_dir
        self.jobs_dir = storage_dir / "jobs"
        self.jobs_dir.mkdir(parents=True, exist_ok=True)

        self._jobs = {}
        self._lock = threading.Lock()

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
            "stats": {}
        }

        with self._lock:
            self._jobs[job_id] = job_data
            self._save(job_id, job_data)

        return job_id

    def update_job(self, job_id: str, **kwargs):

        with self._lock:
            if job_id in self._jobs:
                self._jobs[job_id].update(kwargs)
                self._jobs[job_id]["updated_at"] = datetime.utcnow().isoformat()
                self._save(job_id, self._jobs[job_id])

    def get_job(self, job_id: str) -> Optional[Dict]:
        with self._lock:
            return self._jobs.get(job_id)

    def _save(self, job_id: str, data: Dict):
        file_path = self.jobs_dir / f"{job_id}.json"

        with open(file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)