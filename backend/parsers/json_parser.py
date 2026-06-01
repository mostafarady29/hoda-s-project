# ═══════════════════════════════════════
# Parsers — Curriculum JSON Parser
# ═══════════════════════════════════════
import json
from typing import Dict
from core.logger import logger
from core.exceptions import ValidationError


class CurriculumJsonParser:
    """Parse JSON curriculum files for import."""

    REQUIRED_KEYS = {"name", "year", "courses"}

    def parse(self, file_data: bytes) -> Dict:
        try:
            data = json.loads(file_data.decode("utf-8"))
        except json.JSONDecodeError as e:
            raise ValidationError(f"ملف JSON غير صالح: {str(e)}")

        missing = self.REQUIRED_KEYS - set(data.keys())
        if missing:
            raise ValidationError(f"حقول مفقودة في JSON: {', '.join(missing)}")

        # Validate courses
        courses = data.get("courses", [])
        for i, course in enumerate(courses):
            if not course.get("code"):
                raise ValidationError(f"المادة رقم {i+1} بدون كود")
            if not course.get("name_ar"):
                raise ValidationError(f"المادة {course['code']} بدون اسم عربي")

        logger.info(f"Parsed curriculum JSON: {data.get('name')} with {len(courses)} courses")
        return data
