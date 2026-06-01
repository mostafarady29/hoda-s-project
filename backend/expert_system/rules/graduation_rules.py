# ═══════════════════════════════════════
# Expert System — Graduation Rules
# ═══════════════════════════════════════
from typing import Dict, List, Tuple


class GraduationRules:
    """Rules related to graduation readiness."""

    def evaluate(self, facts: Dict) -> Tuple[List[Dict], List[Dict]]:
        recommendations = []
        warnings = []

        remaining = facts.get("remaining_hours", 0)
        gpa = facts.get("gpa", 0.0)

        if remaining <= 18 and remaining > 0:
            recommendations.append({
                "type": "graduation_path",
                "priority": "high",
                "title": "قريب من التخرج",
                "message": f"متبقي {remaining} ساعة فقط للتخرج. ركز على إتمام المواد المتبقية.",
                "related_courses": facts.get("remaining_course_codes", [])[:5],
            })

        if facts.get("can_graduate"):
            recommendations.append({
                "type": "graduation_path",
                "priority": "critical",
                "title": "مؤهل للتخرج! 🎓",
                "message": "أكملت جميع متطلبات التخرج. تقدم بطلب التخرج.",
                "related_courses": [],
            })

        if gpa < 1.0 and gpa > 0:
            warnings.append({
                "type": "gpa_critical",
                "severity": "critical",
                "message": f"المعدل التراكمي ({gpa:.2f}) منخفض جداً — خطر الفصل",
                "details": "يجب رفع المعدل فوراً",
            })
        elif gpa < 2.0:
            warnings.append({
                "type": "gpa_low",
                "severity": "warning",
                "message": f"المعدل التراكمي ({gpa:.2f}) أقل من 2.0",
                "details": "حاول التركيز على المواد ذات الساعات المعتمدة العالية",
            })

        return recommendations, warnings
