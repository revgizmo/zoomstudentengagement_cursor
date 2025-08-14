#' Analyze Multi-Session Attendance Patterns
#'
#' Analyzes attendance patterns across multiple Zoom sessions, tracking who attended
#' which sessions and identifying participation patterns while maintaining privacy compliance.
#'
#' @param transcript_files Character vector of transcript file paths
#' @param roster_data Data frame containing student roster information
#' @param data_folder Path to the data folder containing transcripts
#' @param transcripts_folder Name of the transcripts subfolder (default: "transcripts")
#' @param unmatched_names_action Action for unmatched names: "stop" (default) or "warn"
#' @param privacy_level Privacy level for output masking: "ferpa_strict", "ferpa_standard", "mask", "none"
#' @param min_attendance_threshold Minimum attendance percentage to be considered a "consistent attendee" (default: 0.5)
#'
#' @return A list containing:
#'   - `attendance_matrix`: Data frame with participants as rows and sessions as columns
#'   - `attendance_summary`: Summary statistics for each participant
#'   - `session_summary`: Summary statistics for each session
#'   - `participation_patterns`: Analysis of participation patterns
#'   - `privacy_compliant`: Boolean indicating if all outputs maintain privacy
#'
#' @examples
#' \dontrun{
#' # Analyze attendance across multiple sessions
#' transcript_files <- c("session1.vtt", "session2.vtt", "session3.vtt")
#' roster_data <- load_roster(data_folder = "data/metadata", roster_file = "roster.csv")
#'
#' results <- analyze_multi_session_attendance(
#'   transcript_files = transcript_files,
#'   roster_data = roster_data,
#'   data_folder = "data",
#'   unmatched_names_action = "warn"
#' )
#'
#' # View attendance summary
#' print(results$attendance_summary)
#' }
#'
#' @export
analyze_multi_session_attendance <- function(
    transcript_files,
    roster_data,
    data_folder = "data",
    transcripts_folder = "transcripts",
    unmatched_names_action = c("stop", "warn"),
    privacy_level = c("ferpa_strict", "ferpa_standard", "mask", "none"),
    min_attendance_threshold = 0.5) {
  # Validate inputs
  unmatched_names_action <- match.arg(unmatched_names_action)
  privacy_level <- match.arg(privacy_level)

  if (length(transcript_files) < 2) {
    stop("At least 2 transcript files are required for multi-session analysis")
  }

  if (!is.data.frame(roster_data) || nrow(roster_data) == 0) {
    stop("roster_data must be a non-empty data frame")
  }

  if (min_attendance_threshold < 0 || min_attendance_threshold > 1) {
    stop("min_attendance_threshold must be between 0 and 1")
  }

  # Set privacy defaults
  set_privacy_defaults(
    privacy_level = privacy_level,
    unmatched_names_action = unmatched_names_action
  )

  # Initialize tracking variables
  session_attendance <- list()
  session_metrics <- list()
  all_participants <- character(0)
  session_names <- character(0)

  # Process each session
  for (i in seq_along(transcript_files)) {
    transcript_file <- transcript_files[i]

    # Construct full path if needed
    if (!file.exists(transcript_file)) {
      full_path <- file.path(data_folder, transcripts_folder, transcript_file)
      if (!file.exists(full_path)) {
        warning(sprintf("Transcript file not found: %s", transcript_file))
        next
      }
      transcript_file <- full_path
    }

    session_name <- tools::file_path_sans_ext(basename(transcript_file))
    session_names[i] <- session_name

    # Process transcript with privacy-aware name matching
    tryCatch(
      {
        # Load transcript data first
        transcript_data <- load_zoom_transcript(transcript_file)

        # Process with privacy-aware name matching
        session_data <- process_transcript_with_privacy(
          transcript_data = transcript_data,
          roster_data = roster_data
        )

        # Extract participants for this session
        session_participants <- unique(session_data$name)
        session_attendance[[session_name]] <- session_participants
        all_participants <- unique(c(all_participants, session_participants))

        # Calculate session metrics
        session_metrics[[session_name]] <- summarize_transcript_metrics(
          transcript_file_path = transcript_file,
          names_exclude = c("dead_air")
        )
      },
      error = function(e) {
        warning(sprintf("Error processing session %s: %s", session_name, e$message))
      }
    )
  }

  if (length(all_participants) == 0) {
    stop("No participants found across all sessions")
  }

  # Create attendance matrix
  attendance_matrix <- data.frame(
    participant = all_participants,
    stringsAsFactors = FALSE
  )

  for (session_name in names(session_attendance)) {
    attendance_matrix[[session_name]] <- all_participants %in% session_attendance[[session_name]]
  }

  # Calculate attendance statistics
  total_sessions <- length(session_attendance)
  attendance_counts <- rowSums(attendance_matrix[, -1, drop = FALSE])
  attendance_rates <- attendance_counts / total_sessions

  # Create attendance summary
  attendance_summary <- data.frame(
    participant = all_participants,
    total_sessions = attendance_counts,
    attendance_rate = round(attendance_rates * 100, 1),
    is_consistent_attendee = attendance_rates >= min_attendance_threshold,
    is_one_time_attendee = attendance_counts == 1,
    stringsAsFactors = FALSE
  )

  # Create session summary
  session_summary <- data.frame(
    session = names(session_attendance),
    participants = sapply(session_attendance, length),
    stringsAsFactors = FALSE
  )

  # Analyze participation patterns
  consistent_attendees <- all_participants[attendance_rates >= min_attendance_threshold]
  one_time_attendees <- all_participants[attendance_counts == 1]
  occasional_attendees <- all_participants[attendance_counts > 1 & attendance_rates < min_attendance_threshold]

  participation_patterns <- list(
    total_participants = length(all_participants),
    total_sessions = total_sessions,
    consistent_attendees = length(consistent_attendees),
    occasional_attendees = length(occasional_attendees),
    one_time_attendees = length(one_time_attendees),
    average_attendance_rate = round(mean(attendance_rates) * 100, 1),
    median_attendance_rate = round(stats::median(attendance_rates) * 100, 1),
    attendance_rate_std = round(stats::sd(attendance_rates) * 100, 1)
  )

  # Validate privacy compliance
  privacy_compliant <- TRUE
  tryCatch(
    {
      validate_privacy_compliance(attendance_summary, privacy_level = privacy_level)
      validate_privacy_compliance(session_summary, privacy_level = privacy_level)
    },
    error = function(e) {
      privacy_compliant <<- FALSE
      warning(sprintf("Privacy violation detected: %s", e$message))
    }
  )

  # Return results
  result <- list(
    attendance_matrix = attendance_matrix,
    attendance_summary = attendance_summary,
    session_summary = session_summary,
    participation_patterns = participation_patterns,
    privacy_compliant = privacy_compliant,
    session_metrics = session_metrics
  )

  # Add privacy masking to sensitive data
  if (privacy_level != "none") {
    result$attendance_matrix <- ensure_privacy(result$attendance_matrix, privacy_level = privacy_level)
    result$attendance_summary <- ensure_privacy(result$attendance_summary, privacy_level = privacy_level)
    result$session_summary <- ensure_privacy(result$session_summary, privacy_level = privacy_level)
  }

  return(result)
}

#' Generate Multi-Session Attendance Report
#'
#' Creates a comprehensive report of multi-session attendance analysis.
#'
#' @param analysis_results Results from `analyze_multi_session_attendance()`
#' @param output_file Path to save the report (optional)
#' @param include_charts Whether to include attendance charts (requires ggplot2)
#'
#' @return Character vector containing the report content
#'
#' @examples
#' \dontrun{
#' results <- analyze_multi_session_attendance(transcript_files, roster_data)
#' report <- generate_attendance_report(results, "attendance_report.md")
#' }
#'
#' @export
generate_attendance_report <- function(
    analysis_results,
    output_file = NULL,
    include_charts = FALSE) {
  if (!is.list(analysis_results) || !"participation_patterns" %in% names(analysis_results)) {
    stop("analysis_results must be the output from analyze_multi_session_attendance()")
  }

  patterns <- analysis_results$participation_patterns
  summary <- analysis_results$attendance_summary

  # Generate report content
  report_content <- c(
    "# Multi-Session Attendance Analysis Report",
    "",
    paste("**Generated**:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    paste("**Sessions Analyzed**:", patterns$total_sessions),
    paste("**Total Participants**:", patterns$total_participants),
    "",
    "## Participation Summary",
    "",
    paste("- **Consistent Attendees** (>=", patterns$total_sessions * 0.5, "sessions):", patterns$consistent_attendees),
    paste("- **Occasional Attendees** (2-", ceiling(patterns$total_sessions * 0.5) - 1, "sessions):", patterns$occasional_attendees),
    paste("- **One-time Attendees**:", patterns$one_time_attendees),
    "",
    "## Attendance Statistics",
    "",
    paste("- **Average Attendance Rate**:", patterns$average_attendance_rate, "%"),
    paste("- **Median Attendance Rate**:", patterns$median_attendance_rate, "%"),
    paste("- **Attendance Rate Std Dev**:", patterns$attendance_rate_std, "%"),
    "",
    "## Privacy Compliance",
    "",
    if (analysis_results$privacy_compliant) "[PASS] All outputs maintain privacy compliance" else "[FAIL] Privacy violations detected",
    ""
  )

  # Add attendance matrix if privacy allows
  if (analysis_results$privacy_compliant) {
    report_content <- c(
      report_content,
      "## Attendance Matrix",
      "",
      "| Participant | Sessions Attended | Attendance Rate |",
      "|-------------|-------------------|-----------------|"
    )

    for (i in seq_len(min(10, nrow(summary)))) { # Limit to first 10 for report
      row <- summary[i, ]
      report_content <- c(
        report_content,
        sprintf(
          "| %s | %d | %.1f%% |",
          row$participant,
          row$total_sessions,
          row$attendance_rate
        )
      )
    }

    if (nrow(summary) > 10) {
      report_content <- c(report_content, "| ... | ... | ... |")
    }
  }

  # Save report if output file specified
  if (!is.null(output_file)) {
    writeLines(report_content, output_file)
  }

  return(report_content)
}
