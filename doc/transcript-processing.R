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

## ----load-basic---------------------------------------------------------------
# Load a sample transcript
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)

# Load the raw transcript
raw_transcript <- load_zoom_transcript(transcript_file_path = transcript_file)

# View the structure
head(raw_transcript)

## ----process-transcript-------------------------------------------------------
# Process the transcript with options
processed_transcript <- process_zoom_transcript(
  transcript_file_path = transcript_file,
  consolidate_comments = TRUE,
  max_pause_sec = 1,
  add_dead_air = TRUE,
  dead_air_name = "dead_air",
  na_name = "unknown"
)

# View the processed transcript
head(processed_transcript)

## ----single-metrics-----------------------------------------------------------
# Calculate summary metrics
summary_metrics <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air"),
  consolidate_comments = TRUE,
  max_pause_sec = 1,
  add_dead_air = TRUE
)

# View the metrics
summary_metrics

## ----batch-processing---------------------------------------------------------
# Set up data folder path
data_folder <- system.file("extdata", package = "zoomstudentengagement")

# Process multiple transcripts
batch_metrics <- summarize_transcript_files(
  transcript_file_names = "GMT20240124-202901_Recording.transcript.vtt",
  data_folder = data_folder,
  transcripts_folder = "transcripts",
  names_to_exclude = c("dead_air"),
  deduplicate_content = FALSE
)

# View batch results
head(batch_metrics)

## ----file-list----------------------------------------------------------------
# Load transcript files list
transcript_files <- load_transcript_files_list(
  data_folder = data_folder,
  transcripts_folder = "transcripts"
)

# View the file list
transcript_files

## ----recordings-list----------------------------------------------------------
# Load Zoom recordings list
recordings_list <- load_zoom_recorded_sessions_list(
  data_folder = data_folder,
  transcripts_folder = "transcripts",
  dept = "LTF",
  semester_start_mdy = "Jan 01, 2024",
  scheduled_session_length_hours = 1.5
)

# View the recordings list
recordings_list

## ----deduplication------------------------------------------------------------
# Process with content deduplication
deduplicated_metrics <- summarize_transcript_files(
  transcript_file_names = "GMT20240124-202901_Recording.transcript.vtt",
  data_folder = data_folder,
  transcripts_folder = "transcripts",
  deduplicate_content = TRUE,
  similarity_threshold = 0.95,
  duplicate_method = "hybrid"
)

# View deduplicated results
head(deduplicated_metrics)

## ----custom-params------------------------------------------------------------
# Custom processing with specific parameters
custom_processed <- process_zoom_transcript(
  transcript_file_path = transcript_file,
  consolidate_comments = TRUE,
  max_pause_sec = 2, # Longer pause threshold
  add_dead_air = TRUE,
  dead_air_name = "silence",
  na_name = "unidentified"
)

# View custom processed transcript
head(custom_processed)

