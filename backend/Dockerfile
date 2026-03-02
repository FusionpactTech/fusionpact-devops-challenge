# Backend Dockerfile
FROM python:3.11-slim

WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Run the application (adjusted for app/ subdirectory)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]