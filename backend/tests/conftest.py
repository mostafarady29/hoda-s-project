# ═══════════════════════════════════════
# Tests — Conftest (shared fixtures)
# ═══════════════════════════════════════
import pytest
import sys
from pathlib import Path

# Add backend to path
sys.path.insert(0, str(Path(__file__).parent.parent))


@pytest.fixture
def sample_study_plan():
    return {
        "name": "لائحة 2024 — حاسبات ومعلومات",
        "name_en": "2024 Plan — Computer Science",
        "year": 2024,
        "total_graduation_hours": 148,
        "status": "draft",
    }


@pytest.fixture
def sample_course():
    return {
        "code": "CS101",
        "name_ar": "مقدمة في علوم الحاسب",
        "name_en": "Introduction to Computer Science",
        "credit_hours": 3,
        "theory_hours": 2,
        "practical_hours": 2,
        "level": 1,
        "semester": "fall",
        "course_type": "mandatory",
    }


@pytest.fixture
def sample_student():
    return {
        "student_code": "20240001",
        "name": "أحمد محمد",
        "cumulative_gpa": 2.85,
        "total_earned_hours": 96,
        "current_level": 3,
        "passed_courses": ["CS101", "CS102", "MATH101"],
        "failed_courses": ["CS205"],
    }
