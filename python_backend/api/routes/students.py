from fastapi import APIRouter, HTTPException, Query
from typing import Optional
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

router = APIRouter(prefix="/students", tags=["Students"])


@router.get("/", summary="Get all students")
async def get_all_students(
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    department_code: Optional[str] = None
):
    """
    Get list of all students from database
    """
    try:
        from core.db.supabase_client import supabase
        
        query = supabase.table("students").select("*", count="exact")
        
        if department_code:
            query = query.eq("department_code", department_code)
        
        result = query.range(offset, offset + limit - 1).order("created_at", desc=True).execute()
        
        return {
            "students": result.data,
            "total": result.count,
            "limit": limit,
            "offset": offset
        }
    except Exception as e:
        # Return empty list if table doesn't exist yet
        return {
            "students": [],
            "total": 0,
            "limit": limit,
            "offset": offset,
            "message": "Database not fully configured yet"
        }


@router.get("/{student_id}", summary="Get student by ID")
async def get_student_by_id(student_id: str):
    """
    Get a single student by their UUID
    """
    try:
        from core.db.supabase_client import supabase
        
        result = supabase.table("students").select("*").eq("id", student_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Student not found")
        
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        return {"id": student_id, "message": "Student data not available", "error": str(e)}


@router.get("/code/{student_code}", summary="Get student by code")
async def get_student_by_code(student_code: str):
    """
    Get a single student by their student code
    """
    try:
        from core.db.supabase_client import supabase
        
        result = supabase.table("students").select("*").eq("student_code", student_code).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Student not found")
        
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        return {"student_code": student_code, "message": "Student data not available", "error": str(e)}


@router.get("/{student_id}/full", summary="Get student with all data (semesters + courses)")
async def get_student_full(student_id: str):
    """
    Get complete student record with all semesters and courses
    """
    try:
        from core.db.supabase_client import supabase
        
        # Get student
        student = supabase.table("students").select("*").eq("id", student_id).execute()
        
        if not student.data:
            raise HTTPException(status_code=404, detail="Student not found")
        
        # Get semesters
        semesters = supabase.table("student_semesters")\
            .select("*")\
            .eq("student_id", student_id)\
            .order("semester_number")\
            .execute()
        
        # Get courses for each semester
        for sem in semesters.data:
            courses = supabase.table("student_courses")\
                .select("*")\
                .eq("semester_id", sem["id"])\
                .order("created_at")\
                .execute()
            sem["courses"] = courses.data
        
        # Get latest analysis
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
    except HTTPException:
        raise
    except Exception as e:
        return {
            "student": {"id": student_id},
            "message": "Complete data not available yet",
            "error": str(e)
        }