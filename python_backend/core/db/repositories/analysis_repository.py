"""
Analysis repository — storing and retrieving analysis results.
"""
from typing import Optional, List, Dict, Any
from core.db.supabase_client import get_supabase
import logging

logger = logging.getLogger("acadexa.analysis_repo")


class AnalysisRepository:

    def save_analysis(
        self,
        student_id: str,
        plan_id: Optional[str],
        gpa: float,
        attempted: int,
        passed: int,
        grad_pct: Optional[float],
        eligible: bool,
        issues: List[Dict],
        recommendations: List[Dict],
        analyzed_by: Optional[str] = None,
    ) -> str:
        sb = get_supabase()

        # Mark old analyses as not latest
        sb.table("analysis_results").update({"is_latest": False}).eq(
            "student_id", student_id
        ).eq("is_latest", True).execute()

        # Get next version
        ver_res = (
            sb.table("analysis_results")
            .select("analysis_version")
            .eq("student_id", student_id)
            .order("analysis_version", desc=True)
            .limit(1)
            .execute()
        )
        version = (ver_res.data[0]["analysis_version"] + 1) if ver_res.data else 1

        errors = sum(1 for i in issues if i.get("severity") == "error")
        warnings = sum(1 for i in issues if i.get("severity") == "warning")
        info_c = sum(1 for i in issues if i.get("severity") == "info")

        result_data = {
            "student_id": student_id,
            "plan_id": plan_id,
            "calculated_gpa": round(gpa, 2),
            "total_attempted_hours": attempted,
            "total_passed_hours": passed,
            "graduation_percentage": grad_pct,
            "is_eligible_to_graduate": eligible,
            "errors_count": errors,
            "warnings_count": warnings,
            "info_count": info_c,
            "analyzed_by": analyzed_by,
            "is_latest": True,
            "analysis_version": version,
        }

        res = sb.table("analysis_results").insert(result_data).execute()
        analysis_id = res.data[0]["id"]

        # Save issues
        if issues:
            for iss in issues:
                iss["analysis_id"] = analysis_id
                iss["student_id"] = student_id
            sb.table("analysis_issues").insert(issues).execute()

        # Save recommendations
        if recommendations:
            for rec in recommendations:
                rec["analysis_id"] = analysis_id
                rec["student_id"] = student_id
            sb.table("analysis_recommendations").insert(recommendations).execute()

        return analysis_id

    def get_latest_analysis(self, student_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = (
            sb.table("analysis_results")
            .select("*")
            .eq("student_id", student_id)
            .eq("is_latest", True)
            .execute()
        )
        if not res.data:
            return None
        result = res.data[0]
        result["issues"] = self.get_issues(result["id"])
        result["recommendations"] = self.get_recommendations(result["id"])
        return result

    def get_issues(self, analysis_id: str) -> List[Dict]:
        sb = get_supabase()
        res = sb.table("analysis_issues").select("*").eq("analysis_id", analysis_id).execute()
        return res.data or []

    def get_recommendations(self, analysis_id: str) -> List[Dict]:
        sb = get_supabase()
        res = (
            sb.table("analysis_recommendations")
            .select("*")
            .eq("analysis_id", analysis_id)
            .order("priority")
            .execute()
        )
        return res.data or []

    def get_analysis_history(self, student_id: str) -> List[Dict]:
        sb = get_supabase()
        res = (
            sb.table("analysis_results")
            .select("*")
            .eq("student_id", student_id)
            .order("analyzed_at", desc=True)
            .execute()
        )
        return res.data or []

    def get_students_needing_followup(
        self,
        department_id: Optional[str] = None,
        limit: int = 50,
    ) -> List[Dict]:
        sb = get_supabase()
        res = sb.rpc("get_students_needing_followup", {"p_limit": limit}).execute()
        return res.data or []

    def get_department_stats(self, department_id: str) -> Dict:
        sb = get_supabase()
        res = sb.rpc("get_department_statistics", {"p_department_id": department_id}).execute()
        return res.data[0] if res.data else {}

    def get_general_stats(self) -> Dict:
        sb = get_supabase()
        res = sb.rpc("get_general_statistics").execute()
        return res.data or {}