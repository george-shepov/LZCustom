FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install compatible versions
RUN pip install --no-cache-dir --upgrade pip

# Install core dependencies first
RUN pip install --no-cache-dir \
    fastapi==0.104.1 \
    uvicorn[standard]==0.24.0 \
    pydantic==2.5.0 \
    aiohttp==3.9.1 \
    urllib3==2.4.0

# Copy requirements and install remaining
COPY requirements.txt .
RUN pip install --no-cache-dir --force-reinstall -r requirements.txt

# Copy source code
COPY . .

# Create database directory
RUN mkdir -p /app/database

EXPOSE 8000

# Start the application
CMD ["python", "main.py"]
