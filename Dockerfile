# Dockerfile for zoomstudentengagement R package
# Optimized for development environment

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

# Install ALL R packages including transitive dependencies (136 total packages)
RUN R -q -e "install.packages(c('askpass', 'backports', 'base64enc', 'bit', 'bit64', 'brew', 'brio', 'bslib', 'cachem', 'callr', 'cli', 'clipr', 'codetools', 'collections', 'commonmark', 'covr', 'cpp11', 'crayon', 'credentials', 'curl', 'data.table', 'desc', 'devtools', 'diffobj', 'digest', 'downlit', 'dplyr', 'ellipsis', 'evaluate', 'fansi', 'farver', 'fastmap', 'fontawesome', 'fs', 'generics', 'gert', 'ggplot2', 'gh', 'gitcreds', 'glue', 'gtable', 'highr', 'hms', 'htmltools', 'htmlwidgets', 'httpuv', 'httr', 'httr2', 'ini', 'isoband', 'jquerylib', 'jsonlite', 'knitr', 'labeling', 'languageserver', 'later', 'lattice', 'lazyeval', 'lifecycle', 'lintr', 'lubridate', 'magrittr', 'MASS', 'Matrix', 'memoise', 'mgcv', 'mime', 'miniUI', 'nlme', 'openssl', 'pillar', 'pkgbuild', 'pkgconfig', 'pkgdown', 'pkgload', 'praise', 'prettyunits', 'processx', 'profvis', 'progress', 'promises', 'ps', 'purrr', 'R.cache', 'R.methodsS3', 'R.oo', 'R.utils', 'R6', 'ragg', 'rappdirs', 'rcmdcheck', 'RColorBrewer', 'Rcpp', 'readr', 'remotes', 'rex', 'rlang', 'rmarkdown', 'roxygen2', 'rprojroot', 'rstudioapi', 'rversions', 'sass', 'scales', 'sessioninfo', 'shiny', 'sourcetools', 'stringi', 'stringr', 'styler', 'sys', 'systemfonts', 'testthat', 'textshaping', 'tibble', 'tidyr', 'tidyselect', 'timechange', 'tinytex', 'tzdb', 'urlchecker', 'usethis', 'utf8', 'vctrs', 'viridisLite', 'vroom', 'waldo', 'whisker', 'withr', 'xfun', 'xml2', 'xmlparsedata', 'xopen', 'xtable', 'yaml', 'zip'), repos='https://cloud.r-project.org')"

# Set working directory
WORKDIR /workspace

# Copy package files
COPY . /workspace/

# Install the package in development mode
RUN R -q -e "devtools::install_deps(dependencies = TRUE)"

# Install the package
RUN R CMD INSTALL .

# Verify installation
RUN R -e "library(zoomstudentengagement); cat('Package installed successfully\n')"

# Default command
CMD ["R"]
