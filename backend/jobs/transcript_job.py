# ═══════════════════════════════════════
# Jobs — Transcript Import Job
# ═══════════════════════════════════════
"""
Background job that processes uploaded transcript files.
Replaces the old in-memory threading approach with a persistent,
restartable job.
"""
import asyncio
from typing import Dict
from core.logger import logger


async def process_transcript_job(job_id: str, file_data: bytes, filename: str, supabase_client):
    """
    Process a transcript file in the background.
    Updates job status in the import_jobs table.
    """
    from repositories.import_job_repository import ImportJobRepository
    from repositories.student_repository import StudentRepository
    from repositories.transcript_repository import TranscriptRepository
    from parsers.excel_parser import ExcelTranscriptParser

    job_repo = ImportJobRepository(supabase_client)
    student_repo = StudentRepository(supabase_client)
    transcript_repo = TranscriptRepository(supabase_client)

    try:
        await job_repo.update_progress(job_id, 0, "processing")

        # Determine parser based on extension
        if filename.lower().endswith(".xlsx") or filename.lower().endswith(".xls"):
            parser = ExcelTranscriptParser()
        else:
            await job_repo.mark_failed(job_id, "صيغة الملف غير مدعومة")
            return

        # Parse file
        students = parser.parse(file_data)
        total = len(students)
        logger.info(f"Job {job_id}: Found {total} students to process")

        for i, student_data in enumerate(students):
            try:
                # Upsert student
                await student_repo.upsert_by_code(student_data["student_code"], {
                    "name": student_data.get("name", ""),
                    "job_id": job_id,
                })

                # Update progress
                progress = int(((i + 1) / total) * 100)
                await job_repo.update_progress(job_id, progress, "processing")

            except Exception as e:
                logger.warning(f"Job {job_id}: Error processing student {student_data.get('student_code')}: {e}")

        await job_repo.mark_completed(job_id, {"total_students": total})
        logger.info(f"Job {job_id}: Completed — {total} students processed")

    except Exception as e:
        logger.error(f"Job {job_id}: Failed — {e}")
        await job_repo.mark_failed(job_id, str(e))
