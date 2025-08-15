# Docker Setup for zoomstudentengagement

This document provides comprehensive instructions for setting up and using Docker containers with the `zoomstudentengagement` R package.

## ⚠️ CRITICAL: Transitive Dependencies

**IMPORTANT DISCOVERY**: Your package requires **136 total packages**, not just the 27 direct dependencies!

- **27 Direct dependencies** (from DESCRIPTION and code analysis)
- **109 Transitive dependencies** (dependencies of dependencies)
- **Total: 136 packages** (403.7% increase!)

This explains why you had installation failures in Docker - missing transitive dependencies were causing package installation to fail.

## Overview

The `zoomstudentengagement` package requires 136 R packages across four categories:
- **15 Core packages** (required for functionality)
- **5 Development packages** (testing/documentation)
- **7 Development tools** (code quality/build)
- **109 Transitive dependencies** (dependencies of dependencies)

All packages are available on CRAN and can be easily installed in a Docker container.

## Quick Start

### 1. Automated Setup (Recommended)

Use the provided setup script to automatically build and verify the Docker container:

```bash
./scripts/setup-docker-container.sh
```

This script will:
- Check for Docker installation
- Build the Docker image with all dependencies
- Verify that all packages are installed correctly
- Provide usage examples

### 2. Complete Setup (Guaranteed Success)

For guaranteed successful installation, use the complete Dockerfile:

```bash
# Build the complete image with all 136 packages
docker build -f Dockerfile.complete -t zoomstudentengagement:complete .

# Verify the complete setup
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript scripts/verify-complete-dependencies.R
```

## Package Dependencies

### Core Packages (Required for functionality)
- `data.table` - Fast data manipulation
- `digest` - Hash functions
- `dplyr` - Data manipulation
- `ggplot2` - Data visualization
- `hms` - Time handling
- `jsonlite` - JSON processing
- `lubridate` - Date/time manipulation
- `magrittr` - Pipe operator
- `purrr` - Functional programming
- `readr` - Data import
- `rlang` - R language utilities
- `stringr` - String manipulation
- `tibble` - Modern data frames
- `tidyr` - Data tidying
- `tidyselect` - Variable selection

### Development Packages (Testing/Documentation)
- `testthat` - Unit testing framework
- `withr` - Test fixtures
- `covr` - Code coverage
- `knitr` - Dynamic report generation
- `rmarkdown` - R Markdown documents

### Development Tools (Code Quality/Build)
- `devtools` - Package development tools
- `lintr` - Code linting
- `styler` - Code formatting
- `usethis` - Package setup utilities
- `remotes` - Package installation
- `rcmdcheck` - R CMD check wrapper
- `languageserver` - Language server for IDEs

### Transitive Dependencies (109 packages)
Key transitive dependencies include:
- `cli`, `glue`, `rlang` - Core tidyverse infrastructure
- `vctrs`, `pillar`, `lifecycle` - Data structure support
- `Rcpp`, `cpp11` - C++ integration
- `httr`, `curl`, `openssl` - Network and security
- `xml2`, `yaml`, `jsonlite` - Data formats
- `systemfonts`, `ragg`, `textshaping` - Graphics and fonts
- And 100+ more...

## Usage Examples

### Interactive R Session
```bash
docker run -it --rm -v "$(pwd):/workspace" zoomstudentengagement:complete
```

### Run Tests
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'devtools::test()'
```

### Run Package Check
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'devtools::check()'
```

### Run Pre-PR Validation
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript scripts/pre-pr-validation.R
```

### Verify Complete Dependencies
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript scripts/verify-complete-dependencies.R
```

### Build Documentation
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'devtools::document()'
```

### Build Vignettes
```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'devtools::build_vignettes()'
```

## Available Scripts

### `scripts/analyze-all-dependencies.R`
Comprehensive dependency analysis that finds ALL transitive dependencies.

**Usage:**
```bash
Rscript scripts/analyze-all-dependencies.R
```

**Output:**
- Complete list of all 136 packages
- Dependency tree analysis
- Installation commands for different scenarios
- Docker integration commands
- Package verification code

### `scripts/verify-complete-dependencies.R`
Verifies that all 136 packages (including transitive dependencies) are installed.

**Usage:**
```bash
Rscript scripts/verify-complete-dependencies.R
```

**Output:**
- Detailed status of each package by category
- Version information
- Missing package reports
- Critical missing packages identification
- Installation recommendations

### `scripts/docker-package-install.R`
Lists direct dependencies and provides installation commands.

**Usage:**
```bash
Rscript scripts/docker-package-install.R
```

### `scripts/verify-package-dependencies.R`
Verifies direct dependencies only.

**Usage:**
```bash
Rscript scripts/verify-package-dependencies.R
```

### `scripts/setup-docker-container.sh`
Automated Docker container setup and verification.

**Usage:**
```bash
./scripts/setup-docker-container.sh
```

## Docker Images

### `Dockerfile.complete` (Recommended)
Complete Dockerfile with all 136 packages:
- Organized package installation by category
- All transitive dependencies included
- Guaranteed successful installation
- Development environment setup

### `Dockerfile.updated`
Enhanced Dockerfile with direct dependencies only:
- Organized package installation by category
- Direct dependencies only (27 packages)
- May miss some transitive dependencies

### `Dockerfile` (Original)
Original Dockerfile with basic setup.

## Package Management

### Installing Missing Packages
If you need to install additional packages in the container:

```bash
# Interactive installation
docker run -it --rm -v "$(pwd):/workspace" zoomstudentengagement:complete R

# Then in R:
install.packages("package_name")
```

### Using DESCRIPTION Dependencies
The container automatically installs dependencies from the DESCRIPTION file:

```bash
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'remotes::install_deps(dependencies = TRUE)'
```

### Automatic Dependency Resolution
For automatic resolution of all dependencies:

```bash
# This will install all dependencies including transitive ones
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'remotes::install_deps(dependencies = TRUE)'
```

## Troubleshooting

### Common Issues

1. **Docker not found**
   ```bash
   # Install Docker from https://docs.docker.com/get-docker/
   ```

2. **Permission denied on scripts**
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Package installation failures**
   ```bash
   # Check available packages
   Rscript scripts/verify-complete-dependencies.R
   
   # Install missing packages manually
   docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'install.packages("missing_package")'
   ```

4. **Memory issues with large datasets**
   ```bash
   # Increase Docker memory limit
   docker run --memory=4g --rm -v "$(pwd):/workspace" zoomstudentengagement:complete
   ```

5. **Transitive dependency issues**
   ```bash
   # Use the complete Dockerfile
   docker build -f Dockerfile.complete -t zoomstudentengagement:complete .
   
   # Or use automatic dependency resolution
   docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'remotes::install_deps(dependencies = TRUE)'
   ```

### Verification Commands

```bash
# Check if all 136 packages are installed
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript scripts/verify-complete-dependencies.R

# Check package functionality
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'library(zoomstudentengagement); cat("Package loaded successfully\n")'

# Run a quick test
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'devtools::test()'
```

## Development Workflow

### 1. Local Development
```bash
# Start interactive session
docker run -it --rm -v "$(pwd):/workspace" zoomstudentengagement:complete

# In R:
devtools::load_all()  # Load package in development mode
devtools::test()      # Run tests
devtools::check()     # Run package check
```

### 2. Continuous Integration
```bash
# Run full validation
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript scripts/pre-pr-validation.R
```

### 3. Package Building
```bash
# Build package
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'devtools::build()'

# Install package
docker run --rm -v "$(pwd):/workspace" zoomstudentengagement:complete Rscript -e 'devtools::install()'
```

## Performance Considerations

### Memory Usage
- Core packages: ~500MB
- Development packages: ~200MB
- Development tools: ~300MB
- Transitive dependencies: ~800MB
- Total: ~1.8GB

### Build Time
- First build: ~20-30 minutes (downloads all 136 packages)
- Subsequent builds: ~5-10 minutes (uses cached layers)

### Optimization Tips
1. Use multi-stage builds for production images
2. Cache R package downloads
3. Use `.dockerignore` to exclude unnecessary files
4. Consider using `rocker/rstudio` for interactive development
5. Use the complete Dockerfile for guaranteed success

## Security Considerations

- All packages are from CRAN (trusted source)
- No root user in container
- Minimal system dependencies
- Regular security updates recommended

## Support

For issues with the Docker setup:
1. Check the troubleshooting section above
2. Run the complete verification script to identify missing packages
3. Check Docker logs for detailed error messages
4. Ensure you have sufficient disk space and memory
5. Use `Dockerfile.complete` for guaranteed successful installation

## Related Files

- `DESCRIPTION` - Package metadata and dependencies
- `NAMESPACE` - Import/export declarations
- `Dockerfile` - Original container setup
- `Dockerfile.updated` - Enhanced container setup (direct dependencies only)
- `Dockerfile.complete` - Complete container setup (all 136 packages)
- `scripts/` - Utility scripts for package management
- `tests/` - Package tests
- `vignettes/` - Package documentation
