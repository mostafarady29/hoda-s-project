from fastapi import APIRouter, HTTPException, Query
from typing import Optional
from core.db.supabase_client import supabase

router = APIRouter(prefix="/curriculum", tags=["Curriculum"])


@router.get("/plans")
async def get_all_plans(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    is_active: Optional[bool] = None
):
    """جلب كل اللوائح الدراسية"""
    try:
        query = supabase.table("study_plans").select("*", count="exact")
        
        if is_active is not None:
            query = query.eq("status", "active" if is_active else "draft")
        
        result = query.range(offset, offset + limit - 1).order("academic_year", desc=True).execute()
        
        return {
            "plans": result.data,
            "total": result.count,
            "limit": limit,
            "offset": offset
        }
    except Exception as e:
        return {"plans": [], "total": 0, "error": str(e)}


@router.get("/plans/{plan_id}")
async def get_plan_full(plan_id: str):
    """جلب لائحة كاملة بكل تفاصيلها (مواد، متطلبات، مجموعات اختيارية)"""
    try:
        # 1. اللائحة الأساسية
        plan = supabase.table("study_plans").select("*").eq("id", plan_id).execute()
        if not plan.data:
            raise HTTPException(404, "Study plan not found")
        
        # 2. المواد
        courses = supabase.table("courses")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .order("level")\
            .order("term")\
            .execute()
        
        # 3. المتطلبات السابقة لكل مادة
        for course in courses.data:
            prereqs = supabase.table("prerequisites")\
                .select("*, required_course:courses!prerequisites_required_course_id_fkey(code, name_ar)")\
                .eq("course_id", course["id"])\
                .execute()
            course["prerequisites"] = prereqs.data
        
        # 4. المجموعات الاختيارية
        elective_groups = supabase.table("elective_groups")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .execute()
        
        for group in elective_groups.data:
            group_courses = supabase.table("elective_group_courses")\
                .select("course:courses(*)")\
                .eq("group_id", group["id"])\
                .execute()
            group["courses"] = [gc["course"] for gc in group_courses.data]
        
        # 5. هيكل الخطة
        plan_structure = supabase.table("plan_structure")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .order("level")\
            .order("term")\
            .execute()
        
        # 6. قواعد العبء الدراسي
        load_rules = supabase.table("academic_load_rules")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .execute()
        
        # 7. شروط التخرج
        grad_requirements = supabase.table("graduation_requirements")\
            .select("*")\
            .eq("plan_id", plan_id)\
            .execute()
        
        return {
            "plan": plan.data[0],
            "courses": courses.data,
            "elective_groups": elective_groups.data,
            "plan_structure": plan_structure.data,
            "academic_load_rules": load_rules.data[0] if load_rules.data else None,
            "graduation_requirements": grad_requirements.data[0] if grad_requirements.data else None
        }
    except HTTPException:
        raise
    except Exception as e:
        return {"error": str(e)}


@router.get("/plans/{plan_id}/courses")
async def get_plan_courses(
    plan_id: str,
    level: Optional[int] = None,
    term: Optional[str] = None,
    course_type: Optional[str] = None
):
    """جلب مواد لائحة معينة مع فلترة حسب المستوى والترم"""
    try:
        query = supabase.table("courses").select("*").eq("plan_id", plan_id)
        
        if level:
            query = query.eq("level", level)
        if term:
            query = query.eq("term", term)
        if course_type:
            query = query.eq("course_type", course_type)
        
        result = query.order("level").order("term").order("code").execute()
        
        return {
            "courses": result.data,
            "count": len(result.data)
        }
    except Exception as e:
        return {"courses": [], "error": str(e)}


@router.get("/courses/{course_id}/prerequisites")
async def get_course_prerequisites(course_id: str):
    """جلب المتطلبات السابقة لمادة معينة"""
    try:
        result = supabase.table("prerequisites")\
            .select("*, required_course:courses!prerequisites_required_course_id_fkey(*)")\
            .eq("course_id", course_id)\
            .execute()
        
        return {
            "course_id": course_id,
            "prerequisites": result.data
        }
    except Exception as e:
        return {"prerequisites": [], "error": str(e)}


@router.get("/elective-groups")
async def get_elective_groups(plan_id: Optional[str] = None):
    """جلب المجموعات الاختيارية"""
    try:
        query = supabase.table("elective_groups").select("*")
        
        if plan_id:
            query = query.eq("plan_id", plan_id)
        
        result = query.execute()
        
        # جلب المواد لكل مجموعة
        for group in result.data:
            courses = supabase.table("elective_group_courses")\
                .select("course:courses(*)")\
                .eq("group_id", group["id"])\
                .execute()
            group["courses"] = [c["course"] for c in courses.data]
        
        return {
            "elective_groups": result.data
        }
    except Exception as e:
        return {"elective_groups": [], "error": str(e)}


@router.get("/departments")
async def get_departments():
    """جلب كل الأقسام والبرامج"""
    try:
        result = supabase.table("departments")\
            .select("*")\
            .eq("is_active", True)\
            .order("name_ar")\
            .execute()
        
        return result.data
    except Exception as e:
        return []


@router.get("/grading-scales")
async def get_grading_scales(plan_id: Optional[str] = None):
    """جلب جداول التقديرات"""
    try:
        query = supabase.table("grading_scales").select("*")
        
        if plan_id:
            query = query.eq("plan_id", plan_id)
        
        scales = query.execute()
        
        # جلب عناصر كل مقياس
        for scale in scales.data:
            items = supabase.table("grade_scale_items")\
                .select("*")\
                .eq("grade_scale_id", scale["id"])\
                .order("min_score", desc=True)\
                .execute()
            scale["items"] = items.data
        
        return scales.data
    except Exception as e:
        return []