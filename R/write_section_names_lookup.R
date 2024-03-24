#' Write Section Names Lookup
#'
#' This function takes a tibble containing session details and summary metrics
#' by speaker for all class sessions (and placeholders for missing sections),
#' including customized student names (`clean_names_df`) and saves a subset as a
#' csv file with the specified file name (`section_names_lookup_file`) to the
#' specified data folder (`data_folder`).
#'
#' @param clean_names_df A tibble containing session details and summary metrics
#'   by speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param section_names_lookup_file File name of the csv file of customized
#'   student names by section Defaults to 'section_names_lookup.csv'
#'
#' @return A tibble coresponding to the csv file saved, which is a sorted subset
#'   of the provided tibble containing session details and summary metrics by
#'   speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#' @export
#'
#' @examples
#' write_section_names_lookup(
#'   clean_names_df = make_clean_names_df(
#'     data_folder = 'data',
#'     section_names_lookup_file = 'section_names_lookup.csv',
#'     transcripts_fliwc_df = fliwc_transcript_files(df_transcript_list = NULL),
#'     roster_sessions = student_roster_sessions(
#'       transcripts_list_df = join_transcripts_list(
#'         df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'         df_transcript_files = load_transcript_files_list(),
#'         df_cancelled_classes = load_cancelled_classes()
#'       ),
#'       roster_small_df = make_roster_small(
#'         roster_df = load_roster()
#'       )
#'     )
#'   ),
#'   data_folder = 'data',
#'   section_names_lookup_file = 'section_names_lookup.csv'
#' )

write_section_names_lookup <-
  function(clean_names_df,
           data_folder = 'data',
           section_names_lookup_file = 'section_names_lookup.csv') {

    day <-
      formal_name <-
      n <-
      preferred_name <-
      section <-
      student_id <- time <- transcript_name <- transcript_section <- NULL

    if (tibble::is_tibble(clean_names_df) &&
        file.exists(data_folder)
    ){

      clean_names_df %>%
        dplyr::group_by(transcript_section,
                        day,
                        time,
                        section,
                        preferred_name,
                        formal_name,
                        transcript_name,
                        student_id) %>%
        dplyr::summarise(n = dplyr::n()) %>%
        dplyr::arrange(preferred_name, formal_name) %>%
        dplyr::select(-n) %>%
        readr::write_csv(paste0(data_folder, '/', section_names_lookup_file))

  }
}
