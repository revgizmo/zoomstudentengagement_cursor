#!/usr/bin/env Rscript

# File Accumulation Prevention Script
# Monitors and prevents non-standard files at root level

library(dplyr)
library(stringr)

# Define acceptable files at root level
acceptable_root_files <- c(
  # Essential package files
  "DESCRIPTION",
  "NAMESPACE", 
  "LICENSE",
  "LICENSE.md",
  "README.md",
  "README.Rmd",
  "NEWS.md",
  "_pkgdown.yml",
  
  # Essential project files
  "PROJECT.md",
  "CONTRIBUTING.md",
  "CRAN_CHECKLIST.md",
  
  # R package files
  "R",
  "man",
  "inst",
  "tests",
  "vignettes",
  "docs",
  "scripts",
  
  # Hidden files
  ".Rbuildignore",
  ".gitignore",
  ".lintr",
  ".Rproj",
  
  # Temporary files (acceptable)
  "r_cmd_check_current.txt",
  "r_cmd_check_after_cleanup.txt"
)

# Define file patterns that should NOT be at root
non_standard_patterns <- c(
  # Implementation guides
  ".*_IMPLEMENTATION_GUIDE\\.md$",
  ".*_CONSOLIDATED_PLAN\\.md$",
  
  # Completion summaries
  ".*_COMPLETION_SUMMARY\\.md$",
  ".*_FINAL_COMPLETION_SUMMARY\\.md$",
  
  # Assessments
  ".*_ASSESSMENT\\.md$",
  "PR_.*_ASSESSMENT\\.md$",
  
  # Analysis reports
  ".*_ANALYSIS_REPORT\\.md$",
  ".*_VERIFICATION_REPORT\\.md$",
  ".*_COMPREHENSIVE_ANALYSIS\\.md$",
  
  # Investigations
  ".*_INVESTIGATION_REPORT\\.md$",
  ".*_INVESTIGATION_AND_PLANNING\\.md$",
  
  # Lessons learned
  ".*_LESSONS_LEARNED\\.md$",
  ".*_ANALYSIS_LESSONS_LEARNED\\.md$",
  
  # Other development files
  "AI_AGENT_PROMPT_.*\\.md$",
  "OPEN_PRS_.*\\.md$",
  ".*_PROMPT_GENERATOR\\.md$",
  ".*_PLANNER\\.md$",
  ".*_SETUP\\.md$",
  ".*_EPIC_.*\\.md$",
  ".*_WORKFLOW_.*\\.md$",
  ".*_MANAGEMENT_.*\\.md$"
)

# Function to check for non-standard files
check_root_level_files <- function() {
  # Get all files at root level
  root_files <- list.files(path = ".", full.names = FALSE)
  
  # Filter out directories
  root_files <- root_files[!dir.exists(root_files)]
  
  # Check for non-standard files
  violations <- character()
  suggestions <- list()
  
  for (file in root_files) {
    # Skip if it's an acceptable file
    if (file %in% acceptable_root_files) {
      next
    }
    
    # Check if it matches non-standard patterns
    is_violation <- FALSE
    for (pattern in non_standard_patterns) {
      if (str_detect(file, pattern)) {
        is_violation <- TRUE
        break
      }
    }
    
    if (is_violation) {
      violations <- c(violations, file)
      
      # Suggest proper location
      suggestion <- suggest_proper_location(file)
      suggestions[[file]] <- suggestion
    }
  }
  
  return(list(
    violations = violations,
    suggestions = suggestions,
    total_files = length(root_files),
    violation_count = length(violations)
  ))
}

# Function to suggest proper location for a file
suggest_proper_location <- function(filename) {
  if (str_detect(filename, "IMPLEMENTATION_GUIDE|CONSOLIDATED_PLAN")) {
    return("docs/development/implementation-guides/")
  } else if (str_detect(filename, "COMPLETION_SUMMARY")) {
    return("docs/development/completion-summaries/")
  } else if (str_detect(filename, "ASSESSMENT")) {
    return("docs/development/assessments/")
  } else if (str_detect(filename, "ANALYSIS_REPORT|VERIFICATION_REPORT|COMPREHENSIVE_ANALYSIS")) {
    return("docs/analysis/reports/")
  } else if (str_detect(filename, "INVESTIGATION")) {
    return("docs/analysis/investigations/")
  } else if (str_detect(filename, "LESSONS_LEARNED")) {
    return("docs/analysis/lessons-learned/")
  } else {
    return("docs/development/")
  }
}

# Function to create prevention report
create_prevention_report <- function(check_result) {
  cat("=== FILE ACCUMULATION PREVENTION REPORT ===\n")
  cat("Generated:", Sys.time(), "\n\n")
  
  cat("Total files at root level:", check_result$total_files, "\n")
  cat("Non-standard files found:", check_result$violation_count, "\n\n")
  
  if (check_result$violation_count > 0) {
    cat("VIOLATIONS FOUND:\n")
    cat("================\n")
    
    for (file in check_result$violations) {
      suggestion <- check_result$suggestions[[file]]
      cat("File:", file, "\n")
      cat("Suggested location:", suggestion, "\n")
      cat("Action: Move to", suggestion, file, "\n\n")
    }
    
    cat("RECOMMENDED ACTIONS:\n")
    cat("===================\n")
    cat("1. Move non-standard files to suggested locations\n")
    cat("2. Update any references to moved files\n")
    cat("3. Add moved files to .Rbuildignore if not already there\n")
    cat("4. Run R CMD check to verify improvement\n\n")
    
    return(FALSE)  # Indicates violations found
  } else {
    cat("✅ NO VIOLATIONS FOUND\n")
    cat("Root level is clean and properly organized.\n\n")
    return(TRUE)  # Indicates no violations
  }
}

# Function to create prevention policy
create_prevention_policy <- function() {
  policy <- "
# File Organization Policy

## Root Level Files
Only the following files should be at the root level:
- Essential package files (DESCRIPTION, NAMESPACE, LICENSE, etc.)
- Essential project files (README.md, PROJECT.md, etc.)
- Package directories (R/, man/, inst/, tests/, vignettes/)
- Configuration files (.Rbuildignore, .gitignore, etc.)

## Development Documentation
All development documentation should be organized in appropriate subdirectories:

### docs/development/
- Implementation guides (*_IMPLEMENTATION_GUIDE.md)
- Consolidated plans (*_CONSOLIDATED_PLAN.md)
- Completion summaries (*_COMPLETION_SUMMARY.md)
- Assessments (*_ASSESSMENT.md)
- Other development files

### docs/analysis/
- Analysis reports (*_ANALYSIS_REPORT.md)
- Verification reports (*_VERIFICATION_REPORT.md)
- Investigation reports (*_INVESTIGATION_REPORT.md)
- Lessons learned (*_LESSONS_LEARNED.md)

## Prevention Measures
1. Run this script before committing changes
2. Use proper directory structure for new files
3. Update references when moving files
4. Add new directories to .Rbuildignore as needed

## Automated Checks
This script should be run:
- Before creating pull requests
- As part of CI/CD pipeline
- During regular maintenance
"
  
  writeLines(policy, "docs/development/FILE_ORGANIZATION_POLICY.md")
  cat("Prevention policy created: docs/development/FILE_ORGANIZATION_POLICY.md\n")
}

# Main execution
main <- function() {
  cat("Running file accumulation prevention check...\n\n")
  
  # Check for violations
  check_result <- check_root_level_files()
  
  # Create report
  is_clean <- create_prevention_report(check_result)
  
  # Create prevention policy if it doesn't exist
  if (!file.exists("docs/development/FILE_ORGANIZATION_POLICY.md")) {
    create_prevention_policy()
  }
  
  # Return exit code
  if (is_clean) {
    cat("✅ CHECK PASSED - No violations found\n")
    quit(status = 0)
  } else {
    cat("❌ CHECK FAILED - Violations found\n")
    quit(status = 1)
  }
}

# Run if called directly
if (!interactive()) {
  main()
}
