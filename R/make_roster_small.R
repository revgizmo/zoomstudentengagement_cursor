#' Make a Smaller DF of the Student Roster
#'
#' This function creates a tibble that includes rows for each students enrolled
#' in the class or classes, with a small subset of the roster columns.
#' @keywords roster
#'
#' @param roster_df A tibble listing the students enrolled in the class or
#'   classes with a small subset of the roster columns. Must contain the following columns:
#'   - student_id: character
#'   - first_last: character
#'   - preferred_name: character
#'   - dept: character
#'   - course: character
#'   - section: character
#'
#' @return A tibble listing the students enrolled in the class or classes with a
#'   small subset of the roster columns.
#' @export
#'
#' @examples
#' # Load a sample roster from the package's extdata directory
#' roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
#' roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
#' make_roster_small(roster_df = roster_df)
make_roster_small <- function(roster_df) {
  # Defensive: check for valid input type
  if (!tibble::is_tibble(roster_df)) {
    stop("roster_df must be a tibble")
  }

  # Defensive: check for required columns
  required_cols <- c("student_id", "first_last", "preferred_name", "dept", "course", "section")
  missing_cols <- setdiff(required_cols, names(roster_df))
  if (length(missing_cols) > 0) {
    stop("roster_df must contain columns: ", paste(missing_cols, collapse = ", "))
  }

  # Handle empty input
  if (nrow(roster_df) == 0) {
    return(tibble::tibble(
      student_id = character(),
      first_last = character(),
      preferred_name = character(),
      dept = character(),
      course = character(),
      section = character()
    ))
  }

  # Select and return required columns, ensuring character types using base R
  result <- roster_df[, c("student_id", "first_last", "preferred_name", "dept", "course", "section"), drop = FALSE]

  # Convert columns to character using base R
  result$student_id <- as.character(result$student_id)
  result$course <- as.character(result$course)
  result$section <- as.character(result$section)

  # Convert to tibble to maintain expected return type
  return(tibble::as_tibble(result))
}
