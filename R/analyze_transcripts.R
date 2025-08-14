#' Analyze Transcripts (High-level orchestration)
#'
#' Convenience wrapper to process a set of `.transcript.vtt` files from a folder,
#' compute engagement metrics, and optionally write outputs.
#'
#' @param transcripts_folder Path to a folder containing Zoom `.transcript.vtt` files.
#' @param names_to_exclude Character vector of names to exclude. Default: c("dead_air").
#' @param write If TRUE, writes engagement metrics to CSV via `write_metrics()`.
#' @param output_path Optional output CSV path. If NULL and `write=TRUE`, defaults to `engagement_metrics.csv`.
#' @return A tibble of engagement metrics (privacy-masked by default at write-time; in-memory masking depends on consumer).
#' @export
analyze_transcripts <- function(
    transcripts_folder,
    names_to_exclude = c("dead_air"),
    write = FALSE,
    output_path = NULL) {
  if (!dir.exists(transcripts_folder)) {
    stop(sprintf("Folder not found: %s", transcripts_folder))
  }

  files <- list.files(transcripts_folder, pattern = "\\.transcript\\.vtt$", full.names = TRUE)
  if (length(files) == 0) {
    stop("No .transcript.vtt files found in the provided folder")
  }

  # Build input for summarize_transcript_files
  file_names <- basename(files)
  input_df <- tibble::tibble(transcript_file = file_names)

  metrics <- summarize_transcript_files(
    transcript_file_names = input_df,
    data_folder = ".",
    transcripts_folder = transcripts_folder,
    names_to_exclude = names_to_exclude,
    deduplicate_content = FALSE
  )

  if (isTRUE(write)) {
    write_metrics(metrics, what = "engagement", path = output_path %||% "engagement_metrics.csv")
  }

  metrics
}

# Safe infix for defaults
`%||%` <- function(a, b) if (is.null(a)) b else a
