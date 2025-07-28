# Use a standard Python base image
FROM python:3.9-slim-buster

# Set environment variables for NLTK data path
ENV NLTK_DATA /usr/local/nltk_data

# Install system dependencies (like wget for downloading, and unzip)
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create the NLTK data directory and set permissions
RUN mkdir -p ${NLTK_DATA} && chmod -R 777 ${NLTK_DATA}

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install Python dependencies
# This will install Streamlit, requests, and other Python libraries
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- NEW: Explicitly install NLTK data using wget and unzip ---
# This ensures NLTK data is physically present in the expected location.
RUN wget -O /tmp/nltk_data.zip https://github.com/nltk/nltk_data/archive/refs/heads/main.zip \
    && unzip /tmp/nltk_data.zip -d /tmp/ \
    && mv /tmp/nltk_data-main/packages/* ${NLTK_DATA}/ \
    && rm -rf /tmp/nltk_data.zip /tmp/nltk_data-main

# Copy the rest of your application files
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# Command to run the Streamlit application
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.enableCORS=false", "--server.enableXsrfProtection=false"]
