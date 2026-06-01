# ═══════════════════════════════════════
# Schemas — Prerequisite
# ═══════════════════════════════════════
from pydantic import BaseModel
from typing import Optional, List


class PrerequisiteCreate(BaseModel):
    course_id: str
    required_course_id: str
    relation_type: str = "all"
    min_grade: Optional[float] = None
    must_be_prior_semester: bool = False


class PrerequisiteBulkCreate(BaseModel):
    course_id: str
    required_course_ids: List[str]
    relation_type: str = "all"


class PrerequisiteResponse(BaseModel):
    id: str
    course_id: str
    required_course_id: str
    required_course_code: str = ""
    required_course_name: str = ""
    relation_type: str = "all"
    min_grade: Optional[float] = None
    must_be_prior_semester: bool = False
