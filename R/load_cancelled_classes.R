#' Load Cancelled Classes csv file
#'
#' This function creates a tibble from a provided csv file of cancelled class
#' sessions for scheduled classes where a zoom recording is not expected.
#'
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param cancelled_classes_file File name of the csv file of cancelled classes.
#'   Defaults to 'cancelled_classes.csv'
#' @param cancelled_classes_col_types column types in the csv file of cancelled
#'   classes. Defaults to 'ccccccccnnnncTTcTTccci'
#'
#' @return A tibble listing the cancelled class sessions for scheduled classes
#'   where a zoom recording is not expected.
#' @export
#'
#' @examples
#' load_cancelled_classes()
load_cancelled_classes <-
  function(data_folder = "data",
           cancelled_classes_file = "cancelled_classes.csv",
           cancelled_classes_col_types = "ccccccccnnnncTTcTTccci",
           write_blank_cancelled_classes = FALSE
           ) {
    cancelled_classes_file_path <-
      paste0(data_folder, "/", cancelled_classes_file)

    # Check if the file exists
    if (file.exists(cancelled_classes_file_path)) {
      # File exists, proceed with importing it
      data <- readr::read_csv(cancelled_classes_file_path,
        col_types = cancelled_classes_col_types
      )
    } else {
      # File doesn't exist, handle the situation accordingly
      print(paste("File does not exist:", cancelled_classes_file_path))
      data <- zoomstudentengagement::make_blank_cancelled_classes_df()

      if (write_blank_cancelled_classes & !file.exists(cancelled_classes_file_path)) {
        data %>%
        readr::write_csv(paste0(data_folder, "/", cancelled_classes_file))
        }
    }

    data
  }
