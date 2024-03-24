#' Make Blank Section Names Lookup Tibble

#' This function creates an empty tibble for customization of student names by section.

#'
#' @return An empty tibble for customization of student names by section.
#' @export
#'
#' @examples
#' make_blank_section_names_lookup_csv()

make_blank_section_names_lookup_csv <- function() {

  readr::read_csv(
    I('transcript_section,day,time,section,preferred_name,formal_name,transcript_name,student_id'),
    col_types = 'cccncccn'
  )
}
