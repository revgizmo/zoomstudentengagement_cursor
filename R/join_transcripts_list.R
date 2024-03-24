#' Join Transcripts Files Into a Single Tibble
#'
#' This function creates a tibble from the joining of the listing of session recordings loaded from the cloud recording csvs
#' (`df_zoom_recorded_sessions`), the list of transcript files
#' (`df_transcript_files`), and the list of cancelled classes
#' (`df_cancelled_classes`) into a single tibble
#'
#' @param df_zoom_recorded_sessions A tibble listing the session recordings
#'   loaded from the cloud recording csvs.
#' @param df_transcript_files A data.frame listing the transcript files from the
#'   zoom recordings loaded from the cloud recording csvs and transcripts.
#' @param df_cancelled_classes A tibble listing the cancelled class sessions for
#'   scheduled classes where a zoom recording is not expected.
#'
#' @return A tibble listing the the class sessions with corresponding transcript
#'   files or placeholders for cancelled classes.
#' @export
#'
#' @examples
#' zoom_recorded_sessions_df <- load_zoom_recorded_sessions_list()
#' transcript_files_df <- load_transcript_files_list()
#' cancelled_classes_df <- load_cancelled_classes()
#'
#' join_transcripts_list(df_zoom_recorded_sessions = zoom_recorded_sessions_df,
#'                       df_transcript_files = transcript_files_df,
#'                       df_cancelled_classes = cancelled_classes_df)

join_transcripts_list <- function(
    df_zoom_recorded_sessions,
    df_transcript_files,
    df_cancelled_classes
) {

  match_start_time <- start_time_local <- match_end_time <- section <- dense_rank <- NULL

  if (tibble::is_tibble(df_zoom_recorded_sessions) &&
      tibble::is_tibble(df_transcript_files) &&
      tibble::is_tibble(df_zoom_recorded_sessions)
  ){

    df_zoom_recorded_sessions %>%
      dplyr::cross_join(df_transcript_files) %>%
      dplyr::filter(match_start_time <= start_time_local,
                    match_end_time >= start_time_local) %>%
      dplyr::bind_rows(df_cancelled_classes) %>%
      dplyr::arrange(start_time_local) %>%
      dplyr::group_by(section) %>%
      dplyr::mutate(session_num = dense_rank(start_time_local)) %>%
      dplyr::ungroup()

  }
}
# join_transcripts_list(df_zoom_recorded_sessions = zoom_recorded_sessions_df,
#                       df_transcript_files = transcript_files_df,
#                       df_cancelled_classes = cancelled_classes_df)
