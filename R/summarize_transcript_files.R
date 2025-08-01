#' Summarize Transcript Files
#'
#' @param transcript_file_names A data.frame or character vector listing the transcript files.
#'   If a tibble with additional columns beyond 'transcript_file' is provided, all metadata
#'   columns will be preserved in the output.
#' @param data_folder Overall data folder for your recordings and data
#' @param transcripts_folder specific subfolder of the data folder where you store transcripts
#' @param names_to_exclude Character vector of names to exclude from the results
#' @param deduplicate_content Logical. If TRUE, detect and handle duplicate transcripts
#' @param similarity_threshold Threshold for considering transcripts as duplicates (0-1)
#' @param duplicate_method Method for detecting duplicates
#' @return A tibble containing session details and summary metrics by speaker
#' @export
#'
#' @importFrom tidyselect all_of
#' @examples
#' # Create sample transcript file names
#' transcript_files <- c(
#'   "GMT20240115-100000_Recording.transcript.vtt",
#'   "GMT20240116-140000_Recording.transcript.vtt"
#' )
#'
#' # Summarize transcript files
#' summary <- summarize_transcript_files(transcript_file_names = transcript_files)
summarize_transcript_files <-
  function(transcript_file_names,
           data_folder = "data",
           transcripts_folder = "transcripts",
           names_to_exclude = NULL,
           deduplicate_content = FALSE,
           similarity_threshold = 0.95,
           duplicate_method = c("hybrid", "content", "metadata")) {
    # Declare global variables to avoid R CMD check warnings
    transcript_file <- transcript_path <- name <- transcript_file_match <- row_id <- NULL

    duplicate_method <- match.arg(duplicate_method)

    transcripts_folder_path <- paste0(data_folder, "/", transcripts_folder, "/")

    # Handle different input types
    if ("character" %in% class(transcript_file_names)) {
      transcript_file_names <- tibble::tibble(transcript_file = transcript_file_names)
    }

    # If input is a tibble with transcript_file column, preserve all other columns
    preserve_metadata <- tibble::is_tibble(transcript_file_names) &&
      "transcript_file" %in% names(transcript_file_names) &&
      ncol(transcript_file_names) > 1

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

      # Store original metadata if preserving
      original_metadata <- NULL
      if (preserve_metadata) {
        original_metadata <- transcript_file_names %>%
          dplyr::select(-transcript_file) %>%
          dplyr::mutate(row_id = dplyr::row_number())
      }

      result <- transcript_file_names %>%
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

      # Restore original metadata if preserving
      if (preserve_metadata && !is.null(original_metadata)) {
        result <- result %>%
          dplyr::mutate(row_id = dplyr::row_number()) %>%
          dplyr::left_join(original_metadata, by = "row_id") %>%
          dplyr::select(-row_id)
      }

      result
    }
  }
