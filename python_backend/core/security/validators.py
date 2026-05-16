# ===== File: python_backend/core/security/validators.py =====
import re
from typing import Tuple, List, Optional
from pathlib import Path
import openpyxl

class ExcelValidator:
    """Excel file validation"""
    
    # Required columns (from old code)
    REQUIRED_COLUMNS = ['CD', 'BC', 'BU', 'AL', 'O', 'Q', 'I']
    
    @staticmethod
    def validate_file(file_path: Path) -> Tuple[bool, List[str]]:
        """
        Validate file format and structure
        Returns: (is_valid, errors_list)
        """
        errors = []
        
        # 1. Check file extension
        if file_path.suffix.lower() not in ['.xlsx', '.xls']:
            errors.append(f"Invalid file extension: {file_path.suffix}")
            return False, errors
        
        # 2. Check file size
        file_size = file_path.stat().st_size
        max_size = 50 * 1024 * 1024  # 50MB
        if file_size > max_size:
            errors.append(f"File too large: {file_size / 1024 / 1024:.2f}MB > 50MB")
            return False, errors
        
        # 3. Try to open and validate structure (sample check)
        try:
            wb = openpyxl.load_workbook(file_path, read_only=True, data_only=True)
            sheets = wb.sheetnames
            
            if not sheets:
                errors.append("No sheets found in workbook")
                return False, errors
            
            # Check first sheet for required columns (sample validation)
            first_sheet = wb[sheets[0]]
            
            # Get all column letters from first 20 rows
            found_columns = set()
            for row in range(1, min(20, first_sheet.max_row) + 1):
                for col in ExcelValidator.REQUIRED_COLUMNS:
                    try:
                        if first_sheet[f"{col}{row}"].value is not None:
                            found_columns.add(col)
                    except:
                        pass
            
            # Don't fail if columns not found in first rows, just warn
            missing_cols = set(ExcelValidator.REQUIRED_COLUMNS) - found_columns
            if missing_cols:
                errors.append(f"Warning: Some columns may be empty or missing: {missing_cols}")
            
            wb.close()
            
        except Exception as e:
            errors.append(f"Cannot read Excel file: {str(e)}")
            return False, errors
        
        return True, errors