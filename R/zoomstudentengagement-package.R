#' Zoom Student Engagement
#'
#' Takes Zoom transcripts and student rosters, converts them for analysis, and analyzes the results for student engagement, with a particular focus on participation equity.
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
    "start_time_local", "student_id", "transcript_name", "transcript_section",
    "wordcount", "wordcount_perc", "wpm", "course_num",

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
    "comment", "duration", "name", "raw_end", "raw_start", "wordcount",

    # Variables from make_transcripts_summary_df.R
    "avg_duration", "avg_wordcount", "max_duration", "max_wordcount",
    "min_duration", "min_wordcount", "total_comments", "total_duration",
    "total_wordcount",

    # Variables from summarize_transcript_metrics.R
    "avg_duration", "avg_wordcount", "max_duration", "max_wordcount",
    "min_duration", "min_wordcount", "total_comments", "total_duration",
    "total_wordcount",

    # Variables from make_names_to_clean_df.R
    "course", "course_section",

    # Variables from make_sections_df.R
    "dept", "course", "section", "n",

    # Variables from make_students_only_transcripts_summary_df.R
    "section",

    # Variables from mask_user_names_by_metric.R
    "row_num", "preferred_name", "section",

    # Variables from make_student_roster_sessions.R
    "start_time_local", "student_id", "transcript_section",

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
