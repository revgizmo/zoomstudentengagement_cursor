#' Join Transcripts Files Into a Single Tibble
#'
#' This function creates a tibble from the joining of the listing of session recordings loaded from the cloud recording csvs
#' (`df_zoom_recorded_sessions`), the list of transcript files
#' (`df_transcript_files`), and the list of cancelled classes
#' (`df_cancelled_classes`) into a single tibble
#'
#' @param df_zoom_recorded_sessions A tibble listing the session recordings
#'   loaded from the cloud recording csvs.
#' @param df_transcript_files A data.frame listing the transcript files from the
#'   zoom recordings loaded from the cloud recording csvs and transcripts.
#' @param df_cancelled_classes A tibble listing the cancelled class sessions for
#'   scheduled classes where a zoom recording is not expected.
#'
#' @return A tibble listing the the class sessions with corresponding transcript
#'   files or placeholders for cancelled classes.
#' @export
#'
#' @examples
#' \dontrun{
#' zoom_recorded_sessions_df <- load_zoom_recorded_sessions_list()
#' transcript_files_df <- load_transcript_files_list()
#' cancelled_classes_df <- load_cancelled_classes()
#'
#' join_transcripts_list(
#'   df_zoom_recorded_sessions = zoom_recorded_sessions_df,
#'   df_transcript_files = transcript_files_df,
#'   df_cancelled_classes = cancelled_classes_df
#' )
#' }
join_transcripts_list <- function(
    df_zoom_recorded_sessions,
    df_transcript_files,
    df_cancelled_classes) {
  match_start_time <- start_time_local <- match_end_time <- section <- NULL

  # Return empty tibble with correct structure if any input is invalid
  if (!tibble::is_tibble(df_zoom_recorded_sessions) ||
    !tibble::is_tibble(df_transcript_files) ||
    !tibble::is_tibble(df_cancelled_classes)) {
    return(tibble::tibble(
      section = character(),
      match_start_time = as.POSIXct(character()),
      match_end_time = as.POSIXct(character()),
      start_time_local = as.POSIXct(character()),
      session_num = integer()
    ))
  }

  # Return empty tibble if any required column is missing
  zoom_recorded_sessions_required_cols <- c("section", "match_start_time", "match_end_time")
  transcript_files_required_cols <- c("start_time_local")

  if (!all(zoom_recorded_sessions_required_cols %in% names(df_zoom_recorded_sessions) & transcript_files_required_cols %in% names(df_transcript_files))) {
    return(tibble::tibble(
      section = character(),
      match_start_time = as.POSIXct(character()),
      match_end_time = as.POSIXct(character()),
      start_time_local = as.POSIXct(character()),
      session_num = integer()
    ))
  }

  # Use base R operations instead of dplyr to avoid segmentation fault
  # Create cross join manually
  joined_sessions <- expand.grid(
    i = seq_len(nrow(df_zoom_recorded_sessions)),
    j = seq_len(nrow(df_transcript_files))
  )

  # Extract rows from both data frames
  zoom_rows <- df_zoom_recorded_sessions[joined_sessions$i, , drop = FALSE]
  transcript_rows <- df_transcript_files[joined_sessions$j, , drop = FALSE]

  # Combine columns
  joined_sessions <- cbind(zoom_rows, transcript_rows)

  # Filter using base R instead of dplyr
  filter_condition <- joined_sessions$match_start_time <= joined_sessions$start_time_local &
    joined_sessions$match_end_time >= joined_sessions$start_time_local
  joined_sessions <- joined_sessions[filter_condition, , drop = FALSE]

  # Get all columns needed in the final output
  all_cols <- union(names(joined_sessions), names(df_cancelled_classes))

  # Add missing columns as NA, matching type from reference data frame
  add_missing_cols <- function(df, all_cols, ref_df) {
    for (col in setdiff(all_cols, names(df))) {
      if (col %in% names(ref_df)) {
        # Match type from reference data frame
        ref_col <- ref_df[[col]]
        if (inherits(ref_col, "POSIXct")) {
          # Use same timezone as reference
          tz <- attr(ref_col, "tzone")
          if (is.null(tz)) tz <- "UTC"
          df[[col]] <- as.POSIXct(NA, tz = tz)
        } else if (is.numeric(ref_col)) {
          df[[col]] <- as.numeric(NA)
        } else if (is.character(ref_col)) {
          df[[col]] <- as.character(NA)
        } else if (is.integer(ref_col)) {
          df[[col]] <- as.integer(NA)
        } else if (is.logical(ref_col)) {
          df[[col]] <- as.logical(NA)
        } else {
          df[[col]] <- NA
        }
      } else {
        # Default to logical NA
        df[[col]] <- NA
      }
    }
    df[all_cols]
  }

  joined_sessions <- add_missing_cols(joined_sessions, all_cols, df_cancelled_classes)
  df_cancelled_classes <- add_missing_cols(df_cancelled_classes, all_cols, joined_sessions)

  # Coerce 'section' to character in both data frames to avoid type mismatch
  joined_sessions$section <- as.character(joined_sessions$section)
  df_cancelled_classes$section <- as.character(df_cancelled_classes$section)

  # Coerce 'course_section' to character in both data frames to avoid type mismatch
  if ("course_section" %in% names(joined_sessions)) {
    joined_sessions$course_section <- as.character(joined_sessions$course_section)
  }
  if ("course_section" %in% names(df_cancelled_classes)) {
    df_cancelled_classes$course_section <- as.character(df_cancelled_classes$course_section)
  }

  # Coerce 'ID' to character in both data frames to avoid type mismatch
  if ("ID" %in% names(joined_sessions)) {
    joined_sessions$ID <- as.character(joined_sessions$ID)
  }
  if ("ID" %in% names(df_cancelled_classes)) {
    df_cancelled_classes$ID <- as.character(df_cancelled_classes$ID)
  }

  # Coerce file columns to character in both data frames to avoid type mismatch
  file_cols <- c("chat_file", "transcript_file", "closed_caption_file")
  for (col in file_cols) {
    if (col %in% names(joined_sessions)) {
      joined_sessions[[col]] <- as.character(joined_sessions[[col]])
    }
    if (col %in% names(df_cancelled_classes)) {
      df_cancelled_classes[[col]] <- as.character(df_cancelled_classes[[col]])
    }
  }

  # Coerce 'Start Time' to character in both data frames to avoid type mismatch
  if ("Start Time" %in% names(joined_sessions)) {
    joined_sessions$`Start Time` <- as.character(joined_sessions$`Start Time`)
  }
  if ("Start Time" %in% names(df_cancelled_classes)) {
    df_cancelled_classes$`Start Time` <- as.character(df_cancelled_classes$`Start Time`)
  }

  # Coerce numeric columns to numeric in both data frames to avoid type mismatch
  numeric_cols <- c("Total Views", "Total Downloads", "File Count", "File Size (MB)")
  for (col in numeric_cols) {
    if (col %in% names(joined_sessions)) {
      joined_sessions[[col]] <- suppressWarnings(as.numeric(joined_sessions[[col]]))
    }
    if (col %in% names(df_cancelled_classes)) {
      df_cancelled_classes[[col]] <- suppressWarnings(as.numeric(df_cancelled_classes[[col]]))
    }
  }

  # Coerce 'Last Accessed' to character in both data frames to avoid type mismatch
  if ("Last Accessed" %in% names(joined_sessions)) {
    joined_sessions$`Last Accessed` <- as.character(joined_sessions$`Last Accessed`)
  }
  if ("Last Accessed" %in% names(df_cancelled_classes)) {
    df_cancelled_classes$`Last Accessed` <- as.character(df_cancelled_classes$`Last Accessed`)
  }

  # Coerce 'match_start_time' and 'match_end_time' to character in both data frames to avoid type mismatch
  for (col in c("match_start_time", "match_end_time")) {
    if (col %in% names(joined_sessions)) {
      joined_sessions[[col]] <- as.character(joined_sessions[[col]])
    }
    if (col %in% names(df_cancelled_classes)) {
      df_cancelled_classes[[col]] <- as.character(df_cancelled_classes[[col]])
    }
  }

  # Coerce 'date_extract' to character in both data frames to avoid type mismatch
  if ("date_extract" %in% names(joined_sessions)) {
    joined_sessions$date_extract <- as.character(joined_sessions$date_extract)
  }
  if ("date_extract" %in% names(df_cancelled_classes)) {
    df_cancelled_classes$date_extract <- as.character(df_cancelled_classes$date_extract)
  }

  # Coerce 'recording_start' to character in both data frames to avoid type mismatch
  if ("recording_start" %in% names(joined_sessions)) {
    joined_sessions$recording_start <- as.character(joined_sessions$recording_start)
  }
  if ("recording_start" %in% names(df_cancelled_classes)) {
    df_cancelled_classes$recording_start <- as.character(df_cancelled_classes$recording_start)
  }

  # Coerce 'start_time_local' to character in both data frames to avoid type mismatch
  if ("start_time_local" %in% names(joined_sessions)) {
    joined_sessions$start_time_local <- as.character(joined_sessions$start_time_local)
  }
  if ("start_time_local" %in% names(df_cancelled_classes)) {
    df_cancelled_classes$start_time_local <- as.character(df_cancelled_classes$start_time_local)
  }

  # Use base R operations instead of dplyr to avoid segmentation fault
  # Combine the data frames
  result <- rbind(joined_sessions, df_cancelled_classes)

  # Sort by start_time_local
  if ("start_time_local" %in% names(result)) {
    result <- result[order(result$start_time_local), , drop = FALSE]
  }

  # Add session_num by section using base R
  if ("section" %in% names(result) && "start_time_local" %in% names(result)) {
    # Convert start_time_local back to POSIXct for proper ordering
    result$start_time_local <- as.POSIXct(result$start_time_local)

    # Calculate session_num by section
    result$session_num <- NA_integer_
    sections <- unique(result$section)

    for (sect in sections) {
      if (!is.na(sect)) { # Handle NA sections
        section_rows <- result$section == sect
        if (sum(section_rows, na.rm = TRUE) > 0) {
          # Get the order within this section
          section_data <- result[section_rows, , drop = FALSE]
          section_order <- order(section_data$start_time_local)

          # Assign dense rank (1, 2, 3, etc.) - handle NA rows carefully
          valid_rows <- which(section_rows)
          if (length(valid_rows) > 0) {
            result$session_num[valid_rows[section_order]] <- seq_len(length(valid_rows))
          }
        }
      }
    }
  }

  # Convert to tibble to maintain expected return type
  tibble::as_tibble(result)
}
# join_transcripts_list(df_zoom_recorded_sessions = zoom_recorded_sessions_df,
#                       df_transcript_files = transcript_files_df,
#                       df_cancelled_classes = cancelled_classes_df)
