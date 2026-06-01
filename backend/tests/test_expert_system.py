# ═══════════════════════════════════════
# Tests — Expert System
# ═══════════════════════════════════════
import pytest
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from expert_system.engine.fact_builder import FactBuilder
from expert_system.rules.graduation_rules import GraduationRules
from expert_system.rules.warning_rules import WarningRules


class TestFactBuilder:
    def test_basic_facts(self, sample_student):
        courses = [
            {"code": "CS101", "credit_hours": 3},
            {"code": "CS102", "credit_hours": 3},
            {"code": "CS205", "credit_hours": 3},
            {"code": "MATH101", "credit_hours": 3},
            {"code": "CS301", "credit_hours": 3},
        ]
        facts = FactBuilder.build(sample_student, courses)
        assert facts["gpa"] == 2.85
        assert facts["earned_hours"] == 96
        assert facts["total_plan_hours"] == 15
        assert "CS301" in facts["remaining_course_codes"]

    def test_can_graduate_false(self, sample_student):
        courses = [{"code": f"C{i}", "credit_hours": 3} for i in range(50)]
        facts = FactBuilder.build(sample_student, courses)
        assert facts["can_graduate"] is False


class TestGraduationRules:
    def test_near_graduation(self):
        facts = {
            "remaining_hours": 12,
            "gpa": 3.0,
            "can_graduate": False,
            "remaining_course_codes": ["CS401", "CS402"],
        }
        recs, warns = GraduationRules().evaluate(facts)
        assert any(r["type"] == "graduation_path" for r in recs)

    def test_low_gpa_warning(self):
        facts = {
            "remaining_hours": 50,
            "gpa": 0.8,
            "can_graduate": False,
            "remaining_course_codes": [],
        }
        recs, warns = GraduationRules().evaluate(facts)
        assert any(w["severity"] == "critical" for w in warns)


class TestWarningRules:
    def test_multiple_failures(self):
        facts = {"failed_course_codes": ["A", "B", "C", "D"]}
        _, warns = WarningRules().evaluate(facts)
        assert len(warns) == 1
        assert "4 مواد" in warns[0]["message"]
