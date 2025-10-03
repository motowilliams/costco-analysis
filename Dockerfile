# Use Python 3.11 as base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy dependency files first for better caching
COPY requirements.txt ./

# Install dependencies using pip
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application
COPY . .

# Create data directories for persistence
RUN mkdir -p /app/data/receipts

# Default command (can be overridden)
CMD ["/bin/bash"]
