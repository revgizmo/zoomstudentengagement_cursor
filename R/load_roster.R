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
#' \dontrun{
#' # Load roster from default location
#' roster <- load_roster()
#'
#' # Load roster from custom location
#' roster <- load_roster(data_folder = "my_data", roster_file = "students.csv")
#' }
load_roster <- function(
    data_folder = "data",
    roster_file = "roster.csv") {
  roster_file_path <- file.path(data_folder, roster_file)

  if (file.exists(roster_file_path)) {
    roster_data <- readr::read_csv(roster_file_path, show_col_types = FALSE)

    # Check if enrolled column exists and filter if it does
    if ("enrolled" %in% names(roster_data)) {
      # Use base R subsetting to avoid segmentation faults
      filtered_data <- roster_data[roster_data$enrolled == TRUE, ]
      return(tibble::as_tibble(filtered_data))
    } else {
      return(tibble::as_tibble(roster_data))
    }
  } else {
    # Return empty tibble with expected structure when file doesn't exist
    return(tibble::tibble())
  }
}
