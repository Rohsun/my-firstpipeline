# Use the latest Python image
FROM python:3.9  

# Set the working directory inside the container
WORKDIR /app  

# Copy all files from the current directory to /app in the container
COPY . .  

# Install dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt  

# Expose the port your app runs on
EXPOSE 8080  

# Command to run the application
CMD ["python3", "app.py"]
