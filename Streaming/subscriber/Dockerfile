FROM python:3.9

# Install dependencies
RUN apt-get update \
    && apt-get install -y openjdk-17-jdk build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy dependencies and install
COPY app/requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY app/ .

# Default command to run the application
CMD ["python", "app.py"]
