# ═══════════════════════════════════════
# Core — Permissions & Role Guards
# ═══════════════════════════════════════
from enum import Enum
from typing import List
from functools import wraps
from fastapi import Depends, HTTPException, status

from core.security import decode_access_token


class UserRole(str, Enum):
    SUPER_ADMIN = "super_admin"
    COLLEGE_ADMIN = "college_admin"
    DEPARTMENT_HEAD = "department_head"
    ACADEMIC_ADVISOR = "academic_advisor"
    VIEWER = "viewer"


# Role hierarchy: higher roles include lower permissions
ROLE_HIERARCHY = {
    UserRole.SUPER_ADMIN: 100,
    UserRole.COLLEGE_ADMIN: 80,
    UserRole.DEPARTMENT_HEAD: 60,
    UserRole.ACADEMIC_ADVISOR: 40,
    UserRole.VIEWER: 20,
}


def require_roles(allowed_roles: List[UserRole]):
    """Dependency that checks if current user has one of the allowed roles."""

    def role_checker(token_data: dict = Depends(decode_access_token)):
        user_role = token_data.get("role", "viewer")
        if user_role not in [r.value for r in allowed_roles]:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="ليس لديك صلاحية للوصول إلى هذا المورد",
            )
        return token_data

    return role_checker
