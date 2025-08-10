#' Create Blank Section Names Lookup Template
#'
#' Creates an empty tibble template for customizing student names by section.
#' This function generates a properly structured data frame that can be filled in
#' to map between different name formats (preferred names, formal names, transcript names)
#' for students across different course sections.
#'
#' @return An empty tibble with the following columns for section name mapping:
#'   \describe{
#'     \item{course_section}{Character. Course and section identifier (e.g., "101.A")}
#'     \item{day}{Character. Day of the week or date}
#'     \item{time}{Character. Class time}
#'     \item{course}{Character. Course number}
#'     \item{section}{Character. Section identifier}
#'     \item{preferred_name}{Character. Student's preferred name}
#'     \item{formal_name}{Character. Student's formal/legal name}
#'     \item{transcript_name}{Character. Name as it appears in Zoom transcripts}
#'     \item{student_id}{Character. Student identification number}
#'   }
#'
#' @export
#'
#' @examples
#' # Create a blank template
#' lookup_template <- make_blank_section_names_lookup_csv()
#' print(lookup_template)
#'
#' # The template can then be filled in and saved as a CSV file
#' # for use with make_clean_names_df()
#'
make_blank_section_names_lookup_csv <- function() {
  readr::read_csv(
    I("course_section,day,time,course,section,preferred_name,formal_name,transcript_name,student_id"),
    col_types = readr::cols(
      course_section = readr::col_character(),
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
