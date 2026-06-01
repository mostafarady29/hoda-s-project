# ═══════════════════════════════════════
# Expert System — Rule Executor
# ═══════════════════════════════════════
from typing import Dict, List, Tuple
from expert_system.rules.graduation_rules import GraduationRules
from expert_system.rules.prerequisite_rules import PrerequisiteRules
from expert_system.rules.warning_rules import WarningRules
from expert_system.rules.recommendation_rules import RecommendationRules


class RuleExecutor:
    """Executes all rule sets against facts and collects results."""

    def __init__(self):
        self.rule_sets = [
            GraduationRules(),
            PrerequisiteRules(),
            WarningRules(),
            RecommendationRules(),
        ]

    def execute_all(self, facts: Dict) -> Tuple[List[Dict], List[Dict]]:
        """Execute all rules and return (recommendations, warnings)."""
        all_recommendations = []
        all_warnings = []

        for rule_set in self.rule_sets:
            recs, warns = rule_set.evaluate(facts)
            all_recommendations.extend(recs)
            all_warnings.extend(warns)

        # Sort by priority
        priority_order = {"critical": 0, "high": 1, "medium": 2, "low": 3}
        all_recommendations.sort(key=lambda r: priority_order.get(r.get("priority", "medium"), 2))
        all_warnings.sort(key=lambda w: priority_order.get(w.get("severity", "warning"), 1))

        return all_recommendations, all_warnings
