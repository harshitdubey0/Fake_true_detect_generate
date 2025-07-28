# Use a base image that includes Python and Streamlit's dependencies
FROM python:3.9-slim-buster

# Set environment variables for NLTK data path
# This tells NLTK where to download and look for its data
ENV NLTK_DATA /usr/local/share/nltk_data

# Install system dependencies (like unzip)
# apt-get update ensures package lists are current
# unzip is needed for NLTK's compressed data
# rm -rf /var/lib/apt/lists/* cleans up after apt-get
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create the NLTK data directory and set permissions
# This ensures the directory exists and is writable
RUN mkdir -p ${NLTK_DATA} && chmod -R 777 ${NLTK_DATA}

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install Python dependencies
# --no-cache-dir reduces image size
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Download NLTK data during the Docker build process
# We'll use a separate nltk.txt file to list packages
# This command runs Python to execute NLTK downloads
# It explicitly tells NLTK to download to the NLTK_DATA directory
COPY nltk.txt .
RUN python -c "import nltk; \
    nltk.data.path.append('/usr/local/share/nltk_data'); \
    with open('nltk.txt') as f: \
        packages = [line.strip() for line in f if line.strip()]; \
    for package in packages: \
        print(f'Downloading NLTK package: {package}'); \
        nltk.download(package, download_dir='/usr/local/share/nltk_data', quiet=True); \
        print(f'Finished downloading {package}');"

# Copy the rest of your application files
# The '.' means copy everything from the current local directory into the /app directory in the container
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# Command to run the Streamlit application
# --server.port=8501: Specifies the port Streamlit should listen on
# --server.enableCORS=false: Disables Cross-Origin Resource Sharing protection (common for demos)
# --server.enableXsrfProtection=false: Disables Cross-Site Request Forgery protection (common for demos)
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.enableCORS=false", "--server.enableXsrfProtection=false"]
