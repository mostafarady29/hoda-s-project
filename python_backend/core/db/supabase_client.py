import os
from supabase import create_client, Client
from dotenv import load_dotenv
import logging

load_dotenv()
logger = logging.getLogger("acadexa.supabase")

class SupabaseClient:
    _instance: Client = None
    
    @classmethod
    def get_client(cls) -> Client:
        if cls._instance is None:
            url = os.getenv("SUPABASE_URL")
            key = os.getenv("SUPABASE_ANON_KEY")
            
            if not url or not key:
                logger.warning("SUPABASE_URL or SUPABASE_ANON_KEY not set. DB operations will be skipped.")
                return None
            
            cls._instance = create_client(url, key)
            logger.info("Supabase client initialized")
        
        return cls._instance

# Create a singleton instance
supabase = SupabaseClient.get_client()