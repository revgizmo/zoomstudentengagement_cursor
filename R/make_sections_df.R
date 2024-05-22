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

  if (tibble::is_tibble(roster_df)) {
    roster_df %>%
      dplyr::count(dept, course_num, section)
  }
}
