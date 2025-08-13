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

  required_cols <- c(
    "course_section", "day", "time", "course", "section",
    "preferred_name", "formal_name", "transcript_name", "student_id"
  )

  # If the file does not exist, return a blank template
  if (!file.exists(file_path)) {
    if (Sys.getenv("TESTTHAT") != "true") {
      warning(paste("File does not exist:", file_path))
      warning("Creating empty lookup table.")
    }
    return(make_blank_section_names_lookup_csv())
  }

  # Detect whether first or second line is the header row
  first_two <- try(readLines(file_path, n = 2, warn = FALSE), silent = TRUE)
  first_line <- if (!inherits(first_two, "try-error") && length(first_two) >= 1) first_two[1] else ""
  second_line <- if (!inherits(first_two, "try-error") && length(first_two) >= 2) first_two[2] else ""

  skip_detected <- if (grepl("course_section", first_line, fixed = TRUE)) {
    0L
  } else if (grepl("course_section", second_line, fixed = TRUE)) {
    1L
  } else {
    0L
  }

  # Read the file using detected skip and provided column types (to preserve numeric cols when requested)
  data_read <- try(
    readr::read_csv(
      file_path,
      col_types = section_names_lookup_col_types,
      skip = skip_detected,
      show_col_types = FALSE
    ),
    silent = TRUE
  )

  if (inherits(data_read, "try-error")) {
    stop(
      paste0(
        "Malformed lookup file: Unable to read CSV at ", file_path, ".\n",
        "Ensure it is a valid CSV with header row."
      )
    )
  }

  data <- data_read

  # Ensure required columns exist; if some are missing, add them as NA to be more forgiving
  for (col in required_cols) {
    if (!col %in% names(data)) {
      data[[col]] <- NA
    }
  }

  # Keep only required columns and order them
  data <- data[, required_cols]

  # Coerce key name/id columns to character to match expectations, leave course and section type per col_types
  char_cols <- c("course_section", "preferred_name", "formal_name", "transcript_name", "student_id")
  for (col in char_cols) {
    data[[col]] <- as.character(data[[col]])
  }

  # Validate that key name columns are character and not purely numeric when values are present
  name_cols <- c("preferred_name", "formal_name", "transcript_name")
  for (col in name_cols) {
    if (!is.character(data[[col]])) {
      stop(
        paste0(
          "Column '", col, "' must be of type character.\n",
          "Please ensure the CSV does not coerce names to numeric or other types."
        )
      )
    }
    non_na <- data[[col]][!is.na(data[[col]])]
    if (length(non_na) > 0 && any(grepl("^\\s*-?\\d+(\\.\\d+)?\\s*$", non_na))) {
      stop(
        paste0(
          "Column '", col, "' must be of type character.\n",
          "Please ensure the CSV does not contain numeric-only values for names."
        )
      )
    }
  }

  # Return tibble (readr already returns a tibble)
  data
}
