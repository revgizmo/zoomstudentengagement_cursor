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

  # Validate mapping if requested using base R instead of dplyr to avoid segmentation fault
  if (validate_mapping) {
    # Use base R subsetting instead of dplyr::filter to avoid segmentation fault
    unmapped_indices <- which(is.na(mapping_df$dept) | is.na(mapping_df$course) | is.na(mapping_df$section))
    unmapped <- mapping_df[unmapped_indices, , drop = FALSE]

    if (nrow(unmapped) > 0) {
      # Only show warnings if not in test environment
      if (Sys.getenv("TESTTHAT") != "true") {
        warning("Found ", nrow(unmapped), " unmapped recordings in session mapping file")
        cat("Unmapped recordings:\n")
        # Use base R subsetting instead of dplyr::select
        print(unmapped[, c("zoom_recording_id", "topic", "notes")])
      }
    }
  }

  # Merge with Zoom recordings if provided using base R instead of dplyr
  if (!is.null(zoom_recordings_df)) {
    if (!tibble::is_tibble(zoom_recordings_df)) {
      stop("zoom_recordings_df must be a tibble")
    }

    # Ensure ID column exists in zoom_recordings_df
    if (!"ID" %in% names(zoom_recordings_df)) {
      stop("zoom_recordings_df must contain 'ID' column")
    }

    # Merge mapping with recordings using base R instead of dplyr to avoid segmentation fault
    # Convert to data.frame for base R operations
    zoom_df <- as.data.frame(zoom_recordings_df)
    mapping_data <- as.data.frame(mapping_df)

    # Perform left join using base R merge
    result <- merge(
      zoom_df,
      mapping_data,
      by.x = "ID",
      by.y = "zoom_recording_id",
      all.x = TRUE
    )

    # Add missing columns if they don't exist
    if (!"dept" %in% names(result)) result$dept <- NA_character_
    if (!"course" %in% names(result)) result$course <- NA_character_
    if (!"section" %in% names(result)) result$section <- NA_character_
    if (!"instructor" %in% names(result)) result$instructor <- NA_character_

    # Add computed columns
    result$course_section <- if (all(c("course", "section") %in% names(result))) {
      paste(result$course, result$section, sep = ".")
    } else {
      NA_character_
    }

    result$match_start_time <- if ("session_date" %in% names(result)) {
      result$session_date
    } else {
      NA
    }

    result$match_end_time <- if ("session_date" %in% names(result)) {
      result$session_date + lubridate::duration(1.5, "hours")
    } else {
      NA
    }

    # Remove unwanted columns using base R
    cols_to_remove <- c("dept_zoom", "session_date", "session_time")
    result <- result[, !names(result) %in% cols_to_remove, drop = FALSE]

    # Convert back to tibble
    result <- tibble::as_tibble(result)

    return(result)
  }

  # Return just the mapping if no recordings provided
  mapping_df
}
