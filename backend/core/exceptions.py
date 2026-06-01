# ═══════════════════════════════════════
# Core — Custom Exceptions
# ═══════════════════════════════════════
from typing import Optional, Any


class AcadexaException(Exception):
    """Base exception for all Acadexa errors."""

    def __init__(self, message: str, code: str = "UNKNOWN_ERROR", details: Optional[Any] = None):
        self.message = message
        self.code = code
        self.details = details
        super().__init__(self.message)


class EntityNotFoundError(AcadexaException):
    """Raised when an entity is not found."""

    def __init__(self, entity: str, identifier: str):
        super().__init__(
            message=f"{entity} غير موجود: {identifier}",
            code="NOT_FOUND",
            details={"entity": entity, "id": identifier},
        )


class DuplicateEntityError(AcadexaException):
    """Raised when trying to create a duplicate entity."""

    def __init__(self, entity: str, field: str, value: str):
        super().__init__(
            message=f"{entity} موجود بالفعل: {field}={value}",
            code="DUPLICATE",
            details={"entity": entity, "field": field, "value": value},
        )


class ValidationError(AcadexaException):
    """Raised for domain-level validation failures."""

    def __init__(self, message: str, details: Optional[Any] = None):
        super().__init__(message=message, code="VALIDATION_ERROR", details=details)


class FileProcessingError(AcadexaException):
    """Raised when file processing fails."""

    def __init__(self, message: str, filename: str = ""):
        super().__init__(
            message=message,
            code="FILE_PROCESSING_ERROR",
            details={"filename": filename},
        )


class AuthenticationError(AcadexaException):
    """Raised for authentication failures."""

    def __init__(self, message: str = "فشل المصادقة"):
        super().__init__(message=message, code="AUTH_ERROR")


class AuthorizationError(AcadexaException):
    """Raised when user lacks permissions."""

    def __init__(self, message: str = "غير مصرح"):
        super().__init__(message=message, code="FORBIDDEN")


class JobError(AcadexaException):
    """Raised for job processing errors."""

    def __init__(self, job_id: str, message: str):
        super().__init__(
            message=message,
            code="JOB_ERROR",
            details={"job_id": job_id},
        )
