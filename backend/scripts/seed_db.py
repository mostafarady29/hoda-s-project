#!/usr/bin/env python3
"""
Acadexa — Seed Database Script
Populates initial data for development.
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from integrations.supabase.client import get_supabase_client


def seed_default_grade_scale(client):
    """Insert the standard Egyptian university grade scale."""
    grades = [
        {"grade_ar": "ممتاز",     "grade_letter": "A+", "points": 4.0, "min_score": 97, "max_score": 100, "order": 1},
        {"grade_ar": "ممتاز",     "grade_letter": "A",  "points": 4.0, "min_score": 93, "max_score": 96,  "order": 2},
        {"grade_ar": "ممتاز",     "grade_letter": "A-", "points": 3.7, "min_score": 89, "max_score": 92,  "order": 3},
        {"grade_ar": "جيد جداً",  "grade_letter": "B+", "points": 3.3, "min_score": 84, "max_score": 88,  "order": 4},
        {"grade_ar": "جيد جداً",  "grade_letter": "B",  "points": 3.0, "min_score": 80, "max_score": 83,  "order": 5},
        {"grade_ar": "جيد جداً",  "grade_letter": "B-", "points": 2.7, "min_score": 76, "max_score": 79,  "order": 6},
        {"grade_ar": "جيد",       "grade_letter": "C+", "points": 2.3, "min_score": 73, "max_score": 75,  "order": 7},
        {"grade_ar": "جيد",       "grade_letter": "C",  "points": 2.0, "min_score": 70, "max_score": 72,  "order": 8},
        {"grade_ar": "جيد",       "grade_letter": "C-", "points": 1.7, "min_score": 67, "max_score": 69,  "order": 9},
        {"grade_ar": "مقبول",     "grade_letter": "D+", "points": 1.3, "min_score": 64, "max_score": 66,  "order": 10},
        {"grade_ar": "مقبول",     "grade_letter": "D",  "points": 1.0, "min_score": 60, "max_score": 63,  "order": 11},
        {"grade_ar": "مقبول",     "grade_letter": "D-", "points": 0.7, "min_score": 57, "max_score": 59,  "order": 12},
        {"grade_ar": "ضعيف",     "grade_letter": "F",  "points": 0.0, "min_score": 0,  "max_score": 56,  "order": 13},
    ]
    print(f"📊 Seeding {len(grades)} grade levels...")
    return grades


def seed_sample_plan():
    """Create a sample study plan for testing."""
    return {
        "name": "لائحة 2024 — كلية الحاسبات والمعلومات",
        "name_en": "2024 Plan — Faculty of Computers and Information",
        "year": 2024,
        "total_graduation_hours": 148,
        "status": "draft",
        "description": "لائحة تجريبية للتطوير",
    }


if __name__ == "__main__":
    print("🌱 Acadexa Database Seeder")
    print("=" * 40)
    client = get_supabase_client()
    if not client:
        print("❌ Cannot connect to Supabase")
        sys.exit(1)

    plan = seed_sample_plan()
    grades = seed_default_grade_scale(client)
    print(f"✅ Sample plan: {plan['name']}")
    print(f"✅ Grade scale: {len(grades)} levels")
    print("🌱 Seed data prepared (insert manually or via API)")
