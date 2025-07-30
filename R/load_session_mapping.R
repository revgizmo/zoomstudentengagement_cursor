#' Load Session Mapping
#'
#' This function loads a session mapping file created by `create_session_mapping()`
#' and integrates it with the Zoom recordings data to provide reliable course
#' information for analysis.
#'
#' @param mapping_file Path to the session mapping CSV file
#' @param zoom_recordings_df Optional Zoom recordings tibble to merge with mapping
#' @param validate_mapping If TRUE, validates that all recordings are properly mapped
#'
#' @return A tibble with the session mapping merged with Zoom recordings data
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Load session mapping
#' session_mapping <- load_session_mapping("session_mapping.csv")
#'
#' # Load and merge with Zoom recordings
#' zoom_recordings_df <- load_zoom_recorded_sessions_list()
#' mapped_recordings <- load_session_mapping(
#'   "session_mapping.csv",
#'   zoom_recordings_df = zoom_recordings_df
#' )
#' }
load_session_mapping <- function(
    mapping_file,
    zoom_recordings_df = NULL,
    validate_mapping = TRUE) {
  # Declare global variables to avoid R CMD check warnings
  zoom_recording_id <- topic <- notes <- dept.x <- instructor.x <- session_date <- NULL

  # Check if mapping file exists
  if (!file.exists(mapping_file)) {
    stop("Session mapping file not found: ", mapping_file)
  }

  # Load mapping file
  mapping_df <- readr::read_csv(mapping_file, show_col_types = FALSE)

  # Validate required columns
  required_cols <- c(
    "zoom_recording_id", "dept", "course", "section",
    "session_date", "session_time", "instructor"
  )
  missing_cols <- setdiff(required_cols, names(mapping_df))
  if (length(missing_cols) > 0) {
    stop(
      "Session mapping file missing required columns: ",
      paste(missing_cols, collapse = ", ")
    )
  }

  # Validate mapping if requested
  if (validate_mapping) {
    unmapped <- mapping_df %>%
      dplyr::filter(is.na(dept) | is.na(course) | is.na(section))

    if (nrow(unmapped) > 0) {
      warning("Found ", nrow(unmapped), " unmapped recordings in session mapping file")
      cat("Unmapped recordings:\n")
      print(unmapped %>% dplyr::select(zoom_recording_id, topic, notes))
    }
  }

  # Merge with Zoom recordings if provided
  if (!is.null(zoom_recordings_df)) {
    if (!tibble::is_tibble(zoom_recordings_df)) {
      stop("zoom_recordings_df must be a tibble")
    }

    # Ensure ID column exists in zoom_recordings_df
    if (!"ID" %in% names(zoom_recordings_df)) {
      stop("zoom_recordings_df must contain 'ID' column")
    }

    # Merge mapping with recordings
    result <- zoom_recordings_df %>%
      dplyr::left_join(
        mapping_df,
        by = c("ID" = "zoom_recording_id")
      ) %>%
      dplyr::mutate(
        dept = if ("dept" %in% names(.)) dept else NA_character_,
        course = if ("course" %in% names(.)) course else NA_character_,
        section = if ("section" %in% names(.)) section else NA_character_,
        instructor = if ("instructor" %in% names(.)) instructor else NA_character_,
        course_section = if (all(c("course", "section") %in% names(.))) paste(course, section, sep = ".") else NA_character_,
        match_start_time = if ("session_date" %in% names(.)) session_date else NA,
        match_end_time = if ("session_date" %in% names(.)) session_date + lubridate::duration(1.5, "hours") else NA
      ) %>%
      dplyr::select(
        -dplyr::any_of(c("dept_zoom")),
        -dplyr::any_of(c("session_date", "session_time"))
      )

    return(result)
  }

  # Return just the mapping if no recordings provided
  mapping_df
}
