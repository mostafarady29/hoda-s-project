# ═══════════════════════════════════════
# Tests — API Response Helpers
# ═══════════════════════════════════════
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.response import success_response, error_response, paginated_response


class TestResponseHelpers:
    def test_success_response(self):
        r = success_response(data={"id": "1"})
        assert r["success"] is True

    def test_error_response(self):
        r = error_response("خطأ")
        assert r["success"] is False

    def test_paginated_response(self):
        r = paginated_response([1, 2, 3], total=50, page=1, page_size=20)
        assert r["data"] == [1, 2, 3]
        assert r["meta"]["total_pages"] == 3
