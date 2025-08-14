# Use the official R base image
FROM rocker/r-ver:4.4.0

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages for development
RUN R -q -e "install.packages(c('rcmdcheck','covr','lintr','roxygen2','testthat','withr','hms','tibble','readr','languageserver'), repos='https://cloud.r-project.org')"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["R"]
