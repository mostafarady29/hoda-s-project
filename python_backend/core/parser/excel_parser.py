# ===== File: python_backend/core/parser/excel_parser.py =====

import openpyxl
from pathlib import Path
from typing import Dict, List, Any, Tuple
from datetime import datetime

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
        # Offset from standard location (Column K = 11, Expected Row)
        row_offset = ref_row - 40  # لأن أول شيت كان عند الصف 40
        col_offset = ref_col - 11  # لأن العمود K = 11
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
    """Same as old code"""
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
    """Version that supports automatic offset for each sheet"""
    
    # Calculate offset for this sheet
    row_offset, col_offset = detect_offset(ws)
    
    semesters = []
    current_semester = None
    current_courses = []
    
    # Standard columns (from first sheet)
    COLS = {
        'K': 'K', 'AH': 'AH', 'BO': 'BO',
        'I': 'I', 'Y': 'Y', 'M': 'M', 'X': 'X',
        'L': 'L', 'W': 'W', 'AN': 'AN',
        'CD': 'CD', 'BC': 'BC', 'BU': 'BU',
        'AL': 'AL', 'Z': 'Z', 'AC': 'AC',
        'AS': 'AS', 'AU': 'AU', 'O': 'O', 'Q': 'Q'
    }
    
    # Start search (with offset applied)
    start_row = max(1, 38 + row_offset)  # Row 38 approximately
    
    for row_idx in range(start_row, ws.max_row + 1):
        # Get cells with offset applied
        cell_k = get_cell_with_offset(ws, COLS['K'], row_idx, row_offset, col_offset)
        cell_ah = get_cell_with_offset(ws, COLS['AH'], row_idx, row_offset, col_offset)
        cell_bo = get_cell_with_offset(ws, COLS['BO'], row_idx, row_offset, col_offset)
        
        cell_k_clean = clean(cell_k)
        
        # Detect start of new semester
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
        
        # Cumulative statistics
        cell_i = clean(get_cell_with_offset(ws, COLS['I'], row_idx, row_offset, col_offset))
        cell_y = clean(get_cell_with_offset(ws, COLS['Y'], row_idx, row_offset, col_offset))
        cell_an = clean(get_cell_with_offset(ws, COLS['AN'], row_idx, row_offset, col_offset))
        
        if cell_i.startswith('الساعات المجتازة :') and cell_y.startswith('النقاط :'):
            current_semester['total_passed_hours'] = cell_i.replace('الساعات المجتازة :', '').strip()
            current_semester['gpa'] = cell_y.replace('النقاط :', '').strip()
            current_semester['grade'] = cell_an.replace('التقدير :', '').strip()
        
        # Semester statistics
        cell_m = clean(get_cell_with_offset(ws, COLS['M'], row_idx, row_offset, col_offset))
        cell_x = clean(get_cell_with_offset(ws, COLS['X'], row_idx, row_offset, col_offset))
        
        if cell_m.startswith('الساعات المجتازة :') and cell_x.startswith('النقاط :'):
            current_semester['semester_hours'] = cell_m.replace('الساعات المجتازة :', '').strip()
            current_semester['semester_gpa'] = cell_x.replace('النقاط :', '').strip()
        
        # Level statistics
        cell_l = clean(get_cell_with_offset(ws, COLS['L'], row_idx, row_offset, col_offset))
        cell_w = clean(get_cell_with_offset(ws, COLS['W'], row_idx, row_offset, col_offset))
        
        if cell_l.startswith('الساعات المجتازة :') and cell_w.startswith('النقاط :'):
            current_semester['level_hours'] = cell_l.replace('الساعات المجتازة :', '').strip()
            current_semester['level_gpa'] = cell_w.replace('النقاط :', '').strip()
        
        # Course data
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
    
    # Save last semester
    if current_semester is not None:
        current_semester['courses'] = current_courses
        semesters.append(current_semester)
    
    return semesters


class ExcelParser:
    """Excel parser that reads all sheets with automatic offset support"""
    
    def __init__(self, file_path: Path, department_name: str = ""):
        self.file_path = file_path
        self.department_name = department_name
        self.errors = []
        
    def parse_all_students(self) -> Tuple[List[Dict], List[Dict]]:
        students = []
        errors = []
        
        try:
            wb = openpyxl.load_workbook(self.file_path, data_only=True)
            
            for sheet_name in wb.sheetnames:
                try:
                    ws = wb[sheet_name]
                    
                    student_info = parse_student_info_old(ws)
                    student_info['department'] = self.department_name
                    
                    # Use the parser with automatic offset
                    semesters = parse_semesters_with_offset(ws)
                    
                    student_data = {
                        "student": student_info,
                        "semesters": semesters,
                        "sheet_name": sheet_name,
                        "parsed_at": datetime.utcnow().isoformat()
                    }
                    
                    if student_data.get('student', {}).get('id'):
                        students.append(student_data)
                    else:
                        errors.append({
                            "sheet": sheet_name,
                            "error": "No valid student ID found"
                        })
                        
                except Exception as e:
                    error_msg = str(e)
                    errors.append({
                        "sheet": sheet_name,
                        "error": error_msg
                    })
                    continue
            
            wb.close()
            
        except Exception as e:
            errors.append({
                "sheet": "all",
                "error": f"Failed to open workbook: {str(e)}"
            })
            
        return students, errors