# ═══════════════════════════════════════
# Tests — Parsers
# ═══════════════════════════════════════
import pytest
import json
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from parsers.json_parser import CurriculumJsonParser


class TestCurriculumJsonParser:
    def test_valid_json(self):
        data = {
            "name": "لائحة 2024",
            "year": 2024,
            "courses": [
                {"code": "CS101", "name_ar": "مقدمة حاسب"},
                {"code": "CS102", "name_ar": "برمجة"},
            ],
        }
        parser = CurriculumJsonParser()
        result = parser.parse(json.dumps(data).encode("utf-8"))
        assert result["name"] == "لائحة 2024"
        assert len(result["courses"]) == 2

    def test_missing_required_fields(self):
        data = {"name": "test"}
        parser = CurriculumJsonParser()
        with pytest.raises(Exception):
            parser.parse(json.dumps(data).encode("utf-8"))

    def test_invalid_json(self):
        parser = CurriculumJsonParser()
        with pytest.raises(Exception):
            parser.parse(b"not json")

    def test_course_without_code(self):
        data = {"name": "test", "year": 2024, "courses": [{"name_ar": "بدون كود"}]}
        parser = CurriculumJsonParser()
        with pytest.raises(Exception):
            parser.parse(json.dumps(data).encode("utf-8"))
