# Use a base image that includes Python and Streamlit's dependencies
FROM python:3.9-slim-buster

# Install system dependencies (like unzip)
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create a dedicated, universally accessible directory for NLTK data
# This is crucial for ensuring permissions and visibility
RUN mkdir -p /usr/share/nltk_data && chmod -R 777 /usr/share/nltk_data

# Set environment variables for NLTK data path
# This tells NLTK where to download and look for its data
ENV NLTK_DATA /usr/share/nltk_data

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download NLTK data during the Docker build process
# We'll explicitly list each package and download to the defined NLTK_DATA path
# This ensures NLTK data is present before the app starts
RUN python -c "import nltk; \
    nltk.data.path.append('/usr/share/nltk_data'); \
    print('Downloading NLTK punkt'); \
    nltk.download('punkt', download_dir='/usr/share/nltk_data', quiet=True); \
    print('Downloading NLTK stopwords'); \
    nltk.download('stopwords', download_dir='/usr/share/nltk_data', quiet=True); \
    print('Downloading NLTK wordnet'); \
    nltk.download('wordnet', download_dir='/usr/share/nltk_data', quiet=True); \
    print('Downloading NLTK punkt_tab'); \
    nltk.download('punkt_tab', download_dir='/usr/share/nltk_data', quiet=True);"

# Copy the rest of your application files
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# Command to run the Streamlit application
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.enableCORS=false", "--server.enableXsrfProtection=false"]
