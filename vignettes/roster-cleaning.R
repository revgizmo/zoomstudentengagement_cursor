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
# Load transcript metrics
transcript_file <- system.file(
  "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
  package = "zoomstudentengagement"
)

transcripts_metrics_df <- summarize_transcript_metrics(
  transcript_file_path = transcript_file,
  names_exclude = c("dead_air")
)

# View transcript metrics
head(transcripts_metrics_df)

