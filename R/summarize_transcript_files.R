#' Summarize Transcript Files
#'
#' @param transcript_file_names A data.frame or character vector listing the transcript files from the
#'   zoom recordings loaded from the cloud recording csvs and transcripts.
#' @param data_folder Overall data folder for your recordings and data. Defaults
#'   to 'data'
#' @param transcripts_folder specific subfolder of the data folder where you
#'   will store the cloud recording csvs and transcripts
#' @param names_to_exclude Character vector of names to exclude from the results.
#'   Defaults to NULL
#' @param deduplicate_content Logical. If TRUE, detect and handle duplicate transcripts.
#'   Defaults to FALSE
#' @param similarity_threshold Threshold for considering transcripts as duplicates (0-1).
#'   Defaults to 0.95 (95% similarity).
#' @param duplicate_method Method for detecting duplicates. Options:
#'   - "content": Compare actual transcript content
#'   - "metadata": Compare file metadata (size, timestamp, etc.)
#'   - "hybrid": Use both content and metadata
#'   Defaults to "hybrid"
#'
#' @return A tibble containing session details and summary metrics by speaker
#'   for all class sessions in the tibble provided.
#' @export
#'
#' @examples
#' summarize_transcript_files(df_transcript_list = NULL)
summarize_transcript_files <-
  function(transcript_file_names,
           data_folder = "data",
           transcripts_folder = "transcripts",
           names_to_exclude = NULL,
           deduplicate_content = FALSE,
           similarity_threshold = 0.95,
           duplicate_method = c("hybrid", "content", "metadata")) {
    transcript_file <- transcript_path <- name <- NULL

    duplicate_method <- match.arg(duplicate_method)

    transcripts_folder_path <- paste0(data_folder, "/", transcripts_folder, "/")

    if ('character' %in% class(transcript_file_names) )      {
      transcript_file_names = tibble(transcript_file = transcript_file_names)
    }

    if (tibble::is_tibble(transcript_file_names) &&
      file.exists(transcripts_folder_path)
    ) {
      
      # Handle duplicate detection if requested
      if (deduplicate_content) {
        # Detect duplicates
        duplicates <- detect_duplicate_transcripts(
          transcript_file_names,
          data_folder = data_folder,
          transcripts_folder = transcripts_folder,
          similarity_threshold = similarity_threshold,
          method = duplicate_method,
          names_to_exclude = names_to_exclude
        )
        
        # If duplicates found, warn user
        if (length(duplicates$duplicate_groups) > 0) {
          warning(paste(
            "Found", length(duplicates$duplicate_groups), "duplicate groups.",
            "Consider reviewing and removing duplicates before processing."
          ))
          
          # Print recommendations
          cat("\nDuplicate detection results:\n")
          cat("============================\n")
          for (i in seq_along(duplicates$recommendations)) {
            cat(paste("Group", i, ":", duplicates$recommendations[i], "\n"))
          }
          cat("\n")
        }
      }

      transcript_file_names %>%
        dplyr::rename(file_name = transcript_file) %>%
        dplyr::mutate(
          transcript_path = dplyr::if_else(
            is.na(file_name),
            NA,
            paste0(transcripts_folder_path, "/", file_name)
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
        ) %>%
        dplyr::mutate(
          # Check if transcript_file from summarize_transcript_metrics matches file_name
          transcript_file_match = transcript_file == file_name
        ) %>%
        {
          # Check for mismatches and warn/error
          mismatches <- dplyr::filter(., !transcript_file_match)
          if (nrow(mismatches) > 0) {
            warning(paste(
              "Found", nrow(mismatches), "rows where transcript_file from summarize_transcript_metrics",
              "doesn't match the input file_name. This may indicate an issue in the processing pipeline."
            ))
            print(mismatches[, c("file_name", "transcript_file")])
          }
          .
        } %>%
        {
          # Only remove columns if they exist
          cols_to_remove <- c("transcript_file_match")
          if ("transcript_file" %in% names(.)) {
            cols_to_remove <- c(cols_to_remove, "transcript_file")
          }
          dplyr::select(., -all_of(cols_to_remove))
        } %>%
        dplyr::rename(transcript_file = file_name)
    }
  }
