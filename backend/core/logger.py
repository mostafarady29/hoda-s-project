# ═══════════════════════════════════════
# Core — Logger
# ═══════════════════════════════════════
import logging
import sys
from pythonjsonlogger import jsonlogger

from core.config import settings


def setup_logger(name: str = "acadexa") -> logging.Logger:
    """Configure structured JSON logging."""
    logger = logging.getLogger(name)
    logger.setLevel(getattr(logging, settings.LOG_LEVEL))

    if not logger.handlers:
        handler = logging.StreamHandler(sys.stdout)

        if settings.ENVIRONMENT == "production":
            formatter = jsonlogger.JsonFormatter(
                "%(asctime)s %(name)s %(levelname)s %(message)s",
                rename_fields={"asctime": "timestamp", "levelname": "level"},
            )
        else:
            formatter = logging.Formatter(
                "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
                datefmt="%Y-%m-%d %H:%M:%S",
            )

        handler.setFormatter(formatter)
        logger.addHandler(handler)

    return logger


logger = setup_logger()
