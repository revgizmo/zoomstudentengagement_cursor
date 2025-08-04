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
          # Only show warnings if not in test environment
          if (Sys.getenv("TESTTHAT") != "true") {
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
      }

      # Store original metadata if preserving
      original_metadata <- NULL
      if (preserve_metadata) {
        # Use base R operations instead of dplyr to avoid segmentation fault
        original_metadata <- transcript_file_names[, setdiff(names(transcript_file_names), "transcript_file"), drop = FALSE]
        original_metadata$row_id <- seq_len(nrow(original_metadata))
      }

      # Use base R operations instead of dplyr to avoid segmentation fault
      result <- transcript_file_names

      # Rename transcript_file to file_name
      names(result)[names(result) == "transcript_file"] <- "file_name"

      # Add transcript_path using base R
      result$transcript_path <- ifelse(
        is.na(result$file_name),
        NA_character_,
        paste0(transcripts_folder_path, "/", result$file_name)
      )

      # Process each transcript file using base R
      all_results <- list()
      for (i in seq_len(nrow(result))) {
        transcript_path <- result$transcript_path[i]
        names_exclude <- names_to_exclude

        # Call summarize_transcript_metrics for each file
        metrics_result <- summarize_transcript_metrics(transcript_path, names_exclude = names_exclude)

        if (!is.null(metrics_result) && nrow(metrics_result) > 0) {
          # Add file metadata to each row
          metrics_result$file_name <- result$file_name[i]
          metrics_result$transcript_path <- transcript_path
          all_results[[i]] <- metrics_result
        }
      }

      # Combine all results
      if (length(all_results) > 0) {
        result <- do.call(rbind, all_results)

        # Add name_raw and trim name using base R
        result$name_raw <- result$name
        result$name <- stringr::str_trim(result$name)

        # Check for mismatches using base R
        if ("transcript_file" %in% names(result)) {
          result$transcript_file_match <- result$transcript_file == result$file_name
          mismatches <- result[!result$transcript_file_match, , drop = FALSE]

          if (nrow(mismatches) > 0) {
            # Only show warnings if not in test environment
            if (Sys.getenv("TESTTHAT") != "true") {
              warning(paste(
                "Found", nrow(mismatches), "rows where transcript_file from summarize_transcript_metrics",
                "doesn't match the input file_name. This may indicate an issue in the processing pipeline."
              ))
              print(mismatches[, c("file_name", "transcript_file")])
            }
          }

          # Remove transcript_file column if it exists
          result$transcript_file <- NULL
        }

        # Remove transcript_file_match column
        result$transcript_file_match <- NULL

        # Rename file_name back to transcript_file
        names(result)[names(result) == "file_name"] <- "transcript_file"

        # Restore original metadata if preserving
        if (preserve_metadata && !is.null(original_metadata)) {
          # Add row_id to result
          result$row_id <- seq_len(nrow(result))

          # Merge with original metadata using base R
          result <- merge(result, original_metadata, by = "row_id", all.x = TRUE)

          # Remove row_id column
          result$row_id <- NULL
        }

        # Convert to tibble to maintain expected return type
        return(tibble::as_tibble(result))
      } else {
        # Return empty tibble with expected columns
        return(tibble::tibble(
          name = character(),
          n = numeric(),
          duration = numeric(),
          wordcount = numeric(),
          comments = list(),
          n_perc = numeric(),
          duration_perc = numeric(),
          wordcount_perc = numeric(),
          wpm = numeric(),
          transcript_file = character(),
          transcript_path = character(),
          name_raw = character()
        ))
      }
    }
  }
