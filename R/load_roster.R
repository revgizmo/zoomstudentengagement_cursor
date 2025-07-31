#' Load Roster of Students from a CSV file
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
  roster_file_path <- file.path(data_folder, roster_file)

  if (file.exists(roster_file_path)) {
    roster_data <- readr::read_csv(roster_file_path)

    # Check if enrolled column exists and filter if it does
    if ("enrolled" %in% names(roster_data)) {
      # Use base R filtering instead of dplyr to avoid segmentation fault
      enrolled_rows <- roster_data$enrolled == TRUE
      return(roster_data[enrolled_rows, , drop = FALSE])
    } else {
      return(roster_data)
    }
  } else {
    # Return empty tibble with same structure if file doesn't exist
    tibble::tibble()
  }
}
