# ===== File: python_backend/services/job_manager.py =====
import uuid
import json
import asyncio
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Any, Optional
from enum import Enum
import threading

class JobStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
    PARTIAL_SUCCESS = "partial_success"

class JobManager:
    """Job management - thread-safe with automatic cleanup"""
    
    def __init__(self, storage_dir: Path):
        self.storage_dir = storage_dir
        self.jobs_dir = storage_dir / "jobs"
        self.jobs_dir.mkdir(parents=True, exist_ok=True)
        
        # In-memory cache with lock for thread safety
        self._jobs = {}
        self._lock = threading.Lock()
        
        # Clean up old jobs on startup
        self._cleanup_old_jobs()
        
    def create_job(self, filename: str, file_path: Path, department: str = "") -> str:
        """Create new job"""
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
            "stats": {
                "total_students": 0,
                "successful": 0,
                "failed": 0
            }
        }
        
        with self._lock:
            self._jobs[job_id] = job_data
            self._save_job(job_id, job_data)
        
        return job_id
    
    def update_job(self, job_id: str, **kwargs):
        """Update job"""
        with self._lock:
            if job_id in self._jobs:
                self._jobs[job_id].update(kwargs)
                self._jobs[job_id]["updated_at"] = datetime.utcnow().isoformat()
                self._save_job(job_id, self._jobs[job_id])
    
    def get_job(self, job_id: str) -> Optional[Dict]:
        """Get job"""
        # Check memory first
        with self._lock:
            if job_id in self._jobs:
                return self._jobs[job_id].copy()
        
        # Try to load from disk
        job_file = self.jobs_dir / f"{job_id}.json"
        if job_file.exists():
            with open(job_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        
        return None
    
    def _save_job(self, job_id: str, job_data: Dict):
        """Save job to disk"""
        job_file = self.jobs_dir / f"{job_id}.json"
        with open(job_file, 'w', encoding='utf-8') as f:
            json.dump(job_data, f, indent=2, ensure_ascii=False)
    
    def delete_job(self, job_id: str):
        """Delete job and related files"""
        job = self.get_job(job_id)
        if job:
            # Delete original file
            original_file = Path(job.get("original_file", ""))
            if original_file.exists():
                original_file.unlink()
            
            # Delete result file
            result_file = Path(job.get("result_file", ""))
            if result_file.exists():
                result_file.unlink()
            
            # Delete metadata
            job_file = self.jobs_dir / f"{job_id}.json"
            if job_file.exists():
                job_file.unlink()
            
            with self._lock:
                if job_id in self._jobs:
                    del self._jobs[job_id]
    
    def _start_cleanup_task(self):
        """Start periodic cleanup task every 24 hours"""
        def cleanup_loop():
            while True:
                try:
                    self._cleanup_old_jobs()
                except Exception as e:
                    print(f"Cleanup error: {e}")
                # Wait 24 hours before next cleanup
                threading.Timer(86400, cleanup_loop).start()
        
        # Start cleanup after one hour from server startup
        threading.Timer(3600, cleanup_loop).start()
    
    def _cleanup_old_jobs(self):
        """Delete jobs older than 7 days"""
        cutoff_time = datetime.utcnow() - timedelta(days=7)
        deleted_count = 0
        
        for job_file in self.jobs_dir.glob("*.json"):
            try:
                with open(job_file, 'r', encoding='utf-8') as f:
                    job_data = json.load(f)
                
                created_at = datetime.fromisoformat(job_data.get("created_at", "2000-01-01"))
                
                if created_at < cutoff_time:
                    self.delete_job(job_data["job_id"])
                    deleted_count += 1
                    
            except Exception as e:
                print(f"Error cleaning job {job_file}: {e}")
        
        if deleted_count > 0:
            print(f"🧹 Cleaned up {deleted_count} old jobs")


# ===== Compatibility function for jobs.py =====
def get_job(job_id: str):
    """Compatibility function for jobs.py"""
    from pathlib import Path
    manager = JobManager(Path(__file__).parent.parent / "storage")
    return manager.get_job(job_id)