# ═══════════════════════════════════════
# Domain — Value Objects: GPA
# ═══════════════════════════════════════
from dataclasses import dataclass
from core.exceptions import ValidationError


@dataclass(frozen=True)
class GPA:
    """Immutable GPA value object with validation."""
    value: float

    def __post_init__(self):
        if not (0.0 <= self.value <= 4.0):
            raise ValidationError(f"GPA غير صالح: {self.value}")

    @property
    def rating_ar(self) -> str:
        if self.value >= 3.7:
            return "ممتاز"
        elif self.value >= 3.0:
            return "جيد جداً"
        elif self.value >= 2.0:
            return "جيد"
        elif self.value >= 1.0:
            return "مقبول"
        else:
            return "ضعيف"

    @property
    def is_passing(self) -> bool:
        return self.value >= 0.7

    @property
    def is_honor(self) -> bool:
        return self.value >= 3.5
