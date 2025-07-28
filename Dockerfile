# Use a base image that includes Python and Streamlit's dependencies
FROM python:3.9-slim-buster

# Install system dependencies (like wget for downloading, and unzip)
RUN apt-get update && apt-get install -y \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create a dedicated, universally accessible directory for NLTK data
RUN mkdir -p /usr/share/nltk_data && chmod -R 777 /usr/share/nltk_data

# Set environment variables for NLTK data path
ENV NLTK_DATA /usr/share/nltk_data

# --- NEW: Manually download and extract NLTK data ---
# This downloads the 'all-nltk' collection which contains punkt, stopwords, wordnet, etc.
# It's a large download, but ensures all necessary data is present.
# We download it to a temporary location and then extract it to NLTK_DATA.
RUN wget -O /tmp/nltk_data.zip https://github.com/nltk/nltk_data/archive/refs/heads/main.zip \
    && unzip /tmp/nltk_data.zip -d /tmp/ \
    && mv /tmp/nltk_data-main/packages/* /usr/share/nltk_data/ \
    && rm -rf /tmp/nltk_data.zip /tmp/nltk_data-main

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of your application files
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# Command to run the Streamlit application
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.enableCORS=false", "--server.enableXsrfProtection=false"]
