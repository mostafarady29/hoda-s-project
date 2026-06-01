# ═══════════════════════════════════════
# Domain — Value Objects: Credit Hours
# ═══════════════════════════════════════
from dataclasses import dataclass
from core.exceptions import ValidationError


@dataclass(frozen=True)
class CreditHours:
    """Immutable credit hours value object."""
    value: int

    def __post_init__(self):
        if self.value < 0 or self.value > 200:
            raise ValidationError(f"عدد الساعات غير صالح: {self.value}")

    def __add__(self, other: "CreditHours") -> "CreditHours":
        return CreditHours(self.value + other.value)

    def __sub__(self, other: "CreditHours") -> "CreditHours":
        return CreditHours(max(0, self.value - other.value))
