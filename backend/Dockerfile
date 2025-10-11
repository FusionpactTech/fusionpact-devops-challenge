# Dockerfile.backend
# Use the official Python image as the base image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file and install dependencies first (for better caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code 
# # Assuming app directory contains services.py and schema.py for 'from app import ...'
COPY app/* ./
COPY app ./app 

# Expose the port on which the application will run
EXPOSE 8000

# Define the command to run the application using uvicorn
# The command uses 'main:app' referring to the 'app' object in 'main.py'
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]