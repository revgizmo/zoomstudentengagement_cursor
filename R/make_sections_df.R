#' Make a DF of Class Sections from the Student Roster
#'
#' This function creates a tibble that includes rows for each section (grouped by dept and course number) and student count in each
#' @keywords sections
#'
#' @param roster_df A tibble listing the students enrolled in the class or classes.
#'
#' @return A tibble including metric labels and metric descriptions
#' @export
#'
#' @examples
#' make_sections_df(roster_df = load_roster())
make_sections_df <- function(roster_df) {
  dept <- course_num <- section <- NULL

  # Defensive: check for valid input
  if (!tibble::is_tibble(roster_df)) {
    stop("roster_df must be a tibble")
  }

  # Defensive: check for required columns
  required_cols <- c("dept", "course_num", "section")
  if (!all(required_cols %in% names(roster_df))) {
    stop("roster_df must contain columns: ", paste(required_cols, collapse = ", "))
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

  roster_df %>%
    dplyr::count(dept, course_num, section)
}
