# ═══════════════════════════════════════
# Services — Department Service
# ═══════════════════════════════════════
from typing import Dict, List
from core.exceptions import EntityNotFoundError
from repositories.department_repository import DepartmentRepository
from repositories.program_repository import ProgramRepository


class DepartmentService:
    def __init__(self, repo: DepartmentRepository, program_repo: ProgramRepository):
        self.repo = repo
        self.program_repo = program_repo

    async def list_departments(self, plan_id: str) -> List[Dict]:
        return await self.repo.find_by_plan(plan_id)

    async def get_department(self, dept_id: str) -> Dict:
        dept = await self.repo.find_by_id(dept_id)
        if not dept:
            raise EntityNotFoundError("القسم", dept_id)
        return dept

    async def create_department(self, data: Dict) -> Dict:
        return await self.repo.create(data)

    async def update_department(self, dept_id: str, data: Dict) -> Dict:
        await self.get_department(dept_id)
        return await self.repo.update(dept_id, data)

    async def delete_department(self, dept_id: str) -> bool:
        await self.get_department(dept_id)
        return await self.repo.delete(dept_id)

    async def list_programs(self, plan_id: str) -> List[Dict]:
        return await self.repo.find_programs(plan_id)
