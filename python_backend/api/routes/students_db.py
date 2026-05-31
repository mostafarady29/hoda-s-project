from fastapi import APIRouter, HTTPException, Query
from core.db.supabase_client import supabase

router = APIRouter()

@router.get("/db/students", summary="جلب كل الطلاب من قاعدة البيانات")
async def get_all_students(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0)
):
    result = supabase.table("students")\
        .select("id, student_code, name, department_id, study_level, is_active")\
        .range(offset, offset + limit - 1)\
        .order("created_at", desc=True)\
        .execute()
    
    return {
        "students": result.data,
        "total": len(result.data),
        "limit": limit,
        "offset": offset
    }

@router.get("/db/students/{student_id}", summary="جلب طالب واحد مع كل بياناته (الفصول والمواد)")
async def get_student_full(student_id: str):
    # 1. جلب بيانات الطالب
    student = supabase.table("students")\
        .select("*")\
        .eq("id", student_id)\
        .execute()
    
    if not student.data:
        raise HTTPException(404, "Student not found")
    
    # 2. جلب الفصول الدراسية
    semesters = supabase.table("student_semesters")\
        .select("*")\
        .eq("student_id", student_id)\
        .order("semester_number")\
        .execute()
    
    # 3. جلب المواد لكل فصل
    for sem in semesters.data:
        courses = supabase.table("student_courses")\
            .select("*")\
            .eq("semester_id", sem["id"])\
            .order("created_at")\
            .execute()
        sem["courses"] = courses.data
    
    # 4. جلب آخر تحليل للطالب
    analysis = supabase.table("analysis_results")\
        .select("*")\
        .eq("student_id", student_id)\
        .eq("is_latest", True)\
        .execute()
    
    return {
        "student": student.data[0],
        "semesters": semesters.data,
        "latest_analysis": analysis.data[0] if analysis.data else None
    }

@router.get("/db/students/{student_id}/analysis", summary="جلب تحليل الطالب")
async def get_student_analysis(student_id: str):
    result = supabase.table("analysis_results")\
        .select("*, analysis_issues(*), analysis_recommendations(*)")\
        .eq("student_id", student_id)\
        .eq("is_latest", True)\
        .execute()
    
    if not result.data:
        return {"message": "No analysis found for this student"}
    
    return result.data[0]