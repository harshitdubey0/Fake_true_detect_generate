# Use a base image that includes Python and Streamlit's dependencies
FROM python:3.9-slim-buster

# Set environment variables for NLTK data path
ENV NLTK_DATA /usr/local/nltk_data

# Install system dependencies (like unzip)
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download NLTK data during the build process
RUN python -c "import nltk; nltk.download('punkt', download_dir='/usr/local/nltk_data'); nltk.download('stopwords', download_dir='/usr/local/nltk_data'); nltk.download('wordnet', download_dir='/usr/local/nltk_data'); nltk.download('punkt_tab', download_dir='/usr/local/nltk_data')"

# Copy the rest of your application files
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# Command to run the Streamlit application
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.enableCORS=false", "--server.enableXsrfProtection=false"]
