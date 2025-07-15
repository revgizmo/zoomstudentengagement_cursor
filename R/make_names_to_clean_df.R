#' Make Names to Clean DF
#'
#' This function creates a tibble from the provided tibble containing session details
#' and summary metrics by speaker for all class sessions (and placeholders for
#' missing sections), including customized student names, and filters out all
#' records except for those students with transcript recordings but no matching
#' student id.
#'
#' If any names except "dead_air", "unknown", or the instructor's name are listed, resolve them.
#'
#'   + Update students with their formal name from the roster in your `section_names_lookup.csv`
#'   + If appropriate, update `section_names_lookup.csv` with a corresponding `preferred_name`
#'   + Any guest students, label them as "Guests"
#'
#'
#'
#' @param clean_names_df A tibble containing session details and summary metrics
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#'
#' @return A tibble containing session details and summary metrics
#'   by speaker students with transcript recordings but no matching
#' student id.
#' @export
#'
#' @examples
#' \dontrun{
#' # Create sample clean_names_df with unmatched students
#' sample_clean_names_df <- tibble::tibble(
#'   student_id = c("12345", NA, "67890"),
#'   preferred_name = c("John Smith", "Unknown Student", "Jane Doe"),
#'   transcript_name = c("John Smith", "Unknown Student", "Jane Doe"),
#'   n = c(5, 3, 8)
#' )
#'
#' # Find students with transcript recordings but no matching student ID
#' make_names_to_clean_df(sample_clean_names_df)
#' }
make_names_to_clean_df <- function(clean_names_df) {
  n <- preferred_name <- student_id <- transcript_name <- NULL

  if (tibble::is_tibble(clean_names_df)
  ) {
    clean_names_df %>%
      dplyr::group_by(student_id, preferred_name, transcript_name) %>%
      dplyr::summarise(n = dplyr::n()) %>%
      dplyr::filter(!is.na(transcript_name)) %>%
      dplyr::filter(is.na(student_id))
  }
}
