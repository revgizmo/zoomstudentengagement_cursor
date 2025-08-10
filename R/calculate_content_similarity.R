#' Calculate Content Similarity Between Two Transcripts
#'
#' Calculates similarity between two transcript data frames based on multiple metrics
#' including speaker overlap, duration, word count, and comment count. This function
#' is useful for identifying duplicate or similar transcript files and for quality
#' control in transcript processing workflows.
#'
#' @param transcript1 First transcript data frame or tibble containing transcript data
#' @param transcript2 Second transcript data frame or tibble containing transcript data
#' @param names_to_exclude Character vector of names to exclude from comparison.
#'   Defaults to c("dead_air") to ignore silence periods and system-generated entries
#'
#' @return Similarity score between 0 and 1, where:
#'   - 1 indicates identical content
#'   - 0 indicates completely different content
#'   - Values in between represent partial similarity
#'
#' @export
#'
#' @examples
#' # Create sample transcript data
#' transcript1 <- data.frame(
#'   name = c("Student A", "Student B", "dead_air"),
#'   duration = c(10, 15, 5),
#'   wordcount = c(20, 30, 0),
#'   stringsAsFactors = FALSE
#' )
#'
#' transcript2 <- data.frame(
#'   name = c("Student A", "Student C", "dead_air"),
#'   duration = c(12, 18, 3),
#'   wordcount = c(22, 35, 0),
#'   stringsAsFactors = FALSE
#' )
#'
#' # Calculate similarity
#' similarity <- calculate_content_similarity(transcript1, transcript2)
#' print(paste("Similarity score:", round(similarity, 3)))
#'
#' # Calculate similarity excluding dead air entries
#' similarity <- calculate_content_similarity(transcript1, transcript2,
#'   names_to_exclude = c("dead_air", "silence")
#' )
calculate_content_similarity <- function(transcript1, transcript2, names_to_exclude = c("dead_air")) {
  # Handle NULL transcripts
  if (is.null(transcript1) || is.null(transcript2)) {
    return(0.0)
  }

  # Filter out excluded names (only if name column exists)
  if (!is.null(names_to_exclude) && "name" %in% names(transcript1) && "name" %in% names(transcript2)) {
    # Use base R filtering instead of dplyr to avoid segmentation fault
    transcript1 <- transcript1[!transcript1$name %in% names_to_exclude, , drop = FALSE]
    transcript2 <- transcript2[!transcript2$name %in% names_to_exclude, , drop = FALSE]
  }

  # If either transcript is empty after filtering, return 0
  if (nrow(transcript1) == 0 || nrow(transcript2) == 0) {
    return(0.0)
  }

  # Calculate similarity metrics

  # 1. Speaker similarity (proportion of speakers in common)
  speaker_sim <- 0.0
  if ("name" %in% names(transcript1) && "name" %in% names(transcript2)) {
    speakers1 <- unique(transcript1$name)
    speakers2 <- unique(transcript2$name)
    speaker_sim <- length(intersect(speakers1, speakers2)) / length(union(speakers1, speakers2))
  }

  # 2. Duration similarity
  duration_sim <- 0.0
  if ("duration" %in% names(transcript1) && "duration" %in% names(transcript2)) {
    # Convert difftime to numeric seconds if needed
    duration1_numeric <- if (inherits(transcript1$duration, "difftime")) {
      as.numeric(transcript1$duration, units = "secs")
    } else {
      transcript1$duration
    }
    duration2_numeric <- if (inherits(transcript2$duration, "difftime")) {
      as.numeric(transcript2$duration, units = "secs")
    } else {
      transcript2$duration
    }

    total_duration1 <- sum(duration1_numeric, na.rm = TRUE)
    total_duration2 <- sum(duration2_numeric, na.rm = TRUE)
    if (total_duration1 > 0 || total_duration2 > 0) {
      duration_sim <- 1 - abs(total_duration1 - total_duration2) / max(total_duration1, total_duration2)
    }
  }

  # 3. Word count similarity
  word_sim <- 0.0
  if ("wordcount" %in% names(transcript1) && "wordcount" %in% names(transcript2)) {
    total_words1 <- sum(transcript1$wordcount, na.rm = TRUE)
    total_words2 <- sum(transcript2$wordcount, na.rm = TRUE)
    if (total_words1 > 0 || total_words2 > 0) {
      word_sim <- 1 - abs(total_words1 - total_words2) / max(total_words1, total_words2)
    }
  }

  # 4. Comment count similarity
  comment_sim <- 0.0
  if (nrow(transcript1) > 0 && nrow(transcript2) > 0) {
    comment_sim <- 1 - abs(nrow(transcript1) - nrow(transcript2)) / max(nrow(transcript1), nrow(transcript2))
  } else if (nrow(transcript1) == 0 && nrow(transcript2) == 0) {
    comment_sim <- 1.0 # Both empty = identical
  }

  # Check if we have any meaningful similarity metrics
  has_meaningful_data <- (speaker_sim > 0 || duration_sim > 0 || word_sim > 0)

  # Combine similarities (weighted average)
  if (has_meaningful_data) {
    overall_sim <- (speaker_sim * 0.3 + duration_sim * 0.3 + word_sim * 0.2 + comment_sim * 0.2)
  } else {
    # If no meaningful data, return 0.0 (as expected by tests)
    overall_sim <- 0.0
  }

  return(overall_sim)
}
