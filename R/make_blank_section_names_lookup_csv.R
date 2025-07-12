#' Make Blank Section Names Lookup Tibble
#'
#' This function creates an empty tibble for customization of student names by section.
#'
#' @return An empty tibble for customization of student names by section.
#' @export
#'
#' @examples
#' make_blank_section_names_lookup_csv()
make_blank_section_names_lookup_csv <- function() {
  readr::read_csv(
    I("transcript_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id"),
    col_types = readr::cols(
      transcript_section = readr::col_character(),
      day = readr::col_character(),
      time = readr::col_character(),
      course = readr::col_character(),
      section = readr::col_character(),
      preferred_name = readr::col_character(),
      formal_name = readr::col_character(),
      transcript_name = readr::col_character(),
      student_id = readr::col_character()
    )
  )
}
