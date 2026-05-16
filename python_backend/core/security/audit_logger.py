# ===== File: python_backend/core/security/audit_logger.py =====
import logging
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional
import traceback
from pythonjsonlogger import jsonlogger

class AuditLogger:
    """Advanced security and tracking system"""
    
    def __init__(self, log_dir: Path):
        self.log_dir = log_dir
        self.log_dir.mkdir(parents=True, exist_ok=True)
        
        # Setup JSON formatter for better parsing
        self._setup_loggers()
    
    def _setup_loggers(self):
        """Setup all loggers with JSON formatter"""
        
        # Audit logger (for security tracking)
        self.audit_logger = logging.getLogger("acadexa_audit")
        self.audit_logger.setLevel(logging.INFO)
        self._add_handler(self.audit_logger, "audit.log")
        
        # Error logger (for errors)
        self.error_logger = logging.getLogger("acadexa_error")
        self.error_logger.setLevel(logging.ERROR)
        self._add_handler(self.error_logger, "error.log")
        
        # Performance logger (for performance)
        self.perf_logger = logging.getLogger("acadexa_performance")
        self.perf_logger.setLevel(logging.INFO)
        self._add_handler(self.perf_logger, "performance.log")
    
    def _add_handler(self, logger: logging.Logger, filename: str):
        """Add JSON file handler to logger"""
        handler = logging.FileHandler(self.log_dir / filename, encoding='utf-8')
        
        # Create JSON formatter
        formatter = jsonlogger.JsonFormatter(
            fmt='%(asctime)s %(name)s %(levelname)s %(message)s',
            rename_fields={'asctime': 'timestamp'}
        )
        handler.setFormatter(formatter)
        
        if not logger.handlers:
            logger.addHandler(handler)
    
    def log_upload(self, job_id: str, filename: str, file_size: int, 
                   student_count: int, department: str = "unknown", ip_address: str = "unknown"):
        """Log file upload"""
        self.audit_logger.info(json.dumps({
            "event_type": "file_upload",
            "job_id": job_id,
            "filename": filename,
            "department": department,
            "file_size_bytes": file_size,
            "student_count": student_count,
            "ip_address": ip_address,
            "timestamp": datetime.utcnow().isoformat()
        }))
    
    def log_error(self, job_id: str, sheet_name: str, error_type: str, 
                  error_message: str, row_number: Optional[int] = None):
        """Log parsing errors (continuing processing)"""
        error_data = {
            "event_type": "parsing_error",
            "job_id": job_id,
            "sheet_name": sheet_name,
            "error_type": error_type,
            "error_message": error_message,
            "timestamp": datetime.utcnow().isoformat()
        }
        if row_number:
            error_data["row_number"] = row_number
        
        self.error_logger.error(json.dumps(error_data))
    
    def log_parsing_complete(self, job_id: str, total_students: int, 
                             successful: int, failed: int, department: str):
        """Log parsing completion"""
        self.audit_logger.info(json.dumps({
            "event_type": "parsing_complete",
            "job_id": job_id,
            "department": department,
            "total_students": total_students,
            "successful_students": successful,
            "failed_students": failed,
            "success_rate": f"{(successful/total_students*100):.2f}%" if total_students > 0 else "0%",
            "timestamp": datetime.utcnow().isoformat()
        }))
    
    def log_performance(self, job_id: str, operation: str, duration_ms: float):
        """Log system performance"""
        self.perf_logger.info(json.dumps({
            "event_type": "performance",
            "job_id": job_id,
            "operation": operation,
            "duration_ms": duration_ms,
            "timestamp": datetime.utcnow().isoformat()
        }))
    
    def log_access(self, job_id: str, action: str, ip_address: str):
        """Log results access"""
        self.audit_logger.info(json.dumps({
            "event_type": "data_access",
            "job_id": job_id,
            "action": action,
            "ip_address": ip_address,
            "timestamp": datetime.utcnow().isoformat()
        }))