#!/usr/bin/env Rscript

# Test package installation in Docker container
cat("Testing package installation in Docker environment...\n")

# Function to install packages with error handling
install_packages_safely <- function(packages) {
  results <- list()
  
  for (pkg in packages) {
    cat("Installing", pkg, "...\n")
    
    result <- tryCatch({
      install.packages(pkg, quiet = TRUE, dependencies = TRUE)
      list(success = TRUE, error = NULL)
    }, error = function(e) {
      list(success = FALSE, error = e$message)
    })
    
    results[[pkg]] <- result
  }
  
  return(results)
}

# Read package list from DESCRIPTION
desc <- readLines("DESCRIPTION")
imports_line <- grep("^Imports:", desc, value = TRUE)
suggests_line <- grep("^Suggests:", desc, value = TRUE)

# Extract packages
extract_packages <- function(line) {
  if (length(line) == 0) return(character(0))
  packages <- gsub("^[^:]+:\\s*", "", line)
  packages <- strsplit(packages, ",\\s*")[[1]]
  packages <- gsub("\\s*\\([^)]+\\)", "", packages)
  packages <- packages[packages != "R"]
  return(packages)
}

imports_pkgs <- extract_packages(imports_line)
suggests_pkgs <- extract_packages(suggests_line)

# Test imports (required)
cat("Testing Imports packages...\n")
imports_results <- install_packages_safely(imports_pkgs)

# Test suggests (optional)
cat("Testing Suggests packages...\n")
suggests_results <- install_packages_safely(suggests_pkgs)

# Report results
cat("\n=== Installation Results ===\n")

cat("\nImports (Required):\n")
imports_success <- sum(sapply(imports_results, function(x) x$success))
cat("Successful:", imports_success, "/", length(imports_pkgs), "\n")

if (imports_success < length(imports_pkgs)) {
  cat("Failed imports:\n")
  for (pkg in names(imports_results)) {
    if (!imports_results[[pkg]]$success) {
      cat("  -", pkg, ":", imports_results[[pkg]]$error, "\n")
    }
  }
}

cat("\nSuggests (Optional):\n")
suggests_success <- sum(sapply(suggests_results, function(x) x$success))
cat("Successful:", suggests_success, "/", length(suggests_pkgs), "\n")

if (suggests_success < length(suggests_pkgs)) {
  cat("Failed suggests:\n")
  for (pkg in names(suggests_results)) {
    if (!suggests_results[[pkg]]$success) {
      cat("  -", pkg, ":", suggests_results[[pkg]]$error, "\n")
    }
  }
}
