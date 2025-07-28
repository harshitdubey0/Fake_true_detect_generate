# Use a base image that includes Python and Streamlit's dependencies
FROM python:3.9-slim-buster

# Install system dependencies (like wget for downloading, and unzip)
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# --- NEW: Create a dedicated NLTK data directory within the appuser's home ---
# This aligns with the path NLTK is actually searching in the error message.
# We'll use /home/appuser/nltk_data as the target.
RUN mkdir -p /home/appuser/nltk_data && chmod -R 777 /home/appuser/nltk_data

# Set environment variables for NLTK data path to this specific location
ENV NLTK_DATA /home/appuser/nltk_data

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- NEW: Manually download and extract NLTK data to the appuser's NLTK_DATA path ---
# This downloads the 'all-nltk' collection which contains punkt, stopwords, wordnet, etc.
# It's a large download, but ensures all necessary data is present.
# We download it to a temporary location and then extract it to NLTK_DATA.
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
