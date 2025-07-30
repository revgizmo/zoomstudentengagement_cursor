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

## ----eval = FALSE-------------------------------------------------------------
# devtools::install_github("revgizmo/zoomstudentengagement")

## ----quick-start--------------------------------------------------------------
# Load a sample transcript
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)

# Process the transcript
processed_transcript <- process_zoom_transcript(
  transcript_file_path = transcript_file,
  consolidate_comments = TRUE,
  add_dead_air = TRUE
)

# Calculate summary metrics
summary_metrics <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air")
)

# View the results
head(summary_metrics)

