# ═══════════════════════════════════════
# Core — Validators
# ═══════════════════════════════════════
import re
from typing import Optional
from pathlib import Path

from core.config import settings
from core.exceptions import ValidationError


def validate_file_extension(filename: str) -> str:
    """Validate uploaded file has an allowed extension."""
    ext = Path(filename).suffix.lower()
    if ext not in settings.ALLOWED_EXTENSIONS:
        raise ValidationError(
            f"نوع الملف غير مسموح: {ext}. الأنواع المسموحة: {', '.join(settings.ALLOWED_EXTENSIONS)}",
            details={"extension": ext, "allowed": list(settings.ALLOWED_EXTENSIONS)},
        )
    return ext


def validate_file_size(size: int) -> int:
    """Validate file size is within limits."""
    if size > settings.MAX_FILE_SIZE:
        max_mb = settings.MAX_FILE_SIZE // (1024 * 1024)
        raise ValidationError(
            f"حجم الملف كبير جداً. الحد الأقصى {max_mb} MB",
            details={"size": size, "max_size": settings.MAX_FILE_SIZE},
        )
    return size


def validate_student_id(student_id: str) -> str:
    """Validate student ID format."""
    if not student_id or not student_id.strip():
        raise ValidationError("رقم الطالب مطلوب")
    return student_id.strip()


def validate_gpa(gpa: float) -> float:
    """Validate GPA is within valid range."""
    if not (0.0 <= gpa <= 4.0):
        raise ValidationError(
            f"المعدل التراكمي غير صالح: {gpa}. يجب أن يكون بين 0.0 و 4.0",
            details={"gpa": gpa},
        )
    return gpa


def validate_credit_hours(hours: int) -> int:
    """Validate credit hours value."""
    if hours < 0 or hours > 200:
        raise ValidationError(
            f"عدد الساعات غير صالح: {hours}",
            details={"hours": hours},
        )
    return hours
