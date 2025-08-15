#!/usr/bin/env Rscript
# Docker Package Installation Script for zoomstudentengagement
# This script provides all packages needed to run, build, test, and develop the package

cat("📦 Package Installation Guide for zoomstudentengagement\n")
cat("=====================================================\n\n")

# Core package dependencies (from DESCRIPTION Imports)
core_packages <- c(
  "data.table",
  "digest", 
  "dplyr",
  "ggplot2",
  "hms",
  "jsonlite",
  "lubridate",
  "magrittr",
  "purrr",
  "readr",
  "rlang",
  "stringr",
  "tibble",
  "tidyr",
  "tidyselect"
)

# Development dependencies (from DESCRIPTION Suggests)
dev_packages <- c(
  "testthat",
  "withr",
  "covr",
  "knitr",
  "rmarkdown"
)

# Additional development tools (from scripts and Dockerfile)
dev_tools <- c(
  "devtools",
  "lintr",
  "styler",
  "usethis",
  "remotes",
  "rcmdcheck",
  "languageserver"
)

# All packages combined
all_packages <- unique(c(core_packages, dev_packages, dev_tools))

cat("📋 PACKAGE CATEGORIES:\n")
cat("---------------------\n")
cat("Core packages (required for functionality):", length(core_packages), "\n")
cat("Development packages (testing/documentation):", length(dev_packages), "\n")
cat("Development tools (code quality/build):", length(dev_tools), "\n")
cat("Total unique packages:", length(all_packages), "\n\n")

cat("🔧 INSTALLATION COMMANDS:\n")
cat("------------------------\n")

# Installation command for all packages
cat("# Install all packages at once:\n")
cat("install.packages(c(\n")
cat("  ", paste0('"', all_packages, '"', collapse = ",\n  "), "\n")
cat("), repos = 'https://cloud.r-project.org')\n\n")

# Installation by category
cat("# Install core packages only:\n")
cat("install.packages(c(\n")
cat("  ", paste0('"', core_packages, '"', collapse = ",\n  "), "\n")
cat("), repos = 'https://cloud.r-project.org')\n\n")

cat("# Install development packages:\n")
cat("install.packages(c(\n")
cat("  ", paste0('"', c(dev_packages, dev_tools), '"', collapse = ",\n  "), "\n")
cat("), repos = 'https://cloud.r-project.org')\n\n")

cat("📊 PACKAGE DETAILS:\n")
cat("------------------\n")

cat("Core Packages (", length(core_packages), "):\n")
for (pkg in sort(core_packages)) {
  cat("  -", pkg, "\n")
}
cat("\n")

cat("Development Packages (", length(dev_packages), "):\n")
for (pkg in sort(dev_packages)) {
  cat("  -", pkg, "\n")
}
cat("\n")

cat("Development Tools (", length(dev_tools), "):\n")
for (pkg in sort(dev_tools)) {
  cat("  -", pkg, "\n")
}
cat("\n")

cat("🚀 DOCKER INTEGRATION:\n")
cat("--------------------\n")
cat("# Add this to your Dockerfile:\n")
cat("RUN R -q -e \"install.packages(c(\n")
cat("  ", paste0('"', all_packages, '"', collapse = ",\n  "), "\n")
cat("), repos='https://cloud.r-project.org')\"\n\n")

cat("✅ VERIFICATION:\n")
cat("---------------\n")
cat("# Check if all packages are installed:\n")
cat("missing_packages <- c(\n")
cat("  ", paste0('"', all_packages, '"', collapse = ",\n  "), "\n")
cat(")[!sapply(c(\n")
cat("  ", paste0('"', all_packages, '"', collapse = ",\n  "), "\n")
cat("), requireNamespace, quietly = TRUE)]\n")
cat("if (length(missing_packages) > 0) {\n")
cat("  cat('Missing packages:', paste(missing_packages, collapse = ', '), '\\n')\n")
cat("} else {\n")
cat("  cat('All packages are installed!\\n')\n")
cat("}\n\n")

cat("🎯 USAGE SCENARIOS:\n")
cat("------------------\n")
cat("1. Basic package usage: Install core_packages only\n")
cat("2. Run tests: Install core_packages + dev_packages\n")
cat("3. Full development: Install all packages\n")
cat("4. Docker container: Use the Docker integration command above\n\n")

cat("📝 NOTES:\n")
cat("--------\n")
cat("- All packages are available on CRAN\n")
cat("- No Bioconductor or GitHub-only dependencies\n")
cat("- Package versions are managed by DESCRIPTION file\n")
cat("- Dockerfile already includes most system dependencies\n")
cat("- Use 'remotes::install_deps()' to install from DESCRIPTION\n\n")

cat("🔗 RELATED FILES:\n")
cat("----------------\n")
cat("- DESCRIPTION: Package metadata and dependencies\n")
cat("- NAMESPACE: Import/export declarations\n")
cat("- Dockerfile: Container setup with system dependencies\n")
cat("- scripts/pre-pr-validation.R: Development workflow\n")
