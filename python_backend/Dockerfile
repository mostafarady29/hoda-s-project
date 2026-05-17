# ===== File: python_backend/Dockerfile =====

FROM python:3.11-slim

# System deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install Python deps first (layer cache)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source
COPY . .

# Create storage dirs
RUN mkdir -p \
    storage/temp_uploads \
    storage/output \
    storage/jobs \
    logs

# Railway sets PORT, default 8000
ENV HOST=0.0.0.0
ENV PORT=8000
ENV ENVIRONMENT=production
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

EXPOSE 8000

# Health check (curl instead of python requests — lighter)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Railway uses this CMD
CMD ["python", "run.py"]