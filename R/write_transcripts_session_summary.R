#' Write Transcripts Session Summary
#'
#' This function takes a tibble containing session details and summary metrics
#' by speaker for all class sessions (and placeholders for missing sections),
#' including customized student names, and summarizes results at the level of
#' the session and preferred student name (`transcripts_session_summary_df`),
#' and saves it as a csv file with the specified file name
#' (`transcripts_session_summary_file`) to the specified data folder
#' (`data_folder`).
#'
#' @param transcripts_session_summary_df a tibble containing session details and
#'   summary metrics by speaker for all class sessions (and placeholders for
#'   missing sections), including customized student names, and summarizes
#'   results at the level of the session and preferred student name.
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param transcripts_session_summary_file File name of the csv file of summary
#'   results at the level of the session and preferred student name. Defaults to
#'   'transcripts_session_summary.csv'
#'
#' @return A tibble coresponding to the csv file saved, which is a sorted subset
#'   of the provided tibble containing session details and summary metrics by
#'   speaker for all class sessions (and placeholders for missing sections),
#'   including customized student names.
#' @export
#'
#' @examples
#' write_transcripts_session_summary(
#'   make_transcripts_session_summary_df(
#'     clean_names_df = make_clean_names_df(
#'       data_folder = "data",
#'       section_names_lookup_file = "section_names_lookup.csv",
#'       transcripts_fliwc_df = fliwc_transcript_files(df_transcript_list = NULL),
#'       roster_sessions = make_student_roster_sessions(
#'         transcripts_list_df = join_transcripts_list(
#'           df_zoom_recorded_sessions = load_zoom_recorded_sessions_list(),
#'           df_transcript_files = load_transcript_files_list(),
#'           df_cancelled_classes = load_cancelled_classes()
#'         ),
#'         roster_small_df = make_roster_small(
#'           roster_df = load_roster()
#'         )
#'       )
#'     )
#'   )
#' )
write_transcripts_session_summary <-
  function(transcripts_session_summary_df,
           data_folder = "data",
           transcripts_session_summary_file = "transcripts_session_summary.csv") {
    if (tibble::is_tibble(transcripts_session_summary_df)
    ) {
      transcripts_session_summary_df %>%
        readr::write_csv(paste0(data_folder, "/", transcripts_session_summary_file))
    }
  }
