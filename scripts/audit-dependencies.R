#!/usr/bin/env Rscript

# Load required packages
library(readr)
library(dplyr)
library(purrr)

cat("Auditing package dependencies...\n")

# Read DESCRIPTION file
desc <- readLines("DESCRIPTION")

# Find the Imports and Suggests sections
imports_start <- which(grepl("^Imports:", desc))
suggests_start <- which(grepl("^Suggests:", desc))

# Extract packages from multi-line sections
extract_packages_from_section <- function(desc, start_line) {
  if (length(start_line) == 0) return(character(0))
  
  packages <- character(0)
  line_num <- start_line
  
  # Get the first line content
  line <- desc[line_num]
  packages <- c(packages, gsub("^[^:]+:\\s*", "", line))
  
  # Continue reading subsequent lines until we hit a new section
  line_num <- line_num + 1
  while (line_num <= length(desc) && 
         grepl("^\\s", desc[line_num]) && 
         !grepl("^[A-Z]", desc[line_num])) {
    packages <- c(packages, desc[line_num])
    line_num <- line_num + 1
  }
  
  # Clean up packages
  packages <- paste(packages, collapse = " ")
  packages <- strsplit(packages, ",\\s*")[[1]]
  packages <- gsub("\\s*\\([^)]+\\)", "", packages)
  packages <- trimws(packages)
  packages <- packages[packages != ""]
  
  return(packages)
}

imports_pkgs <- extract_packages_from_section(desc, imports_start)
suggests_pkgs <- extract_packages_from_section(desc, suggests_start)

all_packages <- unique(c(imports_pkgs, suggests_pkgs))

cat("Total packages to audit:", length(all_packages), "\n")
cat("Imports:", length(imports_pkgs), "\n")
cat("Suggests:", length(suggests_pkgs), "\n")

cat("\nImports packages:\n")
cat(paste(imports_pkgs, collapse = ", "), "\n")

cat("\nSuggests packages:\n")
cat(paste(suggests_pkgs, collapse = ", "), "\n")

# Test package installation
test_package_installation <- function(pkg) {
  tryCatch({
    install.packages(pkg, quiet = TRUE)
    cat("✅", pkg, "installs successfully\n")
    return(TRUE)
  }, error = function(e) {
    cat("❌", pkg, "fails to install:", e$message, "\n")
    return(FALSE)
  })
}

# Test each package
if (length(all_packages) > 0) {
  results <- map_lgl(all_packages, test_package_installation)
  
  cat("\nInstallation Results:\n")
  cat("Successful:", sum(results), "\n")
  cat("Failed:", sum(!results), "\n")
  
  if (sum(!results) > 0) {
    cat("\nFailed packages:\n")
    failed_packages <- all_packages[!results]
    cat(paste(failed_packages, collapse = "\n"), "\n")
  }
} else {
  cat("\nNo packages found to test.\n")
}
