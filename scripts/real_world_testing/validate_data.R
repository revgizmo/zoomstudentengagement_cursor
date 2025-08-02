#!/usr/bin/env Rscript

# Data Validation Script for Real-World Testing
# This script validates test data before running tests

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
  library(fs)
})

# Colors for output
RED <- "\033[31m"
GREEN <- "\033[32m"
YELLOW <- "\033[33m"
BLUE <- "\033[34m"
NC <- "\033[0m" # No Color

print_status <- function(status, message) {
  switch(status,
    "success" = cat(GREEN, "✅", NC, message, "\n"),
    "warning" = cat(YELLOW, "⚠️", NC, message, "\n"),
    "error" = cat(RED, "❌", NC, message, "\n"),
    "info" = cat(BLUE, "ℹ️", NC, message, "\n")
  )
}

# Validate transcript files
validate_transcripts <- function(transcript_dir = "data/transcripts") {
  print_status("info", "Validating transcript files...")
  
  if (!dir_exists(transcript_dir)) {
    print_status("error", paste("Transcript directory not found:", transcript_dir))
    return(FALSE)
  }
  
  # Find transcript files
  transcript_files <- list.files(
    transcript_dir, 
    pattern = "\\.(vtt|txt|csv)$", 
    full.names = TRUE,
    recursive = TRUE
  )
  
  if (length(transcript_files) == 0) {
    print_status("warning", "No transcript files found")
    print_status("info", "Expected files: .vtt, .txt, or .csv files")
    return(FALSE)
  }
  
  print_status("success", paste("Found", length(transcript_files), "transcript file(s)"))
  
  # Check file sizes
  file_sizes <- file.size(transcript_files)
  large_files <- transcript_files[file_sizes > 1024 * 1024] # >1MB
  
  if (length(large_files) > 0) {
    print_status("info", paste("Found", length(large_files), "large file(s) for performance testing"))
  }
  
  # Validate file content (basic check)
  valid_files <- 0
  for (file in transcript_files) {
    tryCatch({
      # Try to read first few lines
      lines <- readLines(file, n = 5, warn = FALSE)
      if (length(lines) > 0 && any(nchar(lines) > 0)) {
        valid_files <- valid_files + 1
      } else {
        print_status("warning", paste("Empty or invalid file:", basename(file)))
      }
    }, error = function(e) {
      print_status("error", paste("Cannot read file:", basename(file)))
    })
  }
  
  print_status("success", paste("Valid transcript files:", valid_files, "/", length(transcript_files)))
  return(valid_files > 0)
}

# Validate roster data
validate_roster <- function(metadata_dir = "data/metadata") {
  print_status("info", "Validating roster data...")
  
  roster_file <- file.path(metadata_dir, "roster.csv")
  
  if (!file_exists(roster_file)) {
    print_status("error", "roster.csv not found")
    print_status("info", "Expected location: data/metadata/roster.csv")
    return(FALSE)
  }
  
  tryCatch({
    roster <- read_csv(roster_file, show_col_types = FALSE)
    
    print_status("success", paste("Roster loaded:", nrow(roster), "students"))
    
    # Check for required columns
    required_cols <- c("name", "id", "course")
    missing_cols <- setdiff(required_cols, tolower(names(roster)))
    
    if (length(missing_cols) > 0) {
      print_status("warning", paste("Missing columns:", paste(missing_cols, collapse = ", ")))
      print_status("info", "Expected columns: name, id, course (case insensitive)")
    } else {
      print_status("success", "All required columns present")
    }
    
    # Check for empty values
    empty_names <- sum(is.na(roster[[1]]) | roster[[1]] == "")
    if (empty_names > 0) {
      print_status("warning", paste(empty_names, "empty or missing names found"))
    }
    
    return(TRUE)
    
  }, error = function(e) {
    print_status("error", paste("Cannot read roster file:", e$message))
    return(FALSE)
  })
}

# Validate session metadata
validate_session_metadata <- function(metadata_dir = "data/metadata") {
  print_status("info", "Validating session metadata...")
  
  session_files <- list.files(
    metadata_dir, 
    pattern = "zoomus_recordings__.*\\.csv$", 
    full.names = TRUE
  )
  
  if (length(session_files) == 0) {
    print_status("warning", "No session metadata files found")
    print_status("info", "Expected files: zoomus_recordings__*.csv")
    return(FALSE)
  }
  
  print_status("success", paste("Found", length(session_files), "session metadata file(s)"))
  
  valid_files <- 0
  for (file in session_files) {
    tryCatch({
      metadata <- read_csv(file, show_col_types = FALSE)
      
      # Check for required columns
      required_cols <- c("Topic", "Start Time", "File Size (MB)")
      missing_cols <- setdiff(required_cols, names(metadata))
      
      if (length(missing_cols) == 0) {
        valid_files <- valid_files + 1
        print_status("success", paste("Valid metadata file:", basename(file)))
      } else {
        print_status("warning", paste("Missing columns in", basename(file), ":", paste(missing_cols, collapse = ", ")))
      }
      
    }, error = function(e) {
      print_status("error", paste("Cannot read metadata file:", basename(file)))
    })
  }
  
  print_status("success", paste("Valid metadata files:", valid_files, "/", length(session_files)))
  return(valid_files > 0)
}

# Check data privacy
check_data_privacy <- function(transcript_dir = "data/transcripts", metadata_dir = "data/metadata") {
  print_status("info", "Checking data privacy...")
  
  privacy_issues <- 0
  
  # Check transcript files for potential sensitive content
  transcript_files <- list.files(
    transcript_dir, 
    pattern = "\\.(vtt|txt|csv)$", 
    full.names = TRUE,
    recursive = TRUE
  )
  
  for (file in transcript_files[1:min(3, length(transcript_files))]) { # Check first 3 files
    tryCatch({
      content <- readLines(file, n = 50, warn = FALSE) # Read first 50 lines
      content_text <- paste(content, collapse = " ")
      
      # Check for potential sensitive patterns
      sensitive_patterns <- c(
        "password", "credit card", "ssn", "social security",
        "phone number", "address", "email", "@",
        "confidential", "private", "secret"
      )
      
      found_patterns <- sapply(sensitive_patterns, function(pattern) {
        grepl(pattern, content_text, ignore.case = TRUE)
      })
      
      if (any(found_patterns)) {
        print_status("warning", paste("Potential sensitive content in:", basename(file)))
        print_status("info", "Consider anonymizing the data")
        privacy_issues <- privacy_issues + 1
      }
      
    }, error = function(e) {
      # Skip files that can't be read
    })
  }
  
  # Check roster for real names
  roster_file <- file.path(metadata_dir, "roster.csv")
  if (file_exists(roster_file)) {
    tryCatch({
      roster <- read_csv(roster_file, show_col_types = FALSE)
      if (nrow(roster) > 0) {
        first_name <- roster[[1]][1]
        if (!is.na(first_name) && nchar(first_name) > 0) {
          # Simple check for common real names vs placeholder names
          placeholder_patterns <- c("student", "user", "test", "anon", "placeholder")
          is_placeholder <- any(sapply(placeholder_patterns, function(p) {
            grepl(p, first_name, ignore.case = TRUE)
          }))
          
          if (!is_placeholder) {
            print_status("warning", "Roster may contain real names")
            print_status("info", "Consider using anonymized identifiers")
            privacy_issues <- privacy_issues + 1
          }
        }
      }
    }, error = function(e) {
      # Skip if can't read roster
    })
  }
  
  if (privacy_issues == 0) {
    print_status("success", "No obvious privacy issues detected")
  } else {
    print_status("warning", paste(privacy_issues, "potential privacy issue(s) found"))
  }
  
  return(privacy_issues == 0)
}

# Main validation function
main <- function() {
  cat("🔍 Data Validation for Real-World Testing\n")
  cat("========================================\n\n")
  
  # Check if we're in the right directory
  if (!file_exists("run_real_world_tests.R")) {
    print_status("error", "Please run this script from the real-world testing directory")
    print_status("info", "Expected to find: run_real_world_tests.R")
    return(1)
  }
  
  # Run validations
  transcript_valid <- validate_transcripts()
  roster_valid <- validate_roster()
  metadata_valid <- validate_session_metadata()
  privacy_ok <- check_data_privacy()
  
  cat("\n📊 Validation Summary\n")
  cat("===================\n")
  
  print_status(ifelse(transcript_valid, "success", "error"), "Transcript files")
  print_status(ifelse(roster_valid, "success", "error"), "Roster data")
  print_status(ifelse(metadata_valid, "success", "error"), "Session metadata")
  print_status(ifelse(privacy_ok, "success", "warning"), "Data privacy")
  
  # Overall assessment
  all_valid <- transcript_valid && roster_valid && metadata_valid && privacy_ok
  
  cat("\n")
  if (all_valid) {
    print_status("success", "✅ All validations passed! Ready to run tests.")
    print_status("info", "Run: ./run_tests.sh")
  } else {
    print_status("error", "❌ Some validations failed. Please address issues before running tests.")
    print_status("info", "Check the warnings and errors above")
  }
  
  return(ifelse(all_valid, 0, 1))
}

# Run if called directly
if (!interactive()) {
  quit(status = main())
} 