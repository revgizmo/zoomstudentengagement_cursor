#' Load Roster of Students from a CSV file
#'
#' This function creates a tibble from a provided csv file of students enrolled
#' in the class or classes

#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param roster_file File name of the csv file of enrolled students
#'   Defaults to 'roster.csv'
#' @param strict_errors Whether to throw errors for missing files instead of
#'   returning empty tibbles. Defaults to FALSE for backward compatibility.
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
    roster_file = "roster.csv",
    strict_errors = FALSE) {
  roster_file_path <- file.path(data_folder, roster_file)

  if (file.exists(roster_file_path)) {
    roster_data <- readr::read_csv(roster_file_path, show_col_types = FALSE)

    # Check if enrolled column exists and filter if it does
    if ("enrolled" %in% names(roster_data)) {
      # Use base R subsetting to avoid segmentation faults
      roster_data <- roster_data[roster_data$enrolled == TRUE, ]
    }

    roster_tbl <- tibble::as_tibble(roster_data)
    # Validate minimal roster schema where possible
    try(validate_schema(roster_tbl, zse_schema$roster$required), silent = TRUE)
    return(roster_tbl)
  } else {
    if (strict_errors) {
      # Throw error when file doesn't exist for enhanced error handling
      abort_zse(paste0("Roster file not found at `", roster_file_path, "`"), class = "zse_input_error")
    } else {
      # Return empty tibble with expected structure when file doesn't exist (backward compatibility)
      return(tibble::tibble())
    }
  }
}
