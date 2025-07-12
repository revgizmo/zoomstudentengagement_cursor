#' Make a DF of Class Sections from the Student Roster
#'
#' This function creates a tibble that includes rows for each section (grouped by dept and course number) and student count in each.
#' @keywords sections
#'
#' @param roster_df A tibble listing the students enrolled in the class or classes.
#'   Must contain the following columns:
#'   - dept: character
#'   - course_num: integer
#'   - section: integer
#'
#' @return A tibble with the following columns:
#'   - dept: character
#'   - course_num: integer
#'   - section: integer
#'   - n: integer (count of students in each section)
#' @export
#'
#' @examples
#' # Load a sample roster from the package's extdata directory
#' roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
#' roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
#' make_sections_df(roster_df = roster_df)
make_sections_df <- function(roster_df) {
  dept <- course_num <- section <- n <- NULL
  
  # Defensive: check for valid input
  if (!tibble::is_tibble(roster_df)) {
    stop("roster_df must be a tibble")
  }

  # Defensive: check for required columns
  required_cols <- c("dept", "course_num", "section")
  missing_cols <- setdiff(required_cols, names(roster_df))
  if (length(missing_cols) > 0) {
    stop("roster_df must contain columns: ", paste(missing_cols, collapse = ", "))
  }

  # Handle empty input
  if (nrow(roster_df) == 0) {
    return(tibble::tibble(
      dept = character(),
      course_num = integer(),
      section = integer(),
      n = integer()
    ))
  }

  # Ensure correct column types
  roster_df <- roster_df %>%
    dplyr::mutate(
      dept = as.character(dept),
      course_num = as.integer(course_num),
      section = as.integer(section)
    )

  # Count students by section, handling NA values
  roster_df %>%
    dplyr::group_by(dept, course_num, section) %>%
    dplyr::summarise(n = dplyr::n(), .groups = "drop") %>%
    dplyr::arrange(dept, course_num, section)
}
