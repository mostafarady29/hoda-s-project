# ═══════════════════════════════════════
# Tests — Domain Value Objects
# ═══════════════════════════════════════
import pytest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from domain.value_objects.gpa import GPA
from domain.value_objects.credit_hours import CreditHours
from domain.value_objects.prerequisite_rule import PrerequisiteRule


class TestGPA:
    def test_valid_gpa(self):
        gpa = GPA(3.5)
        assert gpa.value == 3.5
        assert gpa.is_honor is True
        assert gpa.is_passing is True
        assert gpa.rating_ar == "جيد جداً"

    def test_low_gpa(self):
        gpa = GPA(1.5)
        assert gpa.rating_ar == "مقبول"
        assert gpa.is_honor is False

    def test_invalid_gpa(self):
        with pytest.raises(Exception):
            GPA(5.0)

    def test_zero_gpa(self):
        gpa = GPA(0.0)
        assert gpa.is_passing is False
        assert gpa.rating_ar == "ضعيف"


class TestCreditHours:
    def test_valid_hours(self):
        h = CreditHours(3)
        assert h.value == 3

    def test_add(self):
        result = CreditHours(3) + CreditHours(2)
        assert result.value == 5

    def test_sub(self):
        result = CreditHours(5) - CreditHours(3)
        assert result.value == 2

    def test_sub_no_negative(self):
        result = CreditHours(2) - CreditHours(5)
        assert result.value == 0

    def test_invalid(self):
        with pytest.raises(Exception):
            CreditHours(-1)


class TestPrerequisiteRule:
    def test_all_satisfied(self):
        rule = PrerequisiteRule(course_ids=("CS101", "CS102"), logic="all")
        assert rule.is_satisfied(["CS101", "CS102", "CS103"]) is True
        assert rule.is_satisfied(["CS101"]) is False

    def test_any_satisfied(self):
        rule = PrerequisiteRule(course_ids=("CS101", "CS102"), logic="any")
        assert rule.is_satisfied(["CS101"]) is True
        assert rule.is_satisfied(["CS200"]) is False
