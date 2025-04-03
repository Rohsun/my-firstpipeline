FROM python:3.9

WORKDIR /app

# Copy requirements.txt from my-python-app/ to /app/
COPY my-python-app/requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY my-python-app/ ./

# Set the command to run the application
CMD ["python", "app/main.py"]

