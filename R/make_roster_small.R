#' Make Smaller DF of the Student Roster
#'
#' This function creates a tibble that includes rows for each students enrolled
#' in the class or classes, with a small subset of the roster columns.
#' @keywords roster
#'
#' @param roster_df A tibble listing the students enrolled in the class or
#'   classes with a small subset of the roster columns.
#'
#' @return A tibble listing the students enrolled in the class or classes with a
#'   small subset of the roster columns.
#' @export
#'
#' @examples
#' make_roster_small(roster_df = load_roster())
make_roster_small <- function(roster_df) {
  student_id <-
    first_last <-
    preferred_name <- dept <- course_num <- section <- NULL

  if (tibble::is_tibble(roster_df)) {
    roster_df %>%
      dplyr::select(student_id, first_last, preferred_name, dept, course_num, section)
  }
}
