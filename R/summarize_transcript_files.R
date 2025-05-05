#' Summarize Transcript Files
#'
#' @param df_transcript_list A data.frame listing the transcript files from the
#'   zoom recordings loaded from the cloud recording csvs and transcripts.
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param transcripts_folder specific subfolder of the data folder where you
#'   will store the cloud recording csvs and transcripts
#' @param names_to_exclude Character vector of names to exclude from the results.
#'   Defaults to NULL
#'
#' @return A tibble containing session details and summary metrics by speaker
#'   for all class sessions in the tibble provided.
#' @export
#'
#' @examples
#' summarize_transcript_files(df_transcript_list = NULL)
summarize_transcript_files <-
  function(df_transcript_list,
           data_folder = "data",
           transcripts_folder = "transcripts",
           names_to_exclude = NULL) {
    transcript_file <- transcript_path <- name <- NULL

    transcripts_folder_path <- paste0(data_folder, "/", transcripts_folder, "/")

    if (tibble::is_tibble(df_transcript_list) &&
      file.exists(transcripts_folder_path)
    ) {
      df_transcript_list %>%
        dplyr::mutate(
          transcript_path = dplyr::if_else(
            is.na(transcript_file),
            NA,
            paste0(transcripts_folder_path, "/", transcript_file)
          ),
          summarize_transcript_metrics = purrr::map2(
            transcript_path,
            list(c(names_exclude = names_to_exclude)),
            summarize_transcript_metrics
          )
        ) %>%
        tidyr::unnest(cols = c(summarize_transcript_metrics)) %>%
        dplyr::mutate(
          name_raw = name,
          name = stringr::str_trim(name)
        )
    }
  }
