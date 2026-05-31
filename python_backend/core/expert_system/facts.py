# backend/app/core/expert_system/facts.py

from dataclasses import dataclass
from typing import Any, Optional
from datetime import datetime

@dataclass
class Fact:
    """حقيقة واحدة عن الطالب"""
    fact_type: str  # 'course_taken', 'gpa', 'total_credits', 'semester_hours'
    value: Any      # القيمة (مثلاً: كود المادة أو الرقم)
    semester: Optional[str] = None  # الترم اللي أخذ فيه المادة (لو ينطبق)
    timestamp: Optional[datetime] = None
    
    def __repr__(self):
        return f"Fact({self.fact_type}={self.value})"


class FactManager:
    """يدير كل الحقائق للطالب"""
    
    def __init__(self):
        self.facts: List[Fact] = []
    
    def add_fact(self, fact: Fact):
        self.facts.append(fact)
    
    def add_course_taken(self, course_code: str, semester: str, grade: str, passed: bool):
        """إضافة حقيقة أن الطالب أخذ مادة معينة"""
        self.add_fact(Fact('course_taken', course_code, semester))
        if passed:
            self.add_fact(Fact('course_passed', course_code, semester))
        self.add_fact(Fact(f'grade_{course_code}', grade, semester))
    
    def add_gpa(self, gpa: float, semester: Optional[str] = None):
        self.add_fact(Fact('gpa', gpa, semester))
    
    def add_total_credits(self, credits: int):
        self.add_fact(Fact('total_credits', credits))
    
    def add_semester_hours(self, hours: int, semester: str):
        self.add_fact(Fact('semester_hours', hours, semester))
    
    def get_facts_by_type(self, fact_type: str) -> List[Fact]:
        return [f for f in self.facts if f.fact_type == fact_type]
    
    def has_taken_course(self, course_code: str) -> bool:
        return any(f.value == course_code for f in self.facts if f.fact_type == 'course_taken')
    
    def has_passed_course(self, course_code: str) -> bool:
        return any(f.value == course_code for f in self.facts if f.fact_type == 'course_passed')
    
    def get_course_semester(self, course_code: str) -> Optional[str]:
        for f in self.facts:
            if f.fact_type == 'course_taken' and f.value == course_code:
                return f.semester
        return None