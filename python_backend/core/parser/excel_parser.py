# ===== File: core/parser/excel_parser.py (معدل) =====
"""
Excel Parser v2.1 - معدل للكتابة مباشرة في Supabase
بدلاً من حفظ JSON files
"""

import openpyxl
from pathlib import Path
from typing import Dict, List, Any, Tuple
from datetime import datetime
from supabase import create_client, Client
import os
from dotenv import load_dotenv

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")

def clean(value):
    if value is None:
        return ""
    return str(value).strip()

def get_cell(ws, col_letter, row_idx):
    try:
        return ws[f"{col_letter}{row_idx}"].value
    except:
        return None

def find_first_semester_row(ws):
    """Find the first semester data row"""
    for row in range(1, min(100, ws.max_row + 1)):
        for col in range(1, min(ws.max_column + 1, 30)):
            val = clean(ws.cell(row, col).value)
            if 'القسم/الشعبة' in val:
                return row, col
    return None, None

def detect_offset(ws):
    """
    Determine the offset between the current sheet and the reference sheet
    based on the location of the first cell containing 'القسم/الشعبة'
    """
    ref_row, ref_col = find_first_semester_row(ws)
    if ref_row and ref_col:
        row_offset = ref_row - 40
        col_offset = ref_col - 11
        return row_offset, col_offset
    return 0, 0

def get_cell_with_offset(ws, base_col_letter, base_row, row_offset, col_offset):
    """Get cell with offset applied"""
    base_col_num = openpyxl.utils.column_index_from_string(base_col_letter)
    new_col_num = base_col_num + col_offset
    new_col_letter = openpyxl.utils.get_column_letter(new_col_num)
    new_row = base_row + row_offset
    return get_cell(ws, new_col_letter, new_row)

def parse_student_info_old(ws):
    """Parse student basic info from sheet"""
    student = {
        "id": "",
        "name": "",
        "study_level": "",
        "cumulative_percentage": "",
    }
    for row in ws.iter_rows(min_row=1, max_row=30):
        for cell in row:
            v = clean(cell.value)
            if v.startswith("كود الطالب :"):
                student["id"] = v.replace("كود الطالب :", "").strip()
            elif v.startswith("أسم الطالب :"):
                student["name"] = v.replace("أسم الطالب :", "").strip()
            elif v.startswith("مستوى الدراسة :"):
                student["study_level"] = v.replace("مستوى الدراسة :", "").strip()
            elif v.startswith("النسبة(بحساب النقاط) :"):
                student["cumulative_percentage"] = v.replace("النسبة(بحساب النقاط) :", "").strip()
    return student

def parse_semesters_with_offset(ws):
    """Parse semesters with automatic offset"""
    
    row_offset, col_offset = detect_offset(ws)
    
    semesters = []
    current_semester = None
    current_courses = []
    
    COLS = {
        'K': 'K', 'AH': 'AH', 'BO': 'BO',
        'I': 'I', 'Y': 'Y', 'M': 'M', 'X': 'X',
        'L': 'L', 'W': 'W', 'AN': 'AN',
        'CD': 'CD', 'BC': 'BC', 'BU': 'BU',
        'AL': 'AL', 'Z': 'Z', 'AC': 'AC',
        'AS': 'AS', 'AU': 'AU', 'O': 'O', 'Q': 'Q'
    }
    
    start_row = max(1, 38 + row_offset)
    
    for row_idx in range(start_row, ws.max_row + 1):
        cell_k = get_cell_with_offset(ws, COLS['K'], row_idx, row_offset, col_offset)
        cell_ah = get_cell_with_offset(ws, COLS['AH'], row_idx, row_offset, col_offset)
        cell_bo = get_cell_with_offset(ws, COLS['BO'], row_idx, row_offset, col_offset)
        
        cell_k_clean = clean(cell_k)
        
        if 'القسم/الشعبة :' in cell_k_clean:
            if current_semester is not None:
                current_semester['courses'] = current_courses
                semesters.append(current_semester)
            
            current_semester = {
                "department": cell_k_clean.replace('القسم/الشعبة :', '').strip(),
                "level_semester": clean(cell_ah).replace('المستوى/الفصل :', '').strip(),
                "academic_year": clean(cell_bo).replace('العام الأكاديمي   :', '').strip(),
                "total_passed_hours": "",
                "gpa": "",
                "grade": "",
                "semester_hours": "",
                "semester_gpa": "",
                "level_hours": "",
                "level_gpa": "",
            }
            current_courses = []
            continue
        
        if current_semester is None:
            continue
        
        cell_i = clean(get_cell_with_offset(ws, COLS['I'], row_idx, row_offset, col_offset))
        cell_y = clean(get_cell_with_offset(ws, COLS['Y'], row_idx, row_offset, col_offset))
        cell_an = clean(get_cell_with_offset(ws, COLS['AN'], row_idx, row_offset, col_offset))
        
        if cell_i.startswith('الساعات المجتازة :') and cell_y.startswith('النقاط :'):
            current_semester['total_passed_hours'] = cell_i.replace('الساعات المجتازة :', '').strip()
            current_semester['gpa'] = cell_y.replace('النقاط :', '').strip()
            current_semester['grade'] = cell_an.replace('التقدير :', '').strip()
        
        cell_m = clean(get_cell_with_offset(ws, COLS['M'], row_idx, row_offset, col_offset))
        cell_x = clean(get_cell_with_offset(ws, COLS['X'], row_idx, row_offset, col_offset))
        
        if cell_m.startswith('الساعات المجتازة :') and cell_x.startswith('النقاط :'):
            current_semester['semester_hours'] = cell_m.replace('الساعات المجتازة :', '').strip()
            current_semester['semester_gpa'] = cell_x.replace('النقاط :', '').strip()
        
        cell_l = clean(get_cell_with_offset(ws, COLS['L'], row_idx, row_offset, col_offset))
        cell_w = clean(get_cell_with_offset(ws, COLS['W'], row_idx, row_offset, col_offset))
        
        if cell_l.startswith('الساعات المجتازة :') and cell_w.startswith('النقاط :'):
            current_semester['level_hours'] = cell_l.replace('الساعات المجتازة :', '').strip()
            current_semester['level_gpa'] = cell_w.replace('النقاط :', '').strip()
        
        cell_cd = clean(get_cell_with_offset(ws, COLS['CD'], row_idx, row_offset, col_offset))
        cell_bc = clean(get_cell_with_offset(ws, COLS['BC'], row_idx, row_offset, col_offset))
        
        if cell_cd == 'م' or cell_bc == 'المجمـــوع' or cell_bc == 'المجموع':
            continue
        
        if cell_cd.isdigit() and cell_bc:
            course = {
                "seq": cell_cd,
                "course_code": clean(get_cell_with_offset(ws, COLS['BU'], row_idx, row_offset, col_offset)),
                "course_name": cell_bc,
                "passed": clean(get_cell_with_offset(ws, COLS['I'], row_idx, row_offset, col_offset)),
                "grade_letter": clean(get_cell_with_offset(ws, COLS['O'], row_idx, row_offset, col_offset)),
                "score": clean(get_cell_with_offset(ws, COLS['Q'], row_idx, row_offset, col_offset)),
                "hours": clean(get_cell_with_offset(ws, COLS['AL'], row_idx, row_offset, col_offset)),
                "points": clean(get_cell_with_offset(ws, COLS['Z'], row_idx, row_offset, col_offset)),
                "cumulative": clean(get_cell_with_offset(ws, COLS['AC'], row_idx, row_offset, col_offset)),
                "min_score": clean(get_cell_with_offset(ws, COLS['AS'], row_idx, row_offset, col_offset)),
                "max_score": clean(get_cell_with_offset(ws, COLS['AU'], row_idx, row_offset, col_offset)),
            }
            current_courses.append(course)
    
    if current_semester is not None:
        current_semester['courses'] = current_courses
        semesters.append(current_semester)
    
    return semesters


class ExcelParser:
    """Excel parser that reads all sheets and saves directly to Supabase"""
    
    def __init__(self, file_path: Path, department_name: str = ""):
        self.file_path = file_path
        self.department_name = department_name
        self.errors = []
        self.stats = {"students": 0, "courses": 0, "semesters": 0}
        self.supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY) if SUPABASE_URL else None
    
    def get_department_id(self) -> str:
        """Get department ID from code"""
        if not self.supabase:
            return None
        result = self.supabase.table("departments").select("id").eq("code", self.department_name).execute()
        return result.data[0]["id"] if result.data else None
    
    def get_study_plan_id(self, department_id: str, enrollment_year: int) -> str:
        """Get appropriate study plan ID"""
        if not self.supabase:
            return None
        # Try exact year
        result = self.supabase.table("study_plans").select("id").eq("department_id", department_id).eq("academic_year", enrollment_year).eq("status", "active").execute()
        if result.data:
            return result.data[0]["id"]
        # Try earlier year
        result = self.supabase.table("study_plans").select("id").eq("department_id", department_id).lte("academic_year", enrollment_year).eq("status", "active").order("academic_year", desc=True).limit(1).execute()
        if result.data:
            return result.data[0]["id"]
        # Fallback to current plan
        result = self.supabase.table("study_plans").select("id").eq("department_id", department_id).eq("status", "active").eq("is_current", True).limit(1).execute()
        return result.data[0]["id"] if result.data else None
    
    def save_to_supabase(self, student_info: Dict, courses: List[Dict], department_id: str, study_plan_id: str):
        """Save student and courses to Supabase"""
        if not self.supabase:
            return None
        
        enrollment_year = datetime.now().year
        
        # Save student
        student_result = self.supabase.table("students").upsert({
            "student_code": student_info["id"],
            "name": student_info["name"],
            "department_id": department_id,
            "study_plan_id": study_plan_id,
            "enrollment_year": enrollment_year,
            "study_level": int(student_info["study_level"]) if student_info["study_level"].isdigit() else 1,
            "cumulative_percentage": float(student_info["cumulative_percentage"]) if student_info["cumulative_percentage"] else None,
            "is_active": True
        }).execute()
        
        if not student_result.data:
            return None
        
        student_id = student_result.data[0]["id"]
        self.stats["students"] += 1
        
        semesters_seen = set()
        semester_counter = 1
        
        for course in courses:
            semester_key = f"{semester_counter}"
            if semester_key not in semesters_seen:
                self.supabase.table("student_semesters").insert({
                    "student_id": student_id,
                    "semester_number": semester_counter,
                    "academic_year": str(enrollment_year),
                    "term": "fall" if semester_counter % 2 == 1 else "spring"
                }).execute()
                semesters_seen.add(semester_key)
                self.stats["semesters"] += 1
            
            semester_result = self.supabase.table("student_semesters").select("id").eq("student_id", student_id).eq("semester_number", semester_counter).execute()
            
            if semester_result.data:
                semester_id = semester_result.data[0]["id"]
                
                # Match course with study plan
                matched_course_id = None
                match_result = self.supabase.table("courses").select("id").eq("plan_id", study_plan_id).eq("code", course.get("course_code", "")).execute()
                if match_result.data:
                    matched_course_id = match_result.data[0]["id"]
                
                self.supabase.table("student_courses").insert({
                    "student_id": student_id,
                    "semester_id": semester_id,
                    "course_code": course.get("course_code", ""),
                    "course_name": course.get("course_name", ""),
                    "credit_hours": int(course.get("hours", 0)),
                    "passed": course.get("passed", "") == "نعم",
                    "grade_letter": course.get("grade_letter", ""),
                    "score": float(course.get("score", 0)) if course.get("score", "").replace('.', '').isdigit() else 0,
                    "matched_course_id": matched_course_id
                }).execute()
                self.stats["courses"] += 1
            
            semester_counter += 1
        
        # Run analysis
        try:
            self.supabase.rpc("analyze_student_progress_optimized", {
                "p_student_id": student_id,
                "p_force_refresh": False
            }).execute()
        except Exception as e:
            self.errors.append(f"Analysis failed: {str(e)}")
        
        return student_id
    
    def parse_all_students(self) -> Tuple[List[Dict], List[Dict]]:
        """Parse all sheets and save to Supabase"""
        
        if not self.supabase:
            self.errors.append("Supabase not configured. Check SUPABASE_URL and SUPABASE_KEY")
            return [], self.errors
        
        department_id = self.get_department_id()
        if not department_id:
            self.errors.append(f"Department not found: {self.department_name}")
            return [], self.errors
        
        enrollment_year = datetime.now().year
        study_plan_id = self.get_study_plan_id(department_id, enrollment_year)
        
        if not study_plan_id:
            self.errors.append(f"No study plan found for department: {self.department_name}")
            return [], self.errors
        
        students = []
        
        try:
            wb = openpyxl.load_workbook(self.file_path, data_only=True)
            
            for sheet_name in wb.sheetnames:
                try:
                    ws = wb[sheet_name]
                    
                    student_info = parse_student_info_old(ws)
                    student_info['department'] = self.department_name
                    
                    semesters = parse_semesters_with_offset(ws)
                    
                    # Save to Supabase
                    student_id = self.save_to_supabase(student_info, [], department_id, study_plan_id)
                    
                    # Flatten courses from semesters
                    all_courses = []
                    for sem in semesters:
                        all_courses.extend(sem.get("courses", []))
                    
                    self.save_to_supabase(student_info, all_courses, department_id, study_plan_id)
                    
                    if student_info.get('id'):
                        student_data = {
                            "student": student_info,
                            "semesters": semesters,
                            "sheet_name": sheet_name,
                            "parsed_at": datetime.utcnow().isoformat(),
                            "saved_to_db": True
                        }
                        students.append(student_data)
                    else:
                        self.errors.append({"sheet": sheet_name, "error": "No valid student ID found"})
                        
                except Exception as e:
                    self.errors.append({"sheet": sheet_name, "error": str(e)})
                    continue
            
            wb.close()
            
        except Exception as e:
            self.errors.append({"sheet": "all", "error": f"Failed to open workbook: {str(e)}"})
            
        return students, self.errors
    
    def get_stats(self) -> Dict:
        return self.stats