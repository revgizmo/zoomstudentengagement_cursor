# R Profile for zoomstudentengagement development container

# Set CRAN mirror
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Enable RStudio-like behavior
options(prompt = "R> ")

# Set working directory to project root
if (file.exists("DESCRIPTION")) {
  setwd(dirname(normalizePath("DESCRIPTION")))
}

# Load common development packages
if (interactive()) {
  # Suppress startup messages
  suppressPackageStartupMessages({
    library(usethis)
    library(devtools)
    library(testthat)
  })

  # Set up development environment
  cat("🎯 zoomstudentengagement development environment ready!\n")
  cat("📦 Package development tools loaded\n")
  cat("🧪 Test framework ready\n")
  cat("📚 Documentation tools available\n")
}
