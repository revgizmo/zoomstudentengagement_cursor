#' Make Clean Names DF
#'
#'
#' This function creates a tibble containing session details and summary metrics
#' by speaker for all class sessions (and placeholders for missing sections)
#' from the joining of:
#' * a tibble of customized student names by section (`section_names_lookup_file` in the `data_folder` folder),
#' * a tibble containing session details and summary metrics by speaker for all class sessions (`transcripts_metrics_df`), and
#' * a tibble listing the students enrolled in the class or classes, with rows for each recorded class section for each student (`roster_sessions`) into a single tibble.
#'
#' @param data_folder overall data folder for your recordings. Defaults to
#'   'data'
#' @param section_names_lookup_file File name of the csv file of customized
#'   student names by section Defaults to 'section_names_lookup.csv'
#' @param transcripts_metrics_df A tibble containing session details and summary
#'   metrics by speaker for all class sessions in the tibble provided.
#' @param roster_sessions A tibble listing the students enrolled in the class or
#'   classes, with rows for each recorded class section for each student.
#'
#' @return A tibble containing session details and summary metrics by speaker
#'   for all class sessions (and placeholders for missing sections), including
#'   customized student names.
#' @export
#' @md
#'
#' @examples
#' make_clean_names_df(
#'   data_folder = "data",
#'   section_names_lookup_file = "section_names_lookup.csv",
#'   transcripts_metrics_df = summarize_transcript_files(df_transcript_list = NULL),
#'   roster_sessions = make_student_roster_sessions(
#'     transcripts_list_df = join_transcripts_list(
#'       df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'       df_transcript_files = load_transcript_files_list(),
#'       df_cancelled_classes = load_cancelled_classes()
#'     ),
#'     roster_small_df = make_roster_small(
#'       roster_df = load_roster()
#'     )
#'   )
#' )
#'
make_clean_names_df <- function(data_folder = "data",
                                section_names_lookup_file = "section_names_lookup.csv",
                                transcripts_metrics_df,
                                roster_sessions) {
  comments <-
    day <-
    dept <-
    duration <-
    duration_perc <-
    first_last <-
    formal_name <-
    n <-
    n_perc <-
    name <-
    name_raw <-
    preferred_name <-
    section <-
    session_num <-
    start_time_local <-
    student_id <-
    time <-
    transcript_name <-
    transcript_section <- wordcount <- wordcount_perc <- wpm <- NULL

  # Input validation
  if (!tibble::is_tibble(transcripts_metrics_df)) {
    stop("transcripts_metrics_df must be a tibble")
  }
  if (!tibble::is_tibble(roster_sessions)) {
    stop("roster_sessions must be a tibble")
  }
  if (!is.character(data_folder) || length(data_folder) != 1) {
    stop("data_folder must be a single character string")
  }
  if (!is.character(section_names_lookup_file) || length(section_names_lookup_file) != 1) {
    stop("section_names_lookup_file must be a single character string")
  }

  # Create the file path
  file_path <- file.path(data_folder, section_names_lookup_file)

  # Load the section names lookup
  section_names_lookup <- load_section_names_lookup(
    data_folder = data_folder,
    names_lookup_file = section_names_lookup_file,
    section_names_lookup_col_types = "cccdcccd"
  )

  # Process the data
  transcripts_metrics_df %>%
    dplyr::rename(
      transcript_name = name,
      transcript_section = section
    ) %>%
    # join section_names_lookup to add any manually corrected formal_name values
    dplyr::left_join(
      section_names_lookup,
      by = dplyr::join_by(
        transcript_name,
        transcript_section,
        day,
        time
      )
    ) %>%
    # fill in any formal_name values that weren't on the prior section_names_lookup that was loaded
    dplyr::mutate(
      formal_name = dplyr::coalesce(formal_name, transcript_name)
    ) %>%
    # join to the roster of enrolled students
    dplyr::full_join(
      roster_sessions,
      by = dplyr::join_by(
        formal_name == first_last,
        dept,
        transcript_section,
        session_num,
        start_time_local
      ),
      keep = FALSE
    ) %>%
    # fill in any preferred_name values that weren't on the roster of enrolled students
    dplyr::mutate(
      preferred_name = dplyr::coalesce(preferred_name, formal_name)
    ) %>%
    dplyr::select(
      preferred_name,
      formal_name,
      transcript_name,
      student_id,
      transcript_section,
      session_num,
      n,
      duration,
      wordcount,
      comments,
      n_perc,
      duration_perc,
      wordcount_perc,
      wpm,
      transcript_name,
      name_raw,
      start_time_local,
      tidyselect::everything()
    ) %>%
    dplyr::arrange(student_id, formal_name)
}
