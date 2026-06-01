# Expert System — Warning Rules
from typing import Dict, List, Tuple


class WarningRules:
    def evaluate(self, facts: Dict) -> Tuple[List[Dict], List[Dict]]:
        warnings = []
        failed = facts.get("failed_course_codes", [])
        if len(failed) > 3:
            warnings.append({
                "type": "multiple_failures",
                "severity": "warning",
                "message": f"الطالب راسب في {len(failed)} مواد",
                "details": "يُنصح بمقابلة المرشد الأكاديمي",
            })
        return [], warnings
