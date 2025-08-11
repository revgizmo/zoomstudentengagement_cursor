#' Detect Duplicate Transcripts
#'
#' Identifies and analyzes duplicate Zoom transcript files using multiple detection methods.
#' This function helps clean up transcript datasets by finding files that contain similar
#' or identical content, which can occur when multiple transcript formats are generated
#' for the same recording session.
#'
#' @param transcript_list A tibble containing transcript file information with a
#'   `transcript_file` column containing file names
#' @param data_folder Overall data folder for your recordings and data. Defaults to "data"
#' @param transcripts_folder Specific subfolder of the data folder where transcript files
#'   are stored. Defaults to "transcripts"
#' @param similarity_threshold Threshold for considering transcripts as duplicates (0-1).
#'   Higher values require more similarity. Defaults to 0.95
#' @param method Method for detecting duplicates. One of:
#'   - "hybrid" (default): Combines metadata and content analysis
#'   - "content": Analyzes actual transcript content
#'   - "metadata": Compares file metadata only
#' @param names_to_exclude Character vector of names to exclude from content comparison.
#'   Defaults to c("dead_air") to ignore silence periods
#'
#' @return A list containing duplicate detection results with the following elements:
#'   \describe{
#'     \item{duplicate_groups}{List of groups containing duplicate file names}
#'     \item{similarity_matrix}{Matrix of similarity scores between all file pairs}
#'     \item{recommendations}{Character vector of recommendations for handling duplicates}
#'     \item{summary}{List with summary statistics: total_files, duplicate_groups, total_duplicates}
#'   }
#'
#' @export
#'
#' @examples
#' # Create sample transcript list
#' transcript_list <- tibble::tibble(
#'   transcript_file = c(
#'     "GMT20240115-100000_Recording.transcript.vtt",
#'     "GMT20240115-100000_Recording.cc.vtt",
#'     "GMT20240116-140000_Recording.transcript.vtt"
#'   )
#' )
#'
#' # Detect duplicates in a transcript list
#' duplicates <- detect_duplicate_transcripts(transcript_list)
#'
#' # View duplicate groups
#' duplicates$duplicate_groups
#'
#' # View recommendations
#' duplicates$recommendations
#'
#' # Use different detection method
#' content_duplicates <- detect_duplicate_transcripts(
#'   transcript_list,
#'   method = "content",
#'   similarity_threshold = 0.9
#' )
#'
detect_duplicate_transcripts <- function(
    transcript_list,
    data_folder = "data",
    transcripts_folder = "transcripts",
    similarity_threshold = 0.95,
    method = c("hybrid", "content", "metadata"),
    names_to_exclude = c("dead_air")) {
  method <- match.arg(method)

  # Validate similarity threshold
  if (similarity_threshold < 0 || similarity_threshold > 1) {
    warning("similarity_threshold should be between 0 and 1, clamping to valid range")
    similarity_threshold <- max(0, min(1, similarity_threshold))
  }

  if (!tibble::is_tibble(transcript_list)) {
    stop("transcript_list must be a tibble")
  }

  if (nrow(transcript_list) == 0) {
    return(list(
      duplicate_groups = list(),
      similarity_matrix = matrix(numeric(0), nrow = 0, ncol = 0),
      recommendations = character(0),
      summary = list(
        total_files = 0,
        duplicate_groups = 0,
        total_duplicates = 0
      )
    ))
  }

  # Get transcript file names
  transcript_files <- transcript_list$transcript_file
  transcript_files <- transcript_files[!is.na(transcript_files)]

  if (length(transcript_files) == 0) {
    return(list(
      duplicate_groups = list(),
      similarity_matrix = matrix(numeric(0), nrow = 0, ncol = 0),
      recommendations = character(0),
      summary = list(
        total_files = 0,
        duplicate_groups = 0,
        total_duplicates = 0
      )
    ))
  }

  # Build full paths
  transcripts_folder_path <- paste0(data_folder, "/", transcripts_folder, "/")
  full_paths <- paste0(transcripts_folder_path, transcript_files)

  # Check which files exist
  existing_files <- full_paths[file.exists(full_paths)]
  existing_names <- basename(existing_files)

  if (length(existing_files) == 0) {
    # Only show warnings if not in test environment
    if (Sys.getenv("TESTTHAT") != "true") {
      warning("No transcript files found in the specified directory")
    }
    return(list(
      duplicate_groups = list(),
      similarity_matrix = matrix(numeric(0), nrow = 0, ncol = 0),
      recommendations = character(0),
      summary = list(
        total_files = 0,
        duplicate_groups = 0,
        total_duplicates = 0
      )
    ))
  }

  # Initialize results
  duplicate_groups <- list()
  similarity_matrix <- matrix(0, nrow = length(existing_names), ncol = length(existing_names))
  rownames(similarity_matrix) <- existing_names
  colnames(similarity_matrix) <- existing_names

  # Detect duplicates based on method
  if (method %in% c("metadata", "hybrid")) {
    # Get file metadata
    file_info <- file.info(existing_files)
    file_sizes <- file_info$size
    file_mtimes <- file_info$mtime

    # Compare file sizes and modification times
    for (i in seq_along(existing_names)) {
      for (j in i:length(existing_names)) {
        if (i == j) {
          similarity_matrix[i, j] <- 1.0
        } else {
          # Size similarity
          size_sim <- 1 - abs(file_sizes[i] - file_sizes[j]) / max(file_sizes[i], file_sizes[j])

          # Time similarity (within 1 hour = similar)
          time_diff <- abs(as.numeric(file_mtimes[i] - file_mtimes[j]))
          time_sim <- ifelse(time_diff < 3600, 1.0, max(0, 1 - time_diff / 86400)) # 1 day max

          # Combined metadata similarity
          metadata_sim <- (size_sim + time_sim) / 2
          similarity_matrix[i, j] <- metadata_sim
          similarity_matrix[j, i] <- metadata_sim
        }
      }
    }
  }

  if (method %in% c("content", "hybrid")) {
    # Load and compare transcript content
    transcript_data <- list()

    # Load all transcripts
    for (i in seq_along(existing_files)) {
      tryCatch(
        {
          transcript_data[[i]] <- load_zoom_transcript(existing_files[i])
        },
        error = function(e) {
          warning(paste("Could not load transcript:", existing_names[i], "-", e$message))
          transcript_data[[i]] <- NULL
        }
      )
    }

    # Compare content
    for (i in seq_along(existing_names)) {
      for (j in i:length(existing_names)) {
        if (i == j) {
          similarity_matrix[i, j] <- 1.0
        } else {
          content_sim <- calculate_content_similarity(
            transcript_data[[i]],
            transcript_data[[j]],
            names_to_exclude
          )

          if (method == "hybrid") {
            # Combine metadata and content similarity
            similarity_matrix[i, j] <- (similarity_matrix[i, j] + content_sim) / 2
            similarity_matrix[j, i] <- similarity_matrix[i, j]
          } else {
            similarity_matrix[i, j] <- content_sim
            similarity_matrix[j, i] <- content_sim
          }
        }
      }
    }
  }

  # Find duplicate groups
  processed <- logical(length(existing_names))

  for (i in seq_along(existing_names)) {
    if (!processed[i]) {
      # Find all files similar to this one
      similar_files <- which(similarity_matrix[i, ] >= similarity_threshold)

      if (length(similar_files) > 1) {
        duplicate_groups[[length(duplicate_groups) + 1]] <- existing_names[similar_files]
        processed[similar_files] <- TRUE
      }
    }
  }

  # Generate recommendations
  recommendations <- character(length(duplicate_groups))
  for (i in seq_along(duplicate_groups)) {
    group <- duplicate_groups[[i]]
    if (length(group) == 2) {
      recommendations[i] <- paste("Keep", group[1], "and remove", group[2])
    } else {
      recommendations[i] <- paste("Keep", group[1], "and remove", paste(group[-1], collapse = ", "))
    }
  }

  # Create summary
  total_duplicates <- if (length(duplicate_groups) > 0) {
    sum(sapply(duplicate_groups, length) - 1)
  } else {
    0
  }

  summary <- list(
    total_files = length(existing_names),
    duplicate_groups = length(duplicate_groups),
    total_duplicates = total_duplicates,
    similarity_threshold = similarity_threshold,
    method = method
  )

  return(list(
    duplicate_groups = duplicate_groups,
    similarity_matrix = similarity_matrix,
    recommendations = recommendations,
    summary = summary
  ))
}
