# Use a Python image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the application code to the container
COPY ./app /app

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port for the API
EXPOSE 8000

# Start the FastAPI app using Uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]