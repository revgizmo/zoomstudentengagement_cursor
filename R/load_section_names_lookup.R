#' Load Section Names Lookup File
#'
#' This function creates a tibble from a provided file of customized student names by section.
#' If the file does not exist, the function prints an error and creates an empty tibble using `make_blank_section_names_lookup_csv()`.
#'
#' @param data_folder overall data folder for your recordings
#' @param names_lookup_file File name of the csv file of customized student names by section
#'   Defaults to 'section_names_lookup.csv'
#' @param section_names_lookup_col_types column types in the csv file of customized student names by section. Defaults to 'cccccccc'
#'
#' @return A tibble of customized student names by section.
#' @export
#'
#' @examples
#' load_section_names_lookup()
#'
load_section_names_lookup <- function(data_folder = "data",
                                      names_lookup_file = "section_names_lookup.csv",
                                      section_names_lookup_col_types = "ccccccccc") {
  preferred_name <- section <- student_id <- NULL

  # Input validation
  if (!is.character(data_folder) || length(data_folder) != 1) {
    stop("data_folder must be a single character string")
  }
  if (!is.character(names_lookup_file) || length(names_lookup_file) != 1) {
    stop("names_lookup_file must be a single character string")
  }
  if (!is.character(section_names_lookup_col_types) || length(section_names_lookup_col_types) != 1) {
    stop("section_names_lookup_col_types must be a single character string")
  }

  # Create the file path
  file_path <- file.path(data_folder, names_lookup_file)

  # Check if the file exists
  if (file.exists(file_path)) {
    # File exists, proceed with importing it
    data <- readr::read_csv(
      file_path,
      col_names = c("course_section", "day", "time", "course", "section", "preferred_name", "formal_name", "transcript_name", "student_id"),
      col_types = section_names_lookup_col_types,
      skip = 1,
      show_col_types = FALSE
    )
  } else {
    # File doesn't exist, handle the situation accordingly
    # Only show warnings if not in test environment
    if (Sys.getenv("TESTTHAT") != "true") {
      warning(paste("File does not exist:", file_path))
      warning("Creating empty lookup table.")
    }
    data <- make_blank_section_names_lookup_csv()
  }

  data
}
