#' Load CSV of Student Roster
#'
#' This function creates a tibble from a provided csv file of students enrolled
#' in the class or classes

#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param roster_file File name of the csv file of enrolled students
#'   Defaults to 'roster.csv'
#'
#' @return A tibble listing the students enrolled in the class or classes.
#' @export
#'
#' @examples
#' load_roster()
load_roster <- function(
    data_folder = "data",
    roster_file = "roster.csv") {
  enrolled <- NULL

  roster_file_path <- paste0(data_folder, "/", roster_file)

  if (file.exists(roster_file_path)) {
    readr::read_csv(roster_file_path) %>%
      dplyr::filter(enrolled == TRUE)
  }
}
