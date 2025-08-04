## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6
)

## ----load-packages------------------------------------------------------------
library(zoomstudentengagement)
library(dplyr)
library(ggplot2)
library(readr)
library(tibble)

## ----explore-data-------------------------------------------------------------
# Check what transcript files are available (specifically .transcript.vtt files)
transcript_files <- list.files(
  system.file("extdata/transcripts", package = "zoomstudentengagement"),
  pattern = "\\.transcript\\.vtt$",
  full.names = TRUE
)

cat("Available transcript files:\n")
basename(transcript_files)

# Check what other data files are available
cat("\nAvailable data files:\n")
list.files(system.file("extdata", package = "zoomstudentengagement"))

## ----load-roster--------------------------------------------------------------
# Load the student roster
roster <- load_roster(
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  roster_file = "roster.csv"
)

# View the roster structure
head(roster)
cat("\nRoster dimensions:", nrow(roster), "students\n")

## ----load-transcripts---------------------------------------------------------
# Load a single transcript to see the structure
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)

# Load and process the transcript
transcript_data <- load_zoom_transcript(transcript_file)

# View the structure
head(transcript_data)
cat("\nTranscript dimensions:", nrow(transcript_data), "utterances\n")

## ----process-multiple---------------------------------------------------------
# Get all transcript files (specifically .transcript.vtt files)
transcript_files <- list.files(
  system.file("extdata/transcripts", package = "zoomstudentengagement"),
  pattern = "\\.transcript\\.vtt$",
  full.names = TRUE
)

# Process all transcripts
all_transcripts <- lapply(transcript_files, function(file) {
  cat("Processing:", basename(file), "\n")
  load_zoom_transcript(file)
})

# Combine all transcripts
combined_transcripts <- dplyr::bind_rows(all_transcripts, .id = "session")

cat("\nCombined data dimensions:", nrow(combined_transcripts), "utterances\n")

## ----calculate-metrics--------------------------------------------------------
# Calculate metrics for all transcript files
metrics <- summarize_transcript_files(
  transcript_file_names = basename(transcript_files),
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  transcripts_folder = "transcripts",
  names_to_exclude = c("dead_air", "Unknown")
)

# View the metrics
head(metrics)

## ----name-matching------------------------------------------------------------
# First, let's see what names appear in the transcripts
transcript_names <- unique(metrics$name)
cat("Names in transcripts:\n")
print(transcript_names)

# Compare with roster names
roster_names <- unique(roster$preferred_name)
cat("\nNames in roster:\n")
print(roster_names)

# For this example, let's create a simple manual mapping
# In practice, you would use the more advanced name matching functions
name_mapping <- data.frame(
  name_to_clean = transcript_names,
  clean_name = ifelse(transcript_names %in% roster_names, transcript_names, NA_character_),
  stringsAsFactors = FALSE
)

# View the mapping
print(name_mapping)

## ----preferred-names----------------------------------------------------------
# Identify names that need manual mapping
unmatched_names <- name_mapping %>%
  filter(is.na(clean_name)) %>%
  pull(name_to_clean)

cat("Names needing manual mapping:\n")
print(unmatched_names)

# For this example, let's create some manual mappings
manual_mappings <- data.frame(
  name_to_clean = c("Bob", "Sally", "Mike"),
  clean_name = c("Robert Smith", "Sarah Johnson", "Michael Brown"),
  notes = c("Uses nickname", "Preferred name", "Uses nickname"),
  stringsAsFactors = FALSE
)

# Update the name mapping
name_mapping <- bind_rows(
  name_mapping %>% filter(!is.na(clean_name)),
  manual_mappings
)

## ----clean-engagement---------------------------------------------------------
# Apply name mappings to metrics
clean_metrics <- metrics %>%
  left_join(name_mapping, by = c("name" = "name_to_clean")) %>%
  mutate(
    student_name = coalesce(clean_name, name),
    is_matched = !is.na(clean_name)
  )

# View the results
head(clean_metrics)

# Summary of matching success
matching_summary <- clean_metrics %>%
  group_by(is_matched) %>%
  summarise(
    count = n(),
    percentage = n() / nrow(clean_metrics) * 100
  )

print(matching_summary)

## ----analyze-patterns---------------------------------------------------------
# Create a summary by student
student_summary <- clean_metrics %>%
  group_by(student_name) %>%
  summarise(
    total_utterances = sum(n, na.rm = TRUE),
    total_duration = sum(duration, na.rm = TRUE),
    total_words = sum(wordcount, na.rm = TRUE),
    avg_words_per_minute = mean(wpm, na.rm = TRUE),
    participation_rate = total_utterances / nrow(clean_metrics) * 100
  ) %>%
  arrange(desc(total_utterances))

# View the summary
head(student_summary, 10)

## ----visualize-participation--------------------------------------------------
# Plot participation by utterance count
ggplot(student_summary, aes(x = reorder(student_name, total_utterances), y = total_utterances)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Student Participation by Utterance Count",
    x = "Student Name",
    y = "Number of Utterances"
  ) +
  theme_minimal()

# Plot participation by duration
ggplot(student_summary, aes(x = reorder(student_name, total_duration), y = total_duration / 60)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  coord_flip() +
  labs(
    title = "Student Participation by Speaking Time",
    x = "Student Name",
    y = "Speaking Time (minutes)"
  ) +
  theme_minimal()

## ----identify-gaps------------------------------------------------------------
# Identify students with low participation
low_participation <- student_summary %>%
  filter(total_utterances < median(total_utterances, na.rm = TRUE)) %>%
  arrange(total_utterances)

cat("Students with below-median participation:\n")
print(low_participation[, c("student_name", "total_utterances", "total_duration")])

# Calculate participation equity metrics
participation_stats <- student_summary %>%
  summarise(
    mean_utterances = mean(total_utterances, na.rm = TRUE),
    median_utterances = median(total_utterances, na.rm = TRUE),
    sd_utterances = sd(total_utterances, na.rm = TRUE),
    gini_coefficient = (2 * sum(rank(total_utterances) * total_utterances) /
      (n() * sum(total_utterances))) - (n() + 1) / n()
  )

cat("\nParticipation Statistics:\n")
print(participation_stats)

## ----actionable-insights------------------------------------------------------
# Create participation categories
participation_categories <- student_summary %>%
  mutate(
    participation_level = case_when(
      total_utterances >= quantile(total_utterances, 0.75, na.rm = TRUE) ~ "High",
      total_utterances >= quantile(total_utterances, 0.25, na.rm = TRUE) ~ "Medium",
      TRUE ~ "Low"
    )
  )

# Summary by participation level
level_summary <- participation_categories %>%
  group_by(participation_level) %>%
  summarise(
    count = n(),
    percentage = n() / nrow(participation_categories) * 100
  )

cat("Participation Level Distribution:\n")
print(level_summary)

# Recommendations based on analysis
cat("\n=== RECOMMENDATIONS FOR EQUITABLE PARTICIPATION ===\n")
cat("1. Students with low participation may benefit from:\n")
cat("   - Direct invitations to contribute\n")
cat("   - Smaller group discussions\n")
cat("   - Alternative participation methods (chat, polls)\n\n")

cat("2. Consider implementing:\n")
cat("   - Structured discussion protocols\n")
cat("   - Think-pair-share activities\n")
cat("   - Anonymous participation options\n\n")

cat("3. Monitor participation patterns over time to:\n")
cat("   - Track improvement in engagement\n")
cat("   - Identify effective interventions\n")
cat("   - Ensure all students feel included\n")

## ----save-analysis------------------------------------------------------------
# Save the clean metrics
write_csv(clean_metrics, "clean_engagement_metrics.csv")

# Save the student summary
write_csv(student_summary, "student_participation_summary.csv")

# Save the name mappings for future use
write_csv(name_mapping, "name_mappings.csv")

cat("Analysis files saved:\n")
cat("- clean_engagement_metrics.csv\n")
cat("- student_participation_summary.csv\n")
cat("- name_mappings.csv\n")

