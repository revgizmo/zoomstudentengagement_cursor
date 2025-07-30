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

## ----course-info--------------------------------------------------------------
# Create course information for multiple courses
course_info <- create_course_info(
  dept = c("CS", "CS", "MATH", "LTF"),
  course = c("101", "101", "250", "201"),
  section = c(1, 2, 1, 1),
  instructor = c("Dr. Smith", "Dr. Smith", "Dr. Johnson", "Dr. Smith"),
  session_length_hours = c(1.5, 1.5, 2.0, 1.5),
  session_days = c("Mon", "Wed", "Tue", "Thu"),
  session_times = c("10:00", "14:00", "09:00", "15:00")
)

# View course information
course_info

## ----config-------------------------------------------------------------------
# Create configuration with session mapping
config <- create_analysis_config(
  dept = "CS", # Primary department (can be overridden by mapping)
  semester_start_mdy = "Jan 15, 2024",
  scheduled_session_length_hours = 1.5,
  instructor_name = "Dr. Smith",
  data_folder = system.file("extdata", package = "zoomstudentengagement"),
  transcripts_folder = "transcripts",
  names_to_exclude = c("dead_air"),
  use_session_mapping = TRUE,
  session_mapping_file = "session_mapping.csv"
)

# View configuration
cat("Session mapping enabled:", config$session_mapping$use_session_mapping, "\n")
cat("Session mapping file:", config$session_mapping$session_mapping_file, "\n")

## ----load-raw-----------------------------------------------------------------
# Load raw Zoom recordings (without regex parsing)
zoom_recordings_raw <- load_zoom_recorded_sessions_list(
  data_folder = config$paths$data_folder,
  transcripts_folder = config$paths$transcripts_folder,
  zoom_recorded_sessions_csv_names_pattern = config$patterns$zoom_recordings_csv,
  zoom_recorded_sessions_csv_col_names = config$patterns$zoom_recordings_csv_col_names,
  dept = NULL, # Don't filter by department initially
  semester_start_mdy = config$course$semester_start,
  scheduled_session_length_hours = config$course$session_length_hours
)

# View raw recordings
zoom_recordings_raw

## ----auto-assign--------------------------------------------------------------
# Create session mapping with automatic patterns
session_mapping <- create_session_mapping(
  zoom_recordings_df = zoom_recordings_raw,
  course_info_df = course_info,
  output_file = config$session_mapping$session_mapping_file,
  auto_assign_patterns = list(
    "CS 101" = "CS.*101",
    "MATH 250" = "MATH.*250",
    "LTF 201" = "LTF.*201"
  ),
  interactive = FALSE # Set to TRUE for interactive mode
)

# View session mapping
session_mapping

## ----interactive-assign, eval = FALSE-----------------------------------------
# # Interactive session mapping (commented out for vignette)
# # session_mapping_interactive <- create_session_mapping(
# #   zoom_recordings_df = zoom_recordings_raw,
# #   course_info_df = course_info,
# #   output_file = "session_mapping_interactive.csv",
# #   interactive = TRUE
# # )

## ----load-mapped--------------------------------------------------------------
# Load mapped recordings
zoom_recorded_sessions_df <- load_session_mapping(
  config$session_mapping$session_mapping_file,
  zoom_recordings_df = zoom_recordings_raw
)

# View mapped sessions
zoom_recorded_sessions_df

## ----step1--------------------------------------------------------------------
# Load transcript files
transcript_files_df <- load_transcript_files_list(
  data_folder = config$paths$data_folder,
  transcripts_folder = config$paths$transcripts_folder
)

transcript_files_df

## ----step2--------------------------------------------------------------------
# Load cancelled classes
cancelled_classes_df <- load_cancelled_classes(
  data_folder = config$paths$data_folder,
  cancelled_classes_file = config$paths$cancelled_classes_file,
  write_blank_cancelled_classes = TRUE
)

cancelled_classes_df

## ----step3--------------------------------------------------------------------
# Join all transcript data
transcripts_list_df <- join_transcripts_list(
  df_zoom_recorded_sessions = zoom_recorded_sessions_df,
  df_transcript_files = transcript_files_df,
  df_cancelled_classes = cancelled_classes_df
)

transcripts_list_df

## ----step4--------------------------------------------------------------------
# Process transcripts
transcripts_metrics_df <- summarize_transcript_files(
  transcript_file_names = transcripts_list_df,
  data_folder = config$paths$data_folder,
  transcripts_folder = config$paths$transcripts_folder,
  names_to_exclude = config$analysis$names_to_exclude
)

head(transcripts_metrics_df)

## ----custom-patterns----------------------------------------------------------
# Example of custom patterns
custom_patterns <- list(
  "CS 101 Section 1" = "CS.*101.*Section.*1|CS.*101.*Monday",
  "CS 101 Section 2" = "CS.*101.*Section.*2|CS.*101.*Wednesday",
  "MATH 250" = "MATH.*250|Mathematics.*250",
  "LTF 201" = "LTF.*201|Language.*201"
)

# Use custom patterns in session mapping
session_mapping_custom <- create_session_mapping(
  zoom_recordings_df = zoom_recordings_raw,
  course_info_df = course_info,
  output_file = "session_mapping_custom.csv",
  auto_assign_patterns = custom_patterns,
  interactive = FALSE
)

## ----manual-edit, eval = FALSE------------------------------------------------
# # The session mapping CSV file can be edited manually
# # Columns: recording_id, course_section, dept, course, section, instructor
# # Example:
# # recording_id,course_section,dept,course,section,instructor
# # GMT20240124-202901_Recording,CS.101.1,CS,101,1,Dr. Smith
# # GMT20240125-143000_Recording,CS.101.2,CS,101,2,Dr. Smith

## ----validation---------------------------------------------------------------
# Check mapping coverage
mapping_summary <- session_mapping %>%
  group_by(course_section) %>%
  summarise(
    recordings_count = n(),
    unique_recordings = n_distinct(recording_id)
  )

mapping_summary

# Check for unmapped recordings
unmapped <- zoom_recordings_raw %>%
  anti_join(session_mapping, by = c("ID" = "recording_id"))

if (nrow(unmapped) > 0) {
  cat("Unmapped recordings found:\n")
  print(unmapped$Topic)
} else {
  cat("All recordings mapped successfully!\n")
}

