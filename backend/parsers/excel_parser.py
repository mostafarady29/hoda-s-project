# ═══════════════════════════════════════
# Parsers — Excel Parser
# ═══════════════════════════════════════
import openpyxl
from typing import Dict, List, Optional
from io import BytesIO
from core.logger import logger
from core.exceptions import ValidationError


class ExcelTranscriptParser:
    """
    Parse Excel transcript files (.xlsx).
    Extracts student info, semester records, and course records.
    """

    REQUIRED_HEADERS = {"رقم الطالب", "اسم الطالب", "كود المادة", "اسم المادة", "التقدير"}

    def parse(self, file_data: bytes) -> List[Dict]:
        """Parse Excel file and return list of student records."""
        try:
            wb = openpyxl.load_workbook(BytesIO(file_data), read_only=True)
            ws = wb.active
            if not ws:
                raise ValidationError("ملف Excel فارغ")

            # Read headers
            headers = [str(cell.value).strip() if cell.value else "" for cell in ws[1]]
            header_map = {h: i for i, h in enumerate(headers)}

            # Validate required headers
            missing = self.REQUIRED_HEADERS - set(headers)
            if missing:
                raise ValidationError(f"أعمدة مفقودة: {', '.join(missing)}")

            students = {}
            for row in ws.iter_rows(min_row=2, values_only=True):
                student_code = str(row[header_map.get("رقم الطالب", 0)] or "").strip()
                if not student_code:
                    continue

                if student_code not in students:
                    students[student_code] = {
                        "student_code": student_code,
                        "name": str(row[header_map.get("اسم الطالب", 1)] or ""),
                        "courses": [],
                    }

                students[student_code]["courses"].append({
                    "code": str(row[header_map.get("كود المادة", 2)] or ""),
                    "name": str(row[header_map.get("اسم المادة", 3)] or ""),
                    "grade": str(row[header_map.get("التقدير", 4)] or ""),
                    "credit_hours": int(row[header_map.get("الساعات", 5)] or 0) if "الساعات" in header_map else 0,
                })

            wb.close()
            logger.info(f"Parsed {len(students)} students from Excel")
            return list(students.values())

        except ValidationError:
            raise
        except Exception as e:
            logger.error(f"Excel parsing error: {e}")
            raise ValidationError(f"خطأ في قراءة ملف Excel: {str(e)}")
