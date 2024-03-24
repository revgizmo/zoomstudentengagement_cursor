#' Load Section Names Lookup File
#'
#' This function creates a tibble from a provided file of customized student names by section.
#' If the file does not exist, the function prints an error and creates an empty tibble using `make_blank_section_names_lookup_csv()`.
#'
#' @param data_folder overall data folder for your recordings
#' @param names_lookup_file File name of the csv file of customized student names by section
#'   Defaults to 'section_names_lookup.csv'
#' @param section_names_lookup_col_types column types in the csv file of customized student names by section. Defaults to 'cccdcccd'
#'
#' @return A tibble of customized student names by section.
#' @export
#'
#' @examples
#' load_section_names_lookup()
#'
load_section_names_lookup <- function(data_folder = 'data',
                                      names_lookup_file = 'section_names_lookup.csv',
                                      section_names_lookup_col_types = 'cccdcccd') {

  preferred_name <- section <- student_id <- NULL

  file_path <- paste0(data_folder, '/', names_lookup_file)

  # Check if the file exists
  if (file.exists(file_path)) {
    # File exists, proceed with importing it
    data <- readr::read_csv(file_path, col_types = section_names_lookup_col_types)
    # Your import or processing logic here
  } else {
    # File doesn't exist, handle the situation accordingly
    print(paste("File does not exist:", file_path))
    data <- make_blank_section_names_lookup_csv()

  }

  data %>%
    dplyr::select(-section, -student_id, -preferred_name)
}
