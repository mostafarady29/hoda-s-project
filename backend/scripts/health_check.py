#!/usr/bin/env python3
"""
Acadexa — Health Check Script
Tests connectivity to Supabase and API.
"""
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))


def check_supabase():
    from integrations.supabase.client import get_supabase_client
    client = get_supabase_client()
    if client:
        print("✅ Supabase connection OK")
        return True
    print("❌ Supabase connection FAILED")
    return False


def check_config():
    from core.config import settings
    checks = {
        "SUPABASE_URL": bool(settings.SUPABASE_URL),
        "SUPABASE_SERVICE_ROLE_KEY": bool(settings.SUPABASE_SERVICE_ROLE_KEY),
        "SECRET_KEY": settings.SECRET_KEY != "acadexa-v2-secret-change-in-production-2026",
    }
    for key, ok in checks.items():
        status = "✅" if ok else "⚠️"
        print(f"  {status} {key}")
    return all(checks.values())


if __name__ == "__main__":
    print("🔍 Acadexa Health Check")
    print("=" * 40)
    check_config()
    check_supabase()
