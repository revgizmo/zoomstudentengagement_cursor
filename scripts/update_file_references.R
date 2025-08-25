#!/usr/bin/env Rscript

# File Reference Update Script for Issue #362
# Updates all file references after reorganization

library(dplyr)
library(stringr)
library(purrr)

# Load the reference map
reference_map <- readRDS("file_reference_map.rds")

# Define new directory structure
new_paths <- list(
  # Implementation guides
  "IMPLEMENTATION_GUIDE" = "docs/development/implementation-guides",
  "CONSOLIDATED_PLAN" = "docs/development/implementation-guides",
  
  # Completion summaries
  "COMPLETION_SUMMARY" = "docs/development/completion-summaries",
  "FINAL_COMPLETION_SUMMARY" = "docs/development/completion-summaries",
  
  # Assessments
  "ASSESSMENT" = "docs/development/assessments",
  "PR_.*_ASSESSMENT" = "docs/development/assessments",
  
  # Analysis reports
  "ANALYSIS_REPORT" = "docs/analysis/reports",
  "VERIFICATION_REPORT" = "docs/analysis/reports",
  "COMPREHENSIVE_ANALYSIS" = "docs/analysis/reports",
  
  # Investigations
  "INVESTIGATION_REPORT" = "docs/analysis/investigations",
  "INVESTIGATION_AND_PLANNING" = "docs/analysis/investigations",
  
  # Lessons learned
  "LESSONS_LEARNED" = "docs/analysis/lessons-learned",
  "ANALYSIS_LESSONS_LEARNED" = "docs/analysis/lessons-learned",
  
  # Other development files
  "AI_AGENT_PROMPT_" = "docs/development",
  "OPEN_PRS_" = "docs/development",
  "PROMPT_GENERATOR" = "docs/development",
  "PLANNER" = "docs/development",
  "SETUP" = "docs/development",
  "EPIC_" = "docs/development",
  "WORKFLOW_" = "docs/development",
  "MANAGEMENT_" = "docs/development"
)

# Function to determine new path for a file
get_new_path <- function(filename) {
  for (pattern in names(new_paths)) {
    if (str_detect(filename, pattern)) {
      return(file.path(new_paths[[pattern]], filename))
    }
  }
  return(NULL)  # Keep at root if no pattern matches
}

# Function to update references in a file
update_file_references <- function(file_path, old_to_new_map) {
  if (!file.exists(file_path)) {
    cat("Warning: File not found:", file_path, "\n")
    return(FALSE)
  }
  
  content <- readLines(file_path, warn = FALSE)
  updated <- FALSE
  
  for (old_file in names(old_to_new_map)) {
    new_path <- old_to_new_map[[old_file]]
    
    # Update various reference patterns
    patterns <- c(
      fixed(old_file),  # Exact filename
      str_replace_all(old_file, "\\.", "\\\\."),  # Escaped for regex
      str_replace_all(old_file, "_", "\\\\_")  # Escaped underscores
    )
    
    for (pattern in patterns) {
      if (any(str_detect(content, pattern))) {
        # Update the reference
        content <- str_replace_all(content, pattern, new_path)
        updated <- TRUE
        cat("Updated reference in", file_path, ":", old_file, "->", new_path, "\n")
      }
    }
  }
  
  if (updated) {
    writeLines(content, file_path)
    return(TRUE)
  }
  
  return(FALSE)
}

# Create mapping of old filenames to new paths
old_to_new_map <- list()
for (filename in names(reference_map)) {
  new_path <- get_new_path(filename)
  if (!is.null(new_path)) {
    old_to_new_map[[filename]] <- new_path
  }
}

# Get all files that need reference updates
files_to_update <- unique(unlist(lapply(reference_map, function(x) x$references)))

# Update references in all files
cat("=== UPDATING FILE REFERENCES ===\n")
cat("Files to update:", length(files_to_update), "\n")
cat("Files being moved:", length(old_to_new_map), "\n\n")

updated_count <- 0
for (file_path in files_to_update) {
  if (update_file_references(file_path, old_to_new_map)) {
    updated_count <- updated_count + 1
  }
}

cat("\n=== SUMMARY ===\n")
cat("Files processed:", length(files_to_update), "\n")
cat("Files updated:", updated_count, "\n")
cat("References updated:", length(old_to_new_map), "\n")

# Save the mapping for reference
saveRDS(old_to_new_map, "old_to_new_path_mapping.rds")
cat("Path mapping saved to: old_to_new_path_mapping.rds\n")

# Create a summary report
cat("\n=== DETAILED MAPPING ===\n")
for (old_file in names(old_to_new_map)) {
  cat(old_file, "->", old_to_new_map[[old_file]], "\n")
}
