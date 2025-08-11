#!/usr/bin/env Rscript

# Performance Test Data Generator for zoomstudentengagement
# Creates large datasets to test performance with 100MB+ transcript files

library(tibble)
library(hms)
library(lubridate)

# Function to create large transcript data
create_large_transcript_data <- function(n_rows = 100000, output_file = NULL) {
  cat("Creating large transcript dataset with", n_rows, "rows...\n")
  
  # Generate realistic transcript data
  speakers <- c("Student_A", "Student_B", "Student_C", "Instructor", "Student_D", "Student_E")
  comments <- c(
    "I think that's a great point about the methodology.",
    "Could you elaborate on that concept?",
    "I'm not sure I understand the relationship between these variables.",
    "Let me clarify the key differences here.",
    "That's an interesting perspective on the data.",
    "I agree with your analysis of the results.",
    "Can we discuss the implications of this finding?",
    "I'd like to explore this topic further.",
    "This reminds me of what we discussed earlier.",
    "I have a question about the methodology."
  )
  
  # Create timestamps
  start_times <- seq(as.POSIXct("2024-01-15 10:00:00"), 
                     by = "30 sec", 
                     length.out = n_rows)
  
  # Create data frame
  large_data <- tibble::tibble(
    transcript_file = rep("large_test_transcript.vtt", n_rows),
    comment_num = seq_len(n_rows),
    name = sample(speakers, n_rows, replace = TRUE),
    comment = sample(comments, n_rows, replace = TRUE),
    start = hms::as_hms(start_times),
    end = hms::as_hms(start_times + sample(30:120, n_rows, replace = TRUE)),
    duration = sample(30:120, n_rows, replace = TRUE),
    wordcount = sample(5:25, n_rows, replace = TRUE)
  )
  
  # Calculate actual durations
  large_data$duration <- as.numeric(large_data$end - large_data$start)
  
  cat("Created dataset with", nrow(large_data), "rows\n")
  cat("Estimated size:", format(object.size(large_data), units = "MB"), "\n")
  
  if (!is.null(output_file)) {
    saveRDS(large_data, output_file)
    cat("Saved to:", output_file, "\n")
  }
  
  return(large_data)
}

# Function to create large VTT file
create_large_vtt_file <- function(n_entries = 50000, output_file = "large_test_transcript.vtt") {
  cat("Creating large VTT file with", n_entries, "entries...\n")
  
  speakers <- c("Student_A", "Student_B", "Student_C", "Instructor", "Student_D", "Student_E")
  comments <- c(
    "I think that's a great point about the methodology.",
    "Could you elaborate on that concept?",
    "I'm not sure I understand the relationship between these variables.",
    "Let me clarify the key differences here.",
    "That's an interesting perspective on the data.",
    "I agree with your analysis of the results.",
    "Can we discuss the implications of this finding?",
    "I'd like to explore this topic further.",
    "This reminds me of what we discussed earlier.",
    "I have a question about the methodology."
  )
  
  # Create VTT content
  vtt_lines <- c("WEBVTT", "")
  
  start_time <- as.POSIXct("2024-01-15 10:00:00")
  
  for (i in 1:n_entries) {
    # Add entry number
    vtt_lines <- c(vtt_lines, as.character(i))
    
    # Add timestamp
    entry_start <- start_time + (i - 1) * 30
    entry_end <- entry_start + sample(30:120, 1)
    
    timestamp <- paste0(
      format(entry_start, "%H:%M:%S.000"),
      " --> ",
      format(entry_end, "%H:%M:%S.000")
    )
    vtt_lines <- c(vtt_lines, timestamp)
    
    # Add comment
    speaker <- sample(speakers, 1)
    comment <- sample(comments, 1)
    vtt_lines <- c(vtt_lines, paste0(speaker, ": ", comment))
    
    # Add blank line
    vtt_lines <- c(vtt_lines, "")
  }
  
  # Write to file
  writeLines(vtt_lines, output_file)
  
  file_size <- file.size(output_file)
  cat("Created VTT file:", output_file, "\n")
  cat("File size:", format(file_size, units = "MB"), "\n")
  
  return(output_file)
}

# Function to create performance test scenarios
create_performance_test_scenarios <- function() {
  cat("Creating performance test scenarios...\n")
  
  # Scenario 1: Medium dataset (10K rows)
  cat("\n=== Scenario 1: Medium Dataset (10K rows) ===\n")
  medium_data <- create_large_transcript_data(10000, "test_data_medium.rds")
  
  # Scenario 2: Large dataset (50K rows)
  cat("\n=== Scenario 2: Large Dataset (50K rows) ===\n")
  large_data <- create_large_transcript_data(50000, "test_data_large.rds")
  
  # Scenario 3: Very large dataset (100K rows)
  cat("\n=== Scenario 3: Very Large Dataset (100K rows) ===\n")
  very_large_data <- create_large_transcript_data(100000, "test_data_very_large.rds")
  
  # Scenario 4: Large VTT file
  cat("\n=== Scenario 4: Large VTT File ===\n")
  vtt_file <- create_large_vtt_file(50000, "large_test_transcript.vtt")
  
  cat("\n=== Performance Test Data Creation Complete ===\n")
  cat("Created files:\n")
  cat("- test_data_medium.rds (10K rows)\n")
  cat("- test_data_large.rds (50K rows)\n")
  cat("- test_data_very_large.rds (100K rows)\n")
  cat("- large_test_transcript.vtt (50K entries)\n")
  
  return(list(
    medium = medium_data,
    large = large_data,
    very_large = very_large_data,
    vtt_file = vtt_file
  ))
}

# Main execution
if (!interactive()) {
  cat("=== Performance Test Data Generator ===\n")
  scenarios <- create_performance_test_scenarios()
  cat("\nData generation complete!\n")
}
