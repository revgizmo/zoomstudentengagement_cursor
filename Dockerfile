# Use the official R base image
FROM rocker/r-ver:4.4.0

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update package list and install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # Core development tools
    git \
    curl \
    wget \
    pkg-config \
    build-essential \
    # Compression libraries
    libbz2-dev \
    liblzma-dev \
    libz-dev \
    # SSL and networking
    libssl-dev \
    libcurl4-openssl-dev \
    # XML and data formats
    libxml2-dev \
    # Font and text rendering
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    # Image formats
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    # Spatial data
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    # Git integration
    libgit2-dev \
    # Additional common dependencies
    libcairo2-dev \
    libpango1.0-dev \
    libxt-dev \
    libreadline-dev \
    libblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages for development
RUN R -q -e "install.packages(c('rcmdcheck','covr','lintr','roxygen2','testthat','withr','hms','tibble','readr','languageserver','styler','usethis','devtools','remotes','knitr','rmarkdown','digest','jsonlite','lubridate','magrittr','purrr','rlang','stringr','tidyr','tidyselect','ggplot2','data.table','dplyr'), repos='https://cloud.r-project.org')"

# Set working directory
WORKDIR /workspace

# Default command
CMD ["R"]
