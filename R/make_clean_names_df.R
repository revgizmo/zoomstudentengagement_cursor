#' Make Smaller DF of the Student Roster
#'
#' This function creates a tibble from the joining of a tibble of customized student names by section (`section_names_lookup_file` in the `data_folder` folder),
#' a tibble containing session details and summary metrics by speaker
#'   for all class sessions (`transcripts_fliwc_df`), and A tibble listing the students enrolled in the class or classes, with rows for each recorded class section for each student
#' (`roster_sessions`) into a single tibble.
#'
#' @param data_folder overall data folder for your recordings. Defaults to 'data'
#' @param section_names_lookup_file File name of the csv file of customized student names by section
#'   Defaults to 'section_names_lookup.csv'
#' @param transcripts_fliwc_df A tibble containing session details and summary metrics by speaker
#'   for all class sessions in the tibble provided.
#' @param roster_sessions A tibble listing the students enrolled in the class or classes, with rows for each recorded class section for each student.
#'
#' @return A tibble containing session details and summary metrics by speaker
#'   for all class sessions (and placeholders for missing sections), including customized student names.
#' @export
#'
#' @examples
#' make_clean_names_df(
#'   data_folder = "data",
#'   section_names_lookup_file = "section_names_lookup.csv",
#'   transcripts_fliwc_df = fliwc_transcript_files(df_transcript_list = NULL),
#'   roster_sessions = student_roster_sessions(
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
                                transcripts_fliwc_df,
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

  if (tibble::is_tibble(transcripts_fliwc_df) &&
    tibble::is_tibble(roster_sessions)
  ) {
    transcripts_fliwc_df %>%
      dplyr::rename(
        transcript_name = name,
        transcript_section = section
      ) %>%
      # join section_names_lookup to add any manually corrected formal_name values:
      # (section_names_lookup_file is also the file to update to resolve add incorrect names)
      dplyr::left_join(
        load_section_names_lookup(
          data_folder = data_folder,
          names_lookup_file = section_names_lookup_file
        ),
        by = dplyr::join_by(
          transcript_name,
          transcript_section,
          day,
          time
        )
      ) %>%
      # fill in any formal_name values that weren't on the prior section_names_lookup that was loaded
      dplyr::mutate(
        formal_name = dplyr::if_else(is.na(formal_name),
          transcript_name,
          formal_name
        )
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
        preferred_name = dplyr::if_else(!is.na(preferred_name), preferred_name, formal_name)
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
}
