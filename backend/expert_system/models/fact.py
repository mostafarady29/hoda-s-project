# Expert System models
from dataclasses import dataclass, field
from typing import List, Any


@dataclass
class Fact:
    name: str
    value: Any


@dataclass
class Rule:
    name: str
    conditions: List[str] = field(default_factory=list)
    actions: List[str] = field(default_factory=list)
    priority: int = 0


@dataclass
class RecommendationModel:
    type: str
    priority: str
    title: str
    message: str
    related_courses: List[str] = field(default_factory=list)
