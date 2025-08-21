# Test Script for zoomstudentengagement Package
# Using the provided test transcript examples

# Load the package
library(zoomstudentengagement)

# Set the path to test transcripts
test_dir <- system.file("extdata", "test_transcripts", package = "zoomstudentengagement")

# List available test files
test_files <- list.files(test_dir, pattern = "\\.vtt$", full.names = TRUE)
cat("Available test transcripts:\n")
cat(paste("-", basename(test_files), collapse = "\n"), "\n\n")

# Example 1: Basic transcript analysis
cat("=== Example 1: Basic Transcript Analysis ===\n")
stats_week1 <- file.path(test_dir, "intro_statistics_week1.vtt")

# Parse the transcript
transcript_data <- parse_zoom_transcript(stats_week1)
cat("Transcript parsed successfully\n")
cat("Number of entries:", nrow(transcript_data), "\n")
cat("Speakers:", unique(transcript_data$speaker), "\n\n")

# Example 2: Participation analysis
cat("=== Example 2: Participation Analysis ===\n")
participation <- analyze_participation(transcript_data)
print(participation)

# Example 3: Multi-session comparison
cat("\n=== Example 3: Multi-Session Comparison ===\n")
stats_week1 <- file.path(test_dir, "intro_statistics_week1.vtt")
stats_week2 <- file.path(test_dir, "intro_statistics_week2.vtt")

# Analyze both sessions
session1_data <- parse_zoom_transcript(stats_week1)
session2_data <- parse_zoom_transcript(stats_week2)

session1_participation <- analyze_participation(session1_data)
session2_participation <- analyze_participation(session2_data)

cat("Week 1 Participation:\n")
print(session1_participation)
cat("\nWeek 2 Participation:\n")
print(session2_participation)

# Example 4: Different course types
cat("\n=== Example 4: Course Type Comparison ===\n")
cs_file <- file.path(test_dir, "computer_science_101_week1.vtt")
english_file <- file.path(test_dir, "english_literature_discussion.vtt")

cs_data <- parse_zoom_transcript(cs_file)
english_data <- parse_zoom_transcript(english_file)

cs_participation <- analyze_participation(cs_data)
english_participation <- analyze_participation(english_data)

cat("Computer Science Participation:\n")
print(cs_participation)
cat("\nEnglish Literature Participation:\n")
print(english_participation)

# Example 5: Engagement metrics
cat("\n=== Example 5: Engagement Metrics ===\n")
engagement_stats <- analyze_engagement(transcript_data)
print(engagement_stats)

# Example 6: Question analysis
cat("\n=== Example 6: Question Analysis ===\n")
questions <- extract_questions(transcript_data)
cat("Number of questions found:", nrow(questions), "\n")
if (nrow(questions) > 0) {
  cat("Sample questions:\n")
  print(head(questions, 3))
}

# Example 7: Privacy anonymization
cat("\n=== Example 7: Privacy Anonymization ===\n")
anonymized_data <- anonymize_transcript(transcript_data)
cat("Original speakers:", unique(transcript_data$speaker), "\n")
cat("Anonymized speakers:", unique(anonymized_data$speaker), "\n")

# Example 8: Batch processing multiple transcripts
cat("\n=== Example 8: Batch Processing ===\n")
all_transcripts <- lapply(test_files, function(file) {
  data <- parse_zoom_transcript(file)
  data$file <- basename(file)
  return(data)
})

# Combine all transcripts
combined_data <- do.call(rbind, all_transcripts)
cat("Total entries across all transcripts:", nrow(combined_data), "\n")
cat("Files processed:", length(test_files), "\n")

# Example 9: Generate summary report
cat("\n=== Example 9: Summary Report ===\n")
summary_report <- generate_engagement_report(transcript_data)
cat("Report generated successfully\n")
cat("Report length:", nchar(summary_report), "characters\n")

# Example 10: Export results
cat("\n=== Example 10: Export Results ===\n")
# Create output directory for results
output_dir <- tempdir()
cat("Results will be saved to:", output_dir, "\n")

# Export participation data
write.csv(participation, file.path(output_dir, "participation_analysis.csv"), row.names = FALSE)
cat("Participation data exported\n")

# Export engagement report
writeLines(summary_report, file.path(output_dir, "engagement_report.txt"))
cat("Engagement report exported\n")

cat("\n=== Test Complete ===\n")
cat("All test transcripts processed successfully!\n")