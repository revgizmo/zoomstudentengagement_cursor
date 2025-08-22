#' Zoom Student Engagement Analysis Package
#'
#' @title Analyze Student Engagement from Zoom Transcripts
#' @description A comprehensive R package for analyzing student engagement and participation equity from Zoom meeting transcripts. This package provides tools for processing Zoom transcript files, matching student names with rosters, calculating engagement metrics, and generating privacy-aware visualizations and reports.
#'
#' @details
#' The zoomstudentengagement package is designed for educational researchers and instructors who want to analyze student participation patterns in online learning environments. The package prioritizes privacy and ethical considerations, with built-in data anonymization features and FERPA compliance tools.
#'
#' ## Key Features
#'
#' **Data Processing:**
#' - Load and process Zoom transcript files (VTT, TXT formats)
#' - Match student names with institutional rosters
#' - Handle name variations and privacy masking
#' - Consolidate multiple session transcripts
#'
#' **Engagement Analysis:**
#' - Calculate participation metrics (duration, word count, frequency)
#' - Analyze participation equity across student groups
#' - Generate session and multi-session summaries
#' - Identify participation patterns and trends
#'
#' **Privacy & Compliance:**
#' - Built-in data anonymization with `ensure_privacy()`
#' - FERPA compliance validation tools
#' - Privacy-first defaults for all outputs
#' - Secure data handling practices
#'
#' **Visualization & Reporting:**
#' - Create privacy-aware visualizations
#' - Generate engagement reports and metrics
#' - Export data in various formats
#' - Customizable plotting options
#'
#' ## Getting Started
#'
#' ```r
#' # Load the package
#' library(zoomstudentengagement)
#'
#' # Set privacy defaults (recommended)
#' set_privacy_defaults(privacy_level = "mask")
#'
#' # Load and process a transcript
#' transcript_data <- load_zoom_transcript("path/to/transcript.vtt")
#'
#' # Analyze engagement
#' results <- analyze_transcripts(transcript_data)
#'
#' # Create privacy-aware visualizations
#' plot_users(results)
#' ```
#'
#' ## Privacy-First Design
#'
#' This package is designed with privacy and ethical considerations at its core:
#' - **Default Privacy**: All functions default to masked outputs
#' - **FERPA Compliance**: Built-in tools for educational data protection
#' - **Data Anonymization**: Automatic name masking and data protection
#' - **Ethical Focus**: Emphasis on participation equity, not surveillance
#'
#' ## Educational Use Cases
#'
#' - **Participation Equity Analysis**: Identify and address participation gaps
#' - **Engagement Tracking**: Monitor student engagement over time
#' - **Intervention Planning**: Use data to inform teaching strategies
#' - **Research Studies**: Support educational research with privacy protection
#'
#' @seealso
#' \code{\link{analyze_transcripts}} for main analysis workflow
#' \code{\link{load_zoom_transcript}} for loading transcript data
#' \code{\link{ensure_privacy}} for privacy protection features
#' \code{\link{plot_users}} for creating visualizations
#' \code{\link{write_metrics}} for exporting results
#'
#' @examples
#' # Basic workflow example
#' \dontrun{
#' # Load and process transcript
#' transcript <- load_zoom_transcript("session_transcript.vtt")
#'
#' # Analyze with privacy protection
#' results <- analyze_transcripts(transcript)
#'
#' # Create privacy-aware visualization
#' plot_users(results)
#'
#' # Export results
#' write_metrics(results, "engagement_report.csv")
#' }
#'
#' @docType package
#' @name zoomstudentengagement
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom magrittr %>%
## usethis namespace: end

# CRAN compliance: suppress global variable notes for NSE/dplyr pipelines
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    # Variables from add_dead_air_rows.R
    ".", "comment_num", "end", "prev_end", "prior_dead_air", "start",

    # Variables from load_zoom_recorded_sessions_list.R
    "Total Downloads", "Last Accessed", "match_start_time", "matches",
    "course_section", "course", "section", "day", "time", "instructor", "match_end_time",
    "topic_matches", "section_combined",

    # Variables from make_clean_names_df.R
    "comments", "dept", "duration", "duration_perc", "first_last", "formal_name",
    "n", "n_perc", "name", "name_raw", "preferred_name", "session_num",
    "start_time_local", "student_id", "transcript_name", "course_section",
    "wordcount", "wordcount_perc", "wpm",

    # Variables from load_transcript_files_list.R
    "file_name", "recording_start", "file_type",

    # Variables from load_zoom_transcript.R
    "timestamp", "name_flag", "time_flag", "prior_speaker",

    # Variables from summarize_transcript_files.R
    "transcript_file", "transcript_path",

    # Variables from plot_users_by_metric.R
    ".data", "description",

    # Variables from write_section_names_lookup.R
    "course",

    # Variables from load_section_names_lookup.R
    "preferred_name", "section", "student_id",

    # Variables from consolidate_transcript.R
    "comment", "duration", "name", "raw_end", "raw_start", "wordcount", "transcript_file",

    # Variables from make_transcripts_summary_df.R
    "avg_duration", "avg_wordcount", "max_duration", "max_wordcount",
    "min_duration", "min_wordcount", "total_comments", "total_duration",
    "total_wordcount",

    # Variables from summarize_transcript_metrics.R
    "avg_duration", "avg_wordcount", "max_duration", "max_wordcount",
    "min_duration", "min_wordcount", "total_comments", "total_duration",
    "total_wordcount", "transcript_file",

    # Variables from make_names_to_clean_df.R
    "course", "course_section",

    # Variables from make_sections_df.R
    "dept", "course", "section", "n",

    # Variables from make_students_only_transcripts_summary_df.R
    "section",

    # Variables from mask_user_names_by_metric.R
    "row_num", "preferred_name", "section",

    # Variables from make_student_roster_sessions.R
    "start_time_local", "student_id", "course_section",

    # Variables from join_transcripts_list.R
    "filepath", "transcript_file", "transcript_path",

    # Variables from plot_users_masked_section_by_metric.R
    "preferred_name", "section",

    # Variables from make_blank_cancelled_classes_df.R
    "date_extract", "transcript_file", "chat_file", "closed_caption_file",
    "match_start_time", "match_end_time", "recording_start"
  ))
}

NULL

#' @keywords internal
.onLoad <- function(libname, pkgname) {
  # Set privacy option to mask by default if user has not set it
  current <- getOption("zoomstudentengagement.privacy_level", default = NULL)
  if (is.null(current)) {
    options(zoomstudentengagement.privacy_level = "mask")
  }
  # Ensure verbose option is initialized to FALSE if not set
  if (is.null(getOption("zoomstudentengagement.verbose", default = NULL))) {
    options(zoomstudentengagement.verbose = FALSE)
  }
}
