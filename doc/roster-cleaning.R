## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)

## ----setup--------------------------------------------------------------------
library(zoomstudentengagement)
library(dplyr)
library(ggplot2)

## ----load-roster--------------------------------------------------------------
# Load the sample roster
data_folder <- system.file("extdata", package = "zoomstudentengagement")

roster_df <- load_roster(
  data_folder = data_folder,
  roster_file = "roster.csv"
)

# View the roster structure
head(roster_df)

## ----sections-----------------------------------------------------------------
# Create sections summary
sections_df <- make_sections_df(roster_df)

# View sections
sections_df

## ----roster-small-------------------------------------------------------------
# Create simplified roster
roster_small_df <- make_roster_small(roster_df)

# View simplified roster
head(roster_small_df)

## ----load-transcripts---------------------------------------------------------
# Create sample transcript metrics for demonstration
# In practice, you would use summarize_transcript_metrics() on actual transcript files
transcripts_metrics_df <- tibble::tibble(
  name = c("Conor Healy", "Dr. Melissa Ko", "Ryan Sloan"),
  n = c(15, 8, 12),
  duration = c(45.2, 23.1, 38.7),
  wordcount = c(1200, 650, 950),
  comments = list("Good discussion", "Excellent points", "Interesting question"),
  n_perc = c(25.0, 13.3, 20.0),
  duration_perc = c(25.0, 13.3, 20.0),
  wordcount_perc = c(25.0, 13.3, 20.0),
  wpm = c(26.5, 28.1, 24.6),
  course_section = "23.24",
  course = 23,
  section = 24,
  day = "Thursday",
  time = "18:30",
  name_raw = name,
  start_time_local = as.POSIXct("2024-01-24 18:30:00", tz = "America/Los_Angeles"),
  dept = "LTF",
  session_num = 1
)

# View transcript metrics
head(transcripts_metrics_df)

## ----session-roster-----------------------------------------------------------
# Create a simplified session mapping for demonstration
# In practice, you would use the full data loading functions
transcripts_list_df <- tibble::tibble(
  dept = "LTF",
  course = 23,
  section = 24,
  session_num = 1,
  start_time_local = as.POSIXct("2024-01-24 18:30:00", tz = "America/Los_Angeles"),
  course_section = "23.24"
)

# Create roster sessions
roster_sessions <- make_student_roster_sessions(
  transcripts_list_df,
  roster_small_df
)

# View roster sessions
head(roster_sessions)

## ----initial-matching---------------------------------------------------------
# Create clean names dataframe
clean_names_df <- make_clean_names_df(
  data_folder = data_folder,
  section_names_lookup_file = "section_names_lookup.csv",
  transcripts_metrics_df,
  roster_sessions
)

# View initial matching results
head(clean_names_df)

## ----names-to-clean-----------------------------------------------------------
# Find names that need cleaning
names_to_clean <- make_names_to_clean_df(clean_names_df)

# View names needing attention
names_to_clean

## ----write-lookup-------------------------------------------------------------
# Write section names lookup
write_section_names_lookup(
  clean_names_df,
  data_folder = data_folder,
  section_names_lookup_file = "section_names_lookup.csv"
)

## ----preferred-names----------------------------------------------------------
# Check if roster has preferred names
if ("preferred_name" %in% colnames(roster_df)) {
  cat("Roster includes preferred names\n")
  head(roster_df[, c("first_last", "preferred_name")])
} else {
  cat("Roster uses formal names only\n")
}

## ----special-cases------------------------------------------------------------
# Example: Mark guest speakers
# In the lookup file, set:
# transcript_name: "Guest Speaker"
# preferred_name: "Guest"
# formal_name: "Guest Speaker"
# student_id: "GUEST001"
# section: "LTF.201.1"

## ----validation---------------------------------------------------------------
# After cleaning, check results
final_clean_names <- make_clean_names_df(
  data_folder = data_folder,
  section_names_lookup_file = "section_names_lookup.csv",
  transcripts_metrics_df,
  roster_sessions
)

# Check for any remaining unmatched names
remaining_unmatched <- make_names_to_clean_df(final_clean_names)
if (nrow(remaining_unmatched) == 0) {
  cat("All names successfully matched!\n")
} else {
  cat("Still have", nrow(remaining_unmatched), "names to clean\n")
}

