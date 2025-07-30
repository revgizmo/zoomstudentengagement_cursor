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

