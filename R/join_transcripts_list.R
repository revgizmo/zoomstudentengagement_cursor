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

  joined_sessions <- df_zoom_recorded_sessions %>%
    dplyr::cross_join(df_transcript_files) %>%
    dplyr::filter(
      match_start_time <= start_time_local,
      match_end_time >= start_time_local
    )

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

  # Coerce file columns to character if present and not already
  file_cols <- c("closed_caption_file", "transcript_file", "chat_file")
  for (col in file_cols) {
    if (col %in% names(joined_sessions)) {
      if (is.list(joined_sessions[[col]])) joined_sessions[[col]] <- as.character(joined_sessions[[col]])
    }
    if (col %in% names(df_cancelled_classes)) {
      if (is.list(df_cancelled_classes[[col]])) df_cancelled_classes[[col]] <- as.character(df_cancelled_classes[[col]])
    }
  }

  result <- dplyr::bind_rows(joined_sessions, df_cancelled_classes) %>%
    dplyr::arrange(start_time_local) %>%
    dplyr::group_by(section) %>%
    dplyr::mutate(session_num = dplyr::dense_rank(start_time_local)) %>%
    dplyr::ungroup()

  result
}
# join_transcripts_list(df_zoom_recorded_sessions = zoom_recorded_sessions_df,
#                       df_transcript_files = transcript_files_df,
#                       df_cancelled_classes = cancelled_classes_df)
