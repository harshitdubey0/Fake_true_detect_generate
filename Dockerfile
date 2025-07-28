# Use a base image from a source known to include NLTK data or be more compatible
# 'continuumio/miniconda3' is often used for data science and can be more stable
# It usually comes with a robust conda environment.
FROM continuumio/miniconda3:latest

# Install system dependencies (like unzip)
# miniconda images often use apt-get on Debian-based systems
RUN apt-get update && apt-get install -y \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set the NLTK_DATA environment variable to a common location within the conda environment
ENV NLTK_DATA /opt/conda/nltk_data

# Create the NLTK data directory and set permissions
# This ensures the directory exists and is writable
RUN mkdir -p ${NLTK_DATA} && chmod -R 777 ${NLTK_DATA}

# Set the working directory in the container
WORKDIR /app

# Copy requirements.txt and install Python dependencies
# Use conda to install core data science packages (often more stable with miniconda)
# Then use pip for any remaining packages
COPY requirements.txt .
RUN conda install --yes python=3.9 && \
    conda install --yes -c conda-forge pandas numpy scikit-learn transformers pytorch cpuonly && \
    pip install --no-cache-dir -r requirements.txt

# --- NEW: Download NLTK data using conda (often more reliable in conda environments) ---
# This uses conda-forge, which often provides NLTK data packages.
# We then copy the downloaded data to the NLTK_DATA path.
RUN conda install --yes -c conda-forge nltk-data && \
    cp -r /opt/conda/share/nltk_data/* ${NLTK_DATA}/

# Copy the rest of your application files
COPY . .

# Expose the port Streamlit runs on
EXPOSE 8501

# Command to run the Streamlit application
ENTRYPOINT ["streamlit", "run", "app.py", "--server.port=8501", "--server.enableCORS=false", "--server.enableXsrfProtection=false"]
