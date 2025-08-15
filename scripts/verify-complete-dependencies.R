#!/usr/bin/env Rscript
# Complete Dependency Verification for zoomstudentengagement
# This script verifies ALL 136 packages including transitive dependencies

cat("🔍 Complete Dependency Verification for zoomstudentengagement\n")
cat("===========================================================\n\n")

# All 136 packages including transitive dependencies
all_packages <- c(
  "askpass", "backports", "base64enc", "bit", "bit64", "brew", "brio", "bslib", 
  "cachem", "callr", "cli", "clipr", "codetools", "collections", "commonmark", 
  "covr", "cpp11", "crayon", "credentials", "curl", "data.table", "desc", 
  "devtools", "diffobj", "digest", "downlit", "dplyr", "ellipsis", "evaluate", 
  "fansi", "farver", "fastmap", "fontawesome", "fs", "generics", "gert", 
  "ggplot2", "gh", "gitcreds", "glue", "gtable", "highr", "hms", "htmltools", 
  "htmlwidgets", "httpuv", "httr", "httr2", "ini", "isoband", "jquerylib", 
  "jsonlite", "knitr", "labeling", "languageserver", "later", "lattice", 
  "lazyeval", "lifecycle", "lintr", "lubridate", "magrittr", "MASS", "Matrix", 
  "memoise", "mgcv", "mime", "miniUI", "nlme", "openssl", "pillar", "pkgbuild", 
  "pkgconfig", "pkgdown", "pkgload", "praise", "prettyunits", "processx", 
  "profvis", "progress", "promises", "ps", "purrr", "R.cache", "R.methodsS3", 
  "R.oo", "R.utils", "R6", "ragg", "rappdirs", "rcmdcheck", "RColorBrewer", 
  "Rcpp", "readr", "remotes", "rex", "rlang", "rmarkdown", "roxygen2", 
  "rprojroot", "rstudioapi", "rversions", "sass", "scales", "sessioninfo", 
  "shiny", "sourcetools", "stringi", "stringr", "styler", "sys", "systemfonts", 
  "testthat", "textshaping", "tibble", "tidyr", "tidyselect", "timechange", 
  "tinytex", "tzdb", "urlchecker", "usethis", "utf8", "vctrs", "viridisLite", 
  "vroom", "waldo", "whisker", "withr", "xfun", "xml2", "xmlparsedata", 
  "xopen", "xtable", "yaml", "zip"
)

# Categorize packages
direct_imports <- c("data.table", "digest", "dplyr", "ggplot2", "hms", "jsonlite", 
                   "lubridate", "magrittr", "purrr", "readr", "rlang", "stringr", 
                   "tibble", "tidyr", "tidyselect")

direct_suggests <- c("testthat", "withr", "covr", "knitr", "rmarkdown")

dev_tools <- c("devtools", "lintr", "styler", "usethis", "remotes", "rcmdcheck", "languageserver")

transitive_deps <- setdiff(all_packages, c(direct_imports, direct_suggests, dev_tools))

cat("📦 PACKAGE CATEGORIES:\n")
cat("---------------------\n")
cat("Direct imports:", length(direct_imports), "packages\n")
cat("Direct suggests:", length(direct_suggests), "packages\n")
cat("Development tools:", length(dev_tools), "packages\n")
cat("Transitive dependencies:", length(transitive_deps), "packages\n")
cat("TOTAL PACKAGES:", length(all_packages), "\n\n")

# Function to check package availability
check_package <- function(pkg_name) {
  tryCatch({
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
cat("🔍 Checking all 136 packages...\n")
cat("-------------------------------\n")

results <- list()
for (pkg in all_packages) {
  results[[pkg]] <- check_package(pkg)
}

# Report results by category
cat("\n📊 VERIFICATION RESULTS:\n")
cat("========================\n\n")

# Direct imports
cat("🔧 Direct Imports (Required for functionality):\n")
cat("----------------------------------------------\n")
imports_status <- sapply(direct_imports, function(pkg) results[[pkg]]$available)
for (pkg in direct_imports) {
  status <- if (results[[pkg]]$available) "✅" else "❌"
  version <- if (results[[pkg]]$available) as.character(results[[pkg]]$version) else "NOT INSTALLED"
  cat(sprintf("  %s %-15s %s\n", status, pkg, version))
}
cat("  Summary: ", sum(imports_status), "/", length(imports_status), " installed\n\n")

# Direct suggests
cat("🧪 Direct Suggests (Testing/Documentation):\n")
cat("------------------------------------------\n")
suggests_status <- sapply(direct_suggests, function(pkg) results[[pkg]]$available)
for (pkg in direct_suggests) {
  status <- if (results[[pkg]]$available) "✅" else "❌"
  version <- if (results[[pkg]]$available) as.character(results[[pkg]]$version) else "NOT INSTALLED"
  cat(sprintf("  %s %-15s %s\n", status, pkg, version))
}
cat("  Summary: ", sum(suggests_status), "/", length(suggests_status), " installed\n\n")

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

# Transitive dependencies
cat("🔄 Transitive Dependencies:\n")
cat("--------------------------\n")
transitive_status <- sapply(transitive_deps, function(pkg) results[[pkg]]$available)
for (pkg in sort(transitive_deps)) {
  status <- if (results[[pkg]]$available) "✅" else "❌"
  version <- if (results[[pkg]]$available) as.character(results[[pkg]]$version) else "NOT INSTALLED"
  cat(sprintf("  %s %-15s %s\n", status, pkg, version))
}
cat("  Summary: ", sum(transitive_status), "/", length(transitive_status), " installed\n\n")

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

# Critical missing packages
critical_missing <- intersect(missing_packages, direct_imports)
if (length(critical_missing) > 0) {
  cat("🚨 CRITICAL MISSING PACKAGES (Direct Imports):\n")
  cat("=============================================\n")
  for (pkg in critical_missing) {
    cat("  -", pkg, ":", results[[pkg]]$error, "\n")
  }
  cat("\n")
  cat("⚠️  These packages are required for basic functionality!\n\n")
}

# Package functionality test
cat("🧪 FUNCTIONALITY TEST:\n")
cat("=====================\n")

# Test if the main package can be loaded
tryCatch({
  if (requireNamespace("zoomstudentengagement", quietly = TRUE)) {
    cat("✅ zoomstudentengagement package is available\n")
    
    # Test if core functionality works
    if (all(imports_status)) {
      cat("✅ All direct imports are available\n")
      
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
      cat("❌ Some direct imports are missing\n")
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
  cat("✅ All 136 packages are installed! Your environment is complete.\n")
} else {
  cat("⚠️  Some packages are missing. Recommendations:\n")
  
  if (length(critical_missing) > 0) {
    cat("  1. Install critical missing packages first (direct imports)\n")
  }
  
  if (!all(imports_status)) {
    cat("  2. Install missing direct imports (required for functionality)\n")
  }
  
  if (!all(suggests_status)) {
    cat("  3. Install missing direct suggests (needed for testing)\n")
  }
  
  if (!all(tools_status)) {
    cat("  4. Install missing development tools (needed for code quality)\n")
  }
  
  if (length(missing_packages) > length(critical_missing)) {
    cat("  5. Install remaining missing transitive dependencies\n")
  }
  
  cat("\n  Use the installation command above to install missing packages.\n")
  cat("  Or use 'remotes::install_deps(dependencies = TRUE)' for automatic resolution.\n")
}

cat("\n📝 NOTES:\n")
cat("--------\n")
cat("- Direct imports are required for the package to function\n")
cat("- Direct suggests are needed for testing and documentation\n")
cat("- Development tools are needed for code quality and building\n")
cat("- Transitive dependencies are automatically resolved by R's package manager\n")
cat("- All 136 packages ensure complete and reproducible builds\n")
cat("- Use Dockerfile.complete for guaranteed successful installations\n")
