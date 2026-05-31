"""
Curriculum repository — study plans, courses, prerequisites, elective groups.
"""
from typing import Optional, List, Dict, Any
from core.db.supabase_client import get_supabase
import logging

logger = logging.getLogger("acadexa.curriculum_repo")


class CurriculumRepository:

    # ─── Study Plans ──────────────────────────────────────────────────────────

    def create_plan(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        # Use the DB function that auto-creates grading scale etc.
        res = sb.rpc("create_study_plan", {
            "p_department_id": data["department_id"],
            "p_year": data["academic_year"],
            "p_name": data["name"],
            "p_program_id": data.get("program_id"),
            "p_total_hours": data.get("total_credit_hours", 150),
            "p_description": data.get("description"),
        }).execute()
        plan_id = res.data
        return self.get_plan(plan_id)

    def get_plan(self, plan_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("study_plans").select("*").eq("id", plan_id).execute()
        return res.data[0] if res.data else None

    def list_plans(
        self,
        department_id: Optional[str] = None,
        status: Optional[str] = None,
    ) -> List[Dict]:
        sb = get_supabase()
        q = sb.table("study_plans").select("*")
        if department_id:
            q = q.eq("department_id", department_id)
        if status:
            q = q.eq("status", status)
        q = q.order("academic_year", desc=True)
        res = q.execute()
        return res.data or []

    def update_plan(self, plan_id: str, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        res = sb.table("study_plans").update(data).eq("id", plan_id).execute()
        return res.data[0] if res.data else {}

    def delete_plan(self, plan_id: str) -> bool:
        sb = get_supabase()
        sb.table("study_plans").delete().eq("id", plan_id).execute()
        return True

    def activate_plan(self, plan_id: str) -> Dict:
        return self.update_plan(plan_id, {"status": "active", "is_current": True})

    # ─── Courses ──────────────────────────────────────────────────────────────

    def create_course(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        if "grading_config" in data and isinstance(data["grading_config"], dict):
            import json
            data["grading_config"] = json.dumps(data["grading_config"])
        res = sb.table("courses").insert(data).execute()
        return res.data[0] if res.data else {}

    def get_course(self, course_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("courses").select("*").eq("id", course_id).execute()
        return res.data[0] if res.data else None

    def get_course_by_code(self, plan_id: str, code: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("courses").select("*").eq("plan_id", plan_id).eq("code", code).execute()
        return res.data[0] if res.data else None

    def list_courses(
        self,
        plan_id: Optional[str] = None,
        level: Optional[int] = None,
        term: Optional[str] = None,
        course_type: Optional[str] = None,
    ) -> List[Dict]:
        sb = get_supabase()
        q = sb.table("courses").select("*")
        if plan_id:
            q = q.eq("plan_id", plan_id)
        if level:
            q = q.eq("level", level)
        if term:
            q = q.eq("term", term)
        if course_type:
            q = q.eq("course_type", course_type)
        q = q.order("level").order("term").order("code")
        res = q.execute()
        return res.data or []

    def update_course(self, course_id: str, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        res = sb.table("courses").update(data).eq("id", course_id).execute()
        return res.data[0] if res.data else {}

    def delete_course(self, course_id: str) -> bool:
        sb = get_supabase()
        sb.table("courses").delete().eq("id", course_id).execute()
        return True

    def bulk_create_courses(self, courses: List[Dict]) -> List[Dict]:
        sb = get_supabase()
        import json
        for c in courses:
            if "grading_config" in c and isinstance(c["grading_config"], dict):
                c["grading_config"] = json.dumps(c["grading_config"])
        res = sb.table("courses").insert(courses).execute()
        return res.data or []

    # ─── Prerequisites ────────────────────────────────────────────────────────

    def create_prerequisite(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        res = sb.table("prerequisites").insert(data).execute()
        return res.data[0] if res.data else {}

    def get_prerequisites_for_course(self, course_id: str) -> List[Dict]:
        sb = get_supabase()
        res = sb.table("prerequisites").select("*").eq("course_id", course_id).execute()
        return res.data or []

    def get_all_prerequisites_for_plan(self, plan_id: str) -> List[Dict]:
        """Get all prerequisites for all courses in a plan."""
        sb = get_supabase()
        res = (
            sb.table("prerequisites")
            .select("*, courses!prerequisites_course_id_fkey(plan_id)")
            .execute()
        )
        # Filter by plan
        return [p for p in (res.data or []) if p.get("courses", {}).get("plan_id") == plan_id]

    def delete_prerequisite(self, prereq_id: str) -> bool:
        sb = get_supabase()
        sb.table("prerequisites").delete().eq("id", prereq_id).execute()
        return True

    # ─── Course Equivalents ───────────────────────────────────────────────────

    def add_equivalent(self, course_id: str, equivalent_code: str) -> Dict:
        sb = get_supabase()
        res = sb.table("course_equivalents").insert({
            "course_id": course_id,
            "equivalent_code": equivalent_code,
        }).execute()
        return res.data[0] if res.data else {}

    def get_equivalents(self, course_id: str) -> List[str]:
        sb = get_supabase()
        res = sb.table("course_equivalents").select("equivalent_code").eq("course_id", course_id).execute()
        return [r["equivalent_code"] for r in (res.data or [])]

    def get_all_equivalents_for_plan(self, plan_id: str) -> Dict[str, List[str]]:
        """Returns {course_id: [equiv_codes]}"""
        sb = get_supabase()
        courses = self.list_courses(plan_id=plan_id)
        course_ids = [c["id"] for c in courses]
        if not course_ids:
            return {}

        res = sb.table("course_equivalents").select("*").in_("course_id", course_ids).execute()
        result: Dict[str, List[str]] = {}
        for r in (res.data or []):
            cid = r["course_id"]
            result.setdefault(cid, []).append(r["equivalent_code"])
        return result

    # ─── Elective Groups ──────────────────────────────────────────────────────

    def create_elective_group(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        course_ids = data.pop("course_ids", [])
        res = sb.table("elective_groups").insert(data).execute()
        group = res.data[0] if res.data else {}

        if group and course_ids:
            links = [{"group_id": group["id"], "course_id": cid} for cid in course_ids]
            sb.table("elective_group_courses").insert(links).execute()

        return group

    def get_elective_group(self, group_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("elective_groups").select("*").eq("id", group_id).execute()
        if not res.data:
            return None
        group = res.data[0]
        # Load courses
        c_res = sb.table("elective_group_courses").select("course_id").eq("group_id", group_id).execute()
        group["course_ids"] = [r["course_id"] for r in (c_res.data or [])]
        return group

    def list_elective_groups(self, plan_id: str) -> List[Dict]:
        sb = get_supabase()
        res = sb.table("elective_groups").select("*").eq("plan_id", plan_id).execute()
        groups = res.data or []
        for g in groups:
            c_res = sb.table("elective_group_courses").select("course_id").eq("group_id", g["id"]).execute()
            g["course_ids"] = [r["course_id"] for r in (c_res.data or [])]
        return groups

    def add_course_to_group(self, group_id: str, course_id: str) -> bool:
        sb = get_supabase()
        try:
            sb.table("elective_group_courses").insert({
                "group_id": group_id, "course_id": course_id
            }).execute()
            return True
        except Exception:
            return False

    def remove_course_from_group(self, group_id: str, course_id: str) -> bool:
        sb = get_supabase()
        sb.table("elective_group_courses").delete().eq("group_id", group_id).eq("course_id", course_id).execute()
        return True

    def delete_elective_group(self, group_id: str) -> bool:
        sb = get_supabase()
        sb.table("elective_group_courses").delete().eq("group_id", group_id).execute()
        sb.table("elective_groups").delete().eq("id", group_id).execute()
        return True

    # ─── Plan Structure ───────────────────────────────────────────────────────

    def upsert_plan_structure(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        existing = (
            sb.table("plan_structure")
            .select("id")
            .eq("plan_id", data["plan_id"])
            .eq("level", data["level"])
            .eq("term", data["term"])
            .execute()
        )
        if existing.data:
            row_id = existing.data[0]["id"]
            res = sb.table("plan_structure").update(data).eq("id", row_id).execute()
            return res.data[0] if res.data else {}
        else:
            res = sb.table("plan_structure").insert(data).execute()
            return res.data[0] if res.data else {}

    def get_plan_structure(self, plan_id: str) -> List[Dict]:
        sb = get_supabase()
        res = (
            sb.table("plan_structure")
            .select("*")
            .eq("plan_id", plan_id)
            .order("level")
            .order("term")
            .execute()
        )
        return res.data or []

    # ─── Academic Load Rules ──────────────────────────────────────────────────

    def get_load_rules(self, plan_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("academic_load_rules").select("*").eq("plan_id", plan_id).execute()
        return res.data[0] if res.data else None

    def upsert_load_rules(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        existing = sb.table("academic_load_rules").select("id").eq("plan_id", data["plan_id"]).execute()
        if existing.data:
            rid = existing.data[0]["id"]
            res = sb.table("academic_load_rules").update(data).eq("id", rid).execute()
            return res.data[0] if res.data else {}
        else:
            res = sb.table("academic_load_rules").insert(data).execute()
            return res.data[0] if res.data else {}

    # ─── Graduation Requirements ──────────────────────────────────────────────

    def get_graduation_requirements(self, plan_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("graduation_requirements").select("*").eq("plan_id", plan_id).execute()
        return res.data[0] if res.data else None

    def upsert_graduation_requirements(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        existing = sb.table("graduation_requirements").select("id").eq("plan_id", data["plan_id"]).execute()
        if existing.data:
            rid = existing.data[0]["id"]
            res = sb.table("graduation_requirements").update(data).eq("id", rid).execute()
            return res.data[0] if res.data else {}
        else:
            res = sb.table("graduation_requirements").insert(data).execute()
            return res.data[0] if res.data else {}

    # ─── Field Training Rules ─────────────────────────────────────────────────

    def get_field_training_rules(self, plan_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("field_training_rules").select("*").eq("plan_id", plan_id).execute()
        return res.data[0] if res.data else None

    def upsert_field_training_rules(self, data: Dict[str, Any]) -> Dict:
        sb = get_supabase()
        existing = sb.table("field_training_rules").select("id").eq("plan_id", data["plan_id"]).execute()
        if existing.data:
            rid = existing.data[0]["id"]
            res = sb.table("field_training_rules").update(data).eq("id", rid).execute()
            return res.data[0] if res.data else {}
        else:
            res = sb.table("field_training_rules").insert(data).execute()
            return res.data[0] if res.data else {}

    # ─── Grading Scales ───────────────────────────────────────────────────────

    def get_grading_scale(self, scale_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("grading_scales").select("*").eq("id", scale_id).execute()
        if not res.data:
            return None
        scale = res.data[0]
        items_res = sb.table("grade_scale_items").select("*").eq("grade_scale_id", scale_id).execute()
        scale["items"] = items_res.data or []
        return scale

    def get_default_grading_scale(self, plan_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("grading_scales").select("*").eq("plan_id", plan_id).eq("is_default", True).execute()
        if not res.data:
            return None
        return self.get_grading_scale(res.data[0]["id"])

    def list_grading_scales(self, plan_id: str) -> List[Dict]:
        sb = get_supabase()
        res = sb.table("grading_scales").select("*").eq("plan_id", plan_id).execute()
        scales = res.data or []
        for s in scales:
            items_res = sb.table("grade_scale_items").select("*").eq("grade_scale_id", s["id"]).execute()
            s["items"] = items_res.data or []
        return scales

    def create_grading_scale(self, data: Dict, items: List[Dict]) -> Dict:
        sb = get_supabase()
        res = sb.table("grading_scales").insert(data).execute()
        scale = res.data[0] if res.data else {}
        if scale and items:
            for item in items:
                item["grade_scale_id"] = scale["id"]
            sb.table("grade_scale_items").insert(items).execute()
        return scale

    # ─── Departments ──────────────────────────────────────────────────────────

    def list_departments(self, is_active: bool = True) -> List[Dict]:
        sb = get_supabase()
        res = sb.table("departments").select("*").eq("is_active", is_active).execute()
        return res.data or []

    def get_department(self, dept_id: str) -> Optional[Dict]:
        sb = get_supabase()
        res = sb.table("departments").select("*").eq("id", dept_id).execute()
        return res.data[0] if res.data else None

    def create_department(self, data: Dict) -> Dict:
        sb = get_supabase()
        res = sb.table("departments").insert(data).execute()
        return res.data[0] if res.data else {}

    def update_department(self, dept_id: str, data: Dict) -> Dict:
        sb = get_supabase()
        res = sb.table("departments").update(data).eq("id", dept_id).execute()
        return res.data[0] if res.data else {}

    # ─── Programs ─────────────────────────────────────────────────────────────

    def list_programs(self, is_active: bool = True) -> List[Dict]:
        sb = get_supabase()
        res = sb.table("programs").select("*").eq("is_active", is_active).execute()
        return res.data or []

    def create_program(self, data: Dict) -> Dict:
        sb = get_supabase()
        res = sb.table("programs").insert(data).execute()
        return res.data[0] if res.data else {}

    # ─── Full curriculum export ───────────────────────────────────────────────

    def get_full_curriculum(self, plan_id: str) -> Dict:
        plan = self.get_plan(plan_id)
        if not plan:
            raise ValueError(f"Plan {plan_id} not found")

        courses = self.list_courses(plan_id=plan_id)
        prerequisites = self.get_all_prerequisites_for_plan(plan_id)
        elective_groups = self.list_elective_groups(plan_id)
        plan_structure = self.get_plan_structure(plan_id)
        grading_scales = self.list_grading_scales(plan_id)
        load_rules = self.get_load_rules(plan_id)
        grad_req = self.get_graduation_requirements(plan_id)
        ft_rules = self.get_field_training_rules(plan_id)

        return {
            "plan": plan,
            "courses": courses,
            "prerequisites": prerequisites,
            "elective_groups": elective_groups,
            "plan_structure": plan_structure,
            "grading_scales": grading_scales,
            "academic_load_rules": load_rules,
            "graduation_requirements": grad_req,
            "field_training_rules": ft_rules,
        }