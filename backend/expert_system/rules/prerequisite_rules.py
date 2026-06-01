# ═══════════════════════════════════════
# Expert System — Prerequisite Rules
# ═══════════════════════════════════════
from typing import Dict, List, Tuple


class PrerequisiteRules:
    """Rules for prerequisite checking."""

    def evaluate(self, facts: Dict) -> Tuple[List[Dict], List[Dict]]:
        recommendations = []
        warnings = []

        passed = set(facts.get("passed_course_codes", []))
        courses = facts.get("courses", [])

        # Find courses available to register (prerequisites met)
        available = []
        for course in courses:
            code = course.get("code", "")
            if code in passed:
                continue  # Already passed
            prereqs = course.get("prerequisites", [])
            if not prereqs:
                available.append(code)
            else:
                prereq_codes = [p.get("required_course_code", "") for p in prereqs]
                if all(pc in passed for pc in prereq_codes):
                    available.append(code)

        if available:
            recommendations.append({
                "type": "course_suggestion",
                "priority": "medium",
                "title": "مواد متاحة للتسجيل",
                "message": f"يمكنك تسجيل {len(available)} مادة جديدة بناءً على المتطلبات المكتملة",
                "related_courses": available[:10],
            })

        return recommendations, warnings
