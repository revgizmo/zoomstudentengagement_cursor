#!/usr/bin/env Rscript

# File Reference Mapping Script for Issue #362
# Maps all references to files that will be moved during reorganization

library(dplyr)
library(stringr)
library(purrr)

# Files to be moved (patterns)
files_to_move <- c(
  # Implementation guides
  ".*_IMPLEMENTATION_GUIDE\\.md$",
  ".*_CONSOLIDATED_PLAN\\.md$", 
  ".*_COMPLETION_SUMMARY\\.md$",
  ".*_ASSESSMENT\\.md$",
  
  # Analysis reports
  ".*_ANALYSIS_REPORT\\.md$",
  ".*_VERIFICATION_REPORT\\.md$",
  ".*_COMPREHENSIVE_ANALYSIS\\.md$",
  ".*_INVESTIGATION_REPORT\\.md$",
  ".*_LESSONS_LEARNED\\.md$",
  
  # Other development files
  "AI_AGENT_PROMPT_.*\\.md$",
  "PR_.*_ASSESSMENT\\.md$",
  "OPEN_PRS_.*\\.md$",
  ".*_PROMPT_GENERATOR\\.md$",
  ".*_PLANNER\\.md$",
  ".*_SETUP\\.md$",
  ".*_EPIC_.*\\.md$",
  ".*_WORKFLOW_.*\\.md$",
  ".*_MANAGEMENT_.*\\.md$"
)

# Get all files in the repository
all_files <- list.files(
  path = ".",
  pattern = "\\.(md|R|Rmd|txt)$",
  recursive = TRUE,
  full.names = TRUE
)

# Filter out git and backup directories
all_files <- all_files[!str_detect(all_files, "\\.git/|backup_|node_modules/")]

# Find files that match our patterns
files_to_move_list <- character()
for (pattern in files_to_move) {
  matches <- all_files[str_detect(basename(all_files), pattern)]
  files_to_move_list <- c(files_to_move_list, matches)
}

# Remove duplicates and sort
files_to_move_list <- unique(sort(files_to_move_list))

# Create reference mapping
reference_map <- list()

for (file_path in files_to_move_list) {
  file_name <- basename(file_path)
  
  # Find all files that reference this file
  references <- character()
  
  for (search_file in all_files) {
    if (file_path != search_file) {
      content <- tryCatch({
        readLines(search_file, warn = FALSE)
      }, error = function(e) {
        character(0)
      })
      
      # Check if file content references the target file
      if (any(str_detect(content, fixed(file_name)))) {
        references <- c(references, search_file)
      }
    }
  }
  
  reference_map[[file_name]] <- list(
    current_path = file_path,
    references = references
  )
}

# Generate report
cat("=== FILE REFERENCE MAPPING REPORT ===\n")
cat("Generated:", Sys.time(), "\n\n")

cat("Files to be moved:", length(files_to_move_list), "\n\n")

for (file_name in names(reference_map)) {
  info <- reference_map[[file_name]]
  cat("File:", file_name, "\n")
  cat("Current path:", info$current_path, "\n")
  cat("Referenced by:", length(info$references), "files\n")
  
  if (length(info$references) > 0) {
    cat("References:\n")
    for (ref in info$references) {
      cat("  -", ref, "\n")
    }
  }
  cat("\n")
}

# Save detailed report
saveRDS(reference_map, "file_reference_map.rds")

cat("Detailed reference map saved to: file_reference_map.rds\n")
cat("Total files to move:", length(files_to_move_list), "\n")
cat("Total files with references:", sum(sapply(reference_map, function(x) length(x$references) > 0)), "\n")
