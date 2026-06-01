# ═══════════════════════════════════════
# Expert System — Inference Engine
# ═══════════════════════════════════════
from typing import Dict, List
from datetime import datetime
from core.logger import logger


class InferenceEngine:
    """
    Core inference engine for the expert system.
    Loads rules, builds facts from student data, and executes analysis.
    """

    def __init__(self):
        self.rules = []

    async def analyze(self, student: Dict, courses: List[Dict], plan_id: str) -> Dict:
        """Run full analysis pipeline for a student."""
        logger.info(f"Running analysis for student: {student.get('student_code', 'unknown')}")

        # Build facts from student data
        from expert_system.engine.fact_builder import FactBuilder
        facts = FactBuilder.build(student, courses)

        # Load and execute rules
        from expert_system.engine.rule_executor import RuleExecutor
        executor = RuleExecutor()
        recommendations, warnings = executor.execute_all(facts)

        # Build result
        result = {
            "student_id": student.get("id", ""),
            "plan_id": plan_id,
            "analyzed_at": datetime.utcnow().isoformat(),
            "cumulative_gpa": student.get("cumulative_gpa", 0.0),
            "total_earned_hours": student.get("total_earned_hours", 0),
            "remaining_hours": facts.get("remaining_hours", 0),
            "current_level": student.get("current_level", 1),
            "can_graduate": facts.get("can_graduate", False),
            "graduation_blockers": facts.get("graduation_blockers", []),
            "recommendations": recommendations,
            "warnings": warnings,
            "passed_courses": facts.get("passed_course_codes", []),
            "failed_courses": facts.get("failed_course_codes", []),
            "remaining_courses": facts.get("remaining_course_codes", []),
        }

        return result
