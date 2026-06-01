# Expert System — Recommendation Rules
from typing import Dict, List, Tuple


class RecommendationRules:
    def evaluate(self, facts: Dict) -> Tuple[List[Dict], List[Dict]]:
        recommendations = []
        gpa = facts.get("gpa", 0.0)
        if gpa >= 3.5:
            recommendations.append({
                "type": "gpa_improvement",
                "priority": "low",
                "title": "أداء متميز 🌟",
                "message": "المعدل التراكمي ممتاز — حافظ على هذا المستوى!",
                "related_courses": [],
            })
        return recommendations, []
