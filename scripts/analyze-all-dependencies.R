#!/usr/bin/env Rscript
# Comprehensive Dependency Analysis for zoomstudentengagement
# This script analyzes ALL dependencies including transitive dependencies

cat("🔍 Comprehensive Dependency Analysis for zoomstudentengagement\n")
cat("============================================================\n\n")

# Function to get all dependencies recursively
get_all_dependencies <- function(packages, include_suggests = TRUE) {
  all_deps <- character(0)
  to_check <- packages
  
  while (length(to_check) > 0) {
    current_pkg <- to_check[1]
    to_check <- to_check[-1]
    
    if (current_pkg %in% all_deps) next
    
    cat("  Analyzing:", current_pkg, "\n")
    
    tryCatch({
      # Get package dependencies from CRAN
      deps <- tools::package_dependencies(
        current_pkg, 
        which = c("Depends", "Imports", "LinkingTo"),
        recursive = FALSE,
        db = available.packages(repos = "https://cloud.r-project.org")
      )
      
      if (!is.null(deps[[1]]) && length(deps[[1]]) > 0) {
        new_deps <- deps[[1]]
        # Filter out base R packages
        new_deps <- new_deps[!new_deps %in% c("R", "base", "stats", "graphics", "grDevices", 
                                             "utils", "datasets", "methods", "grid", "splines", 
                                             "tools", "parallel", "compiler", "tcltk")]
        
        all_deps <- c(all_deps, current_pkg)
        to_check <- c(to_check, new_deps[!new_deps %in% all_deps])
      } else {
        all_deps <- c(all_deps, current_pkg)
      }
    }, error = function(e) {
      cat("    Warning: Could not analyze", current_pkg, "-", e$message, "\n")
      all_deps <- c(all_deps, current_pkg)
    })
  }
  
  return(unique(all_deps))
}

# Get direct dependencies from DESCRIPTION
cat("📋 Analyzing direct dependencies from DESCRIPTION...\n")
desc <- read.dcf("DESCRIPTION")
imports <- desc[1, "Imports"]
suggests <- desc[1, "Suggests"]

# Parse imports
direct_imports <- character(0)
if (!is.na(imports)) {
  direct_imports <- strsplit(imports, ",\\s*")[[1]]
  direct_imports <- gsub("\\s*\\([^)]*\\)", "", direct_imports)  # Remove version constraints
  direct_imports <- trimws(direct_imports)
}

# Parse suggests
direct_suggests <- character(0)
if (!is.na(suggests)) {
  direct_suggests <- strsplit(suggests, ",\\s*")[[1]]
  direct_suggests <- gsub("\\s*\\([^)]*\\)", "", direct_suggests)  # Remove version constraints
  direct_suggests <- trimws(direct_suggests)
}

# Additional packages found in code analysis
additional_packages <- c(
  "devtools", "lintr", "styler", "usethis", "remotes", 
  "rcmdcheck", "languageserver"
)

cat("Direct imports:", length(direct_imports), "packages\n")
cat("Direct suggests:", length(direct_suggests), "packages\n")
cat("Additional tools:", length(additional_packages), "packages\n\n")

# Get all transitive dependencies
cat("🔍 Analyzing transitive dependencies...\n")
all_packages_to_analyze <- unique(c(direct_imports, direct_suggests, additional_packages))

cat("Analyzing", length(all_packages_to_analyze), "packages for transitive dependencies...\n")
all_dependencies <- get_all_dependencies(all_packages_to_analyze)

cat("\n📊 DEPENDENCY ANALYSIS RESULTS:\n")
cat("==============================\n\n")

# Categorize dependencies
core_packages <- direct_imports
dev_packages <- direct_suggests
dev_tools <- additional_packages
transitive_deps <- setdiff(all_dependencies, c(core_packages, dev_packages, dev_tools))

cat("📦 PACKAGE CATEGORIES:\n")
cat("---------------------\n")
cat("Core packages (direct imports):", length(core_packages), "\n")
cat("Development packages (direct suggests):", length(dev_packages), "\n")
cat("Development tools (additional):", length(dev_tools), "\n")
cat("Transitive dependencies:", length(transitive_deps), "\n")
cat("TOTAL UNIQUE PACKAGES:", length(all_dependencies), "\n\n")

# Show transitive dependencies
if (length(transitive_deps) > 0) {
  cat("🔄 TRANSITIVE DEPENDENCIES:\n")
  cat("--------------------------\n")
  for (pkg in sort(transitive_deps)) {
    cat("  -", pkg, "\n")
  }
  cat("\n")
}

# Create installation commands
cat("🔧 INSTALLATION COMMANDS:\n")
cat("------------------------\n")

# All packages installation
cat("# Install ALL packages (including transitive dependencies):\n")
cat("install.packages(c(\n")
cat("  ", paste0('"', sort(all_dependencies), '"', collapse = ",\n  "), "\n")
cat("), repos = 'https://cloud.r-project.org')\n\n")

# Core + transitive only
core_and_transitive <- unique(c(core_packages, transitive_deps))
cat("# Install core packages + transitive dependencies only:\n")
cat("install.packages(c(\n")
cat("  ", paste0('"', sort(core_and_transitive), '"', collapse = ",\n  "), "\n")
cat("), repos = 'https://cloud.r-project.org')\n\n")

# Docker integration
cat("🚀 DOCKER INTEGRATION:\n")
cat("--------------------\n")
cat("# Add this to your Dockerfile for complete dependency installation:\n")
cat("RUN R -q -e \"install.packages(c(\n")
cat("  ", paste0('"', sort(all_dependencies), '"', collapse = ",\n  "), "\n")
cat("), repos='https://cloud.r-project.org')\"\n\n")

# Verification script
cat("✅ VERIFICATION SCRIPT:\n")
cat("=====================\n")
cat("# Check if all packages (including transitive) are installed:\n")
cat("all_packages <- c(\n")
cat("  ", paste0('"', sort(all_dependencies), '"', collapse = ",\n  "), "\n")
cat(")\n")
cat("missing_packages <- all_packages[!sapply(all_packages, requireNamespace, quietly = TRUE)]\n")
cat("if (length(missing_packages) > 0) {\n")
cat("  cat('Missing packages:', paste(missing_packages, collapse = ', '), '\\n')\n")
cat("} else {\n")
cat("  cat('All packages (including transitive dependencies) are installed!\\n')\n")
cat("}\n\n")

# Dependency tree analysis
cat("🌳 DEPENDENCY TREE ANALYSIS:\n")
cat("===========================\n")

# Function to show dependency tree for a few key packages
show_dependency_tree <- function(pkg, depth = 0, max_depth = 2, visited = character(0)) {
  if (depth > max_depth || pkg %in% visited) return()
  
  indent <- paste(rep("  ", depth), collapse = "")
  cat(indent, "-", pkg, "\n")
  
  if (depth < max_depth) {
    tryCatch({
      deps <- tools::package_dependencies(
        pkg, 
        which = c("Depends", "Imports"),
        recursive = FALSE,
        db = available.packages(repos = "https://cloud.r-project.org")
      )
      
      if (!is.null(deps[[1]]) && length(deps[[1]]) > 0) {
        new_deps <- deps[[1]]
        new_deps <- new_deps[!new_deps %in% c("R", "base", "stats", "graphics", "grDevices", 
                                             "utils", "datasets", "methods", "grid", "splines", 
                                             "tools", "parallel", "compiler", "tcltk")]
        
        for (dep in sort(new_deps)) {
          show_dependency_tree(dep, depth + 1, max_depth, c(visited, pkg))
        }
      }
    }, error = function(e) {
      # Skip if package not available
    })
  }
}

# Show dependency trees for key packages
key_packages <- c("dplyr", "ggplot2", "data.table")
for (pkg in key_packages) {
  cat("Dependency tree for", pkg, ":\n")
  show_dependency_tree(pkg, max_depth = 2)
  cat("\n")
}

# Summary
cat("📈 SUMMARY:\n")
cat("===========\n")
cat("Original direct dependencies:", length(all_packages_to_analyze), "\n")
cat("Total dependencies (including transitive):", length(all_dependencies), "\n")
cat("Additional transitive dependencies found:", length(transitive_deps), "\n")
cat("Increase in package count:", round((length(all_dependencies) / length(all_packages_to_analyze) - 1) * 100, 1), "%\n\n")

cat("🎯 RECOMMENDATIONS:\n")
cat("==================\n")
cat("1. Use the complete dependency list for Docker installations\n")
cat("2. Consider using 'remotes::install_deps(dependencies = TRUE)' for automatic resolution\n")
cat("3. Test package installation in a clean Docker container\n")
cat("4. Monitor for new transitive dependencies when updating packages\n\n")

cat("📝 NOTES:\n")
cat("--------\n")
cat("- Transitive dependencies are automatically resolved by R's package manager\n")
cat("- Some packages may have system-level dependencies not captured here\n")
cat("- Version conflicts between transitive dependencies are rare but possible\n")
cat("- The complete list ensures reproducible builds across environments\n")
