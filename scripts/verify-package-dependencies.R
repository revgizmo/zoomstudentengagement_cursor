#!/usr/bin/env Rscript
# Package Dependency Verification Script for zoomstudentengagement
# This script verifies that all required packages are installed and accessible

cat("🔍 Package Dependency Verification for zoomstudentengagement\n")
cat("==========================================================\n\n")

# Define all required packages by category
core_packages <- c(
  "data.table", "digest", "dplyr", "ggplot2", "hms", "jsonlite",
  "lubridate", "magrittr", "purrr", "readr", "rlang", "stringr",
  "tibble", "tidyr", "tidyselect"
)

dev_packages <- c(
  "testthat", "withr", "covr", "knitr", "rmarkdown"
)

dev_tools <- c(
  "devtools", "lintr", "styler", "usethis", "remotes", "rcmdcheck", "languageserver"
)

all_packages <- unique(c(core_packages, dev_packages, dev_tools))

# Function to check package availability
check_package <- function(pkg_name) {
  tryCatch({
    # Try to load the package
    suppressPackageStartupMessages(requireNamespace(pkg_name, quietly = TRUE))
    return(list(
      available = TRUE,
      version = packageVersion(pkg_name),
      error = NULL
    ))
  }, error = function(e) {
    return(list(
      available = FALSE,
      version = NULL,
      error = e$message
    ))
  })
}

# Check all packages
cat("📦 Checking package availability...\n")
cat("-----------------------------------\n")

results <- list()
for (pkg in all_packages) {
  results[[pkg]] <- check_package(pkg)
}

# Report results by category
cat("\n📊 VERIFICATION RESULTS:\n")
cat("========================\n\n")

# Core packages
cat("🔧 Core Packages (Required for functionality):\n")
cat("---------------------------------------------\n")
core_status <- sapply(core_packages, function(pkg) results[[pkg]]$available)
for (pkg in core_packages) {
  status <- if (results[[pkg]]$available) "✅" else "❌"
  version <- if (results[[pkg]]$available) as.character(results[[pkg]]$version) else "NOT INSTALLED"
  cat(sprintf("  %s %-15s %s\n", status, pkg, version))
}
cat("  Summary: ", sum(core_status), "/", length(core_status), " installed\n\n")

# Development packages
cat("🧪 Development Packages (Testing/Documentation):\n")
cat("-----------------------------------------------\n")
dev_status <- sapply(dev_packages, function(pkg) results[[pkg]]$available)
for (pkg in dev_packages) {
  status <- if (results[[pkg]]$available) "✅" else "❌"
  version <- if (results[[pkg]]$available) as.character(results[[pkg]]$version) else "NOT INSTALLED"
  cat(sprintf("  %s %-15s %s\n", status, pkg, version))
}
cat("  Summary: ", sum(dev_status), "/", length(dev_status), " installed\n\n")

# Development tools
cat("🛠️  Development Tools (Code Quality/Build):\n")
cat("------------------------------------------\n")
tools_status <- sapply(dev_tools, function(pkg) results[[pkg]]$available)
for (pkg in dev_tools) {
  status <- if (results[[pkg]]$available) "✅" else "❌"
  version <- if (results[[pkg]]$available) as.character(results[[pkg]]$version) else "NOT INSTALLED"
  cat(sprintf("  %s %-15s %s\n", status, pkg, version))
}
cat("  Summary: ", sum(tools_status), "/", length(tools_status), " installed\n\n")

# Overall summary
cat("📈 OVERALL SUMMARY:\n")
cat("==================\n")
total_installed <- sum(sapply(all_packages, function(pkg) results[[pkg]]$available))
total_packages <- length(all_packages)
cat("Total packages checked:", total_packages, "\n")
cat("Packages installed:", total_installed, "\n")
cat("Packages missing:", total_packages - total_installed, "\n")
cat("Installation rate:", round(total_installed/total_packages * 100, 1), "%\n\n")

# Missing packages report
missing_packages <- all_packages[sapply(all_packages, function(pkg) !results[[pkg]]$available)]
if (length(missing_packages) > 0) {
  cat("❌ MISSING PACKAGES:\n")
  cat("===================\n")
  for (pkg in missing_packages) {
    cat("  -", pkg, ":", results[[pkg]]$error, "\n")
  }
  cat("\n")
  
  cat("🔧 INSTALLATION COMMAND FOR MISSING PACKAGES:\n")
  cat("============================================\n")
  cat("install.packages(c(\n")
  cat("  ", paste0('"', missing_packages, '"', collapse = ",\n  "), "\n")
  cat("), repos = 'https://cloud.r-project.org')\n\n")
}

# Package functionality test
cat("🧪 FUNCTIONALITY TEST:\n")
cat("=====================\n")

# Test if the main package can be loaded
tryCatch({
  if (requireNamespace("zoomstudentengagement", quietly = TRUE)) {
    cat("✅ zoomstudentengagement package is available\n")
    
    # Test if core functionality works
    if (all(core_status)) {
      cat("✅ All core dependencies are available\n")
      
      # Try to load the package
      tryCatch({
        library(zoomstudentengagement)
        cat("✅ Package loads successfully\n")
        
        # Check exported functions
        exported_functions <- getNamespaceExports("zoomstudentengagement")
        cat("✅ Package exports", length(exported_functions), "functions\n")
        
      }, error = function(e) {
        cat("❌ Package loading failed:", e$message, "\n")
      })
    } else {
      cat("❌ Some core dependencies are missing\n")
    }
  } else {
    cat("❌ zoomstudentengagement package is not installed\n")
  }
}, error = function(e) {
  cat("❌ Package verification failed:", e$message, "\n")
})

cat("\n🎯 RECOMMENDATIONS:\n")
cat("==================\n")

if (total_installed == total_packages) {
  cat("✅ All packages are installed! Your environment is ready.\n")
} else {
  cat("⚠️  Some packages are missing. Recommendations:\n")
  
  if (!all(core_status)) {
    cat("  1. Install missing core packages first (required for functionality)\n")
  }
  
  if (!all(dev_status)) {
    cat("  2. Install missing development packages (needed for testing)\n")
  }
  
  if (!all(tools_status)) {
    cat("  3. Install missing development tools (needed for code quality)\n")
  }
  
  cat("\n  Use the installation command above to install missing packages.\n")
}

cat("\n📝 NOTES:\n")
cat("--------\n")
cat("- Core packages are required for the package to function\n")
cat("- Development packages are needed for testing and documentation\n")
cat("- Development tools are needed for code quality and building\n")
cat("- All packages are available on CRAN\n")
cat("- Use 'remotes::install_deps()' to install from DESCRIPTION file\n")
