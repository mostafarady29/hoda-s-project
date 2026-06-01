# ═══════════════════════════════════════
# Expert System — Fact Builder
# ═══════════════════════════════════════
from typing import Dict, List


class FactBuilder:
    """Transforms raw student and course data into structured facts for rule execution."""

    @staticmethod
    def build(student: Dict, courses: List[Dict]) -> Dict:
        """Build a fact dictionary from student and course data."""
        total_plan_hours = sum(c.get("credit_hours", 0) for c in courses)
        earned_hours = student.get("total_earned_hours", 0)
        gpa = student.get("cumulative_gpa", 0.0)

        # Identify passed/failed/remaining courses
        passed_codes = set(student.get("passed_courses", []))
        all_codes = set(c.get("code", "") for c in courses)
        remaining_codes = all_codes - passed_codes
        failed_codes = set(student.get("failed_courses", []))

        # Graduation check
        remaining_hours = max(0, total_plan_hours - earned_hours)
        can_graduate = remaining_hours == 0 and gpa >= 0.7

        graduation_blockers = []
        if remaining_hours > 0:
            graduation_blockers.append(f"متبقي {remaining_hours} ساعة")
        if gpa < 0.7:
            graduation_blockers.append(f"المعدل التراكمي ({gpa:.2f}) أقل من الحد الأدنى (0.7)")

        return {
            "student_id": student.get("id", ""),
            "gpa": gpa,
            "earned_hours": earned_hours,
            "total_plan_hours": total_plan_hours,
            "remaining_hours": remaining_hours,
            "current_level": student.get("current_level", 1),
            "passed_course_codes": list(passed_codes),
            "failed_course_codes": list(failed_codes),
            "remaining_course_codes": list(remaining_codes),
            "can_graduate": can_graduate,
            "graduation_blockers": graduation_blockers,
            "courses": courses,
        }
