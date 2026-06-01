# ═══════════════════════════════════════
# Schemas — Field Training
# ═══════════════════════════════════════
from pydantic import BaseModel
from typing import Optional


class FieldTrainingCreate(BaseModel):
    plan_id: str
    training_levels: int = 4
    hours_per_level: int = 2
    external_supervisor_percentage: int = 20
    internal_supervisor_percentage: int = 20
    connected_supervisor_percentage: int = 20
    final_exam_percentage: int = 40
    allow_move_training_12_to_level_2: bool = False
    allow_move_training_34_to_level_3: bool = False
    is_graduation_requirement: bool = True


class FieldTrainingUpdate(BaseModel):
    training_levels: Optional[int] = None
    hours_per_level: Optional[int] = None
    external_supervisor_percentage: Optional[int] = None
    internal_supervisor_percentage: Optional[int] = None
    connected_supervisor_percentage: Optional[int] = None
    final_exam_percentage: Optional[int] = None
    allow_move_training_12_to_level_2: Optional[bool] = None
    allow_move_training_34_to_level_3: Optional[bool] = None
    is_graduation_requirement: Optional[bool] = None


class FieldTrainingResponse(BaseModel):
    id: str
    plan_id: str
    training_levels: int
    hours_per_level: int
    external_supervisor_percentage: int
    internal_supervisor_percentage: int
    connected_supervisor_percentage: int
    final_exam_percentage: int
    allow_move_training_12_to_level_2: bool
    allow_move_training_34_to_level_3: bool
    is_graduation_requirement: bool
