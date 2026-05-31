from fastapi import APIRouter, HTTPException, Query
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent.parent))

router = APIRouter(prefix="/departments", tags=["Departments"])


@router.get("/", summary="Get all departments")
async def get_departments():
    """
    Get all departments
    """
    try:
        from core.db.supabase_client import supabase
        
        result = supabase.table("departments").select("*").eq("is_active", True).order("name_ar").execute()
        
        return result.data
    except Exception as e:
        return []


@router.get("/{department_id}", summary="Get department by ID")
async def get_department(department_id: str):
    """
    Get a single department by ID
    """
    try:
        from core.db.supabase_client import supabase
        
        result = supabase.table("departments").select("*").eq("id", department_id).execute()
        
        if not result.data:
            raise HTTPException(status_code=404, detail="Department not found")
        
        return result.data[0]
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=404, detail="Department not found")