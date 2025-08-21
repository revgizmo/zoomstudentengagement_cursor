# Simplified Manual Workflow Test
# This script tests the key components of the manual workflow

# Load required libraries
suppressPackageStartupMessages({
  library(zoomstudentengagement)
  library(dplyr)
  library(readr)
  library(ggplot2)
})

cat("=== Testing Manual Workflow Components ===\n")

# Step 1: Load test data
cat("Step 1: Loading test data...\n")
transcript_file <- "data/transcripts/GMT20240124-202901_Recording.transcript.vtt"
roster_file <- "data/metadata/roster.csv"

if (!file.exists(transcript_file)) {
  stop("Transcript file not found: ", transcript_file)
}

if (!file.exists(roster_file)) {
  stop("Roster file not found: ", roster_file)
}

# Load transcript
transcript_data <- load_zoom_transcript(transcript_file)
cat("  ✓ Transcript loaded:", nrow(transcript_data), "entries\n")

# Load roster
roster_data <- load_roster(data_folder = "data/metadata", roster_file = "roster.csv")
cat("  ✓ Roster loaded:", nrow(roster_data), "entries\n")

# Step 2: Calculate metrics
cat("Step 2: Calculating metrics...\n")
metrics <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air")
)
cat("  ✓ Metrics calculated:", nrow(metrics), "participants\n")

# Step 3: Test privacy levels
cat("Step 3: Testing privacy levels...\n")
privacy_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")

for (level in privacy_levels) {
  cat("  Testing privacy level:", level, "\n")
  set_privacy_defaults(level)
  
  # Recalculate metrics with privacy
  privacy_metrics <- summarize_transcript_metrics(
    transcript_file_path = transcript_file,
    names_exclude = c("dead_air")
  )
  
  cat("    ✓ Metrics calculated with", level, "privacy\n")
}

# Step 4: Test visualization
cat("Step 4: Testing visualization...\n")
tryCatch({
  # Create a simple plot
  p <- plot_users_by_metric(
    metrics_data = metrics,
    metric = "perc_messages",
    privacy_level = "mask"
  )
  cat("  ✓ Plot created successfully\n")
}, error = function(e) {
  cat("  ✗ Plot creation failed:", e$message, "\n")
})

# Step 5: Test export functionality
cat("Step 5: Testing export functionality...\n")

# Create output directory
if (!dir.exists("reports")) {
  dir.create("reports")
}

# Test write_metrics with different data types
tryCatch({
  # Test with metrics data
  if (is.data.frame(metrics)) {
    write_metrics(metrics, what = "engagement", path = "reports/test_metrics.csv")
    cat("  ✓ Metrics exported successfully\n")
  } else {
    cat("  ✗ Metrics is not a data frame\n")
  }
}, error = function(e) {
  cat("  ✗ Export failed:", e$message, "\n")
})

# Test write_transcripts_summary
tryCatch({
  write_transcripts_summary(
    transcript_file_path = transcript_file,
    output_path = "reports/test_summary.csv"
  )
  cat("  ✓ Summary exported successfully\n")
}, error = function(e) {
  cat("  ✗ Summary export failed:", e$message, "\n")
})

# Step 6: Test privacy validation
cat("Step 6: Testing privacy validation...\n")
tryCatch({
  if (exists("validate_privacy_compliance")) {
    validate_privacy_compliance(metrics, privacy_level = "ferpa_strict")
    cat("  ✓ Privacy validation passed\n")
  } else {
    cat("  ⚠️  Privacy validation function not available\n")
  }
}, error = function(e) {
  cat("  ✗ Privacy validation failed:", e$message, "\n")
})

cat("\n=== Manual Workflow Test Complete ===\n")
cat("Check the reports/ directory for output files\n")
