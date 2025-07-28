#' Detect Duplicate Transcripts
#'
#' Analyze a list of transcript files to identify potential duplicates based on content similarity.
#' This function helps identify when the same transcript content appears in multiple files,
#' which can happen when the same Zoom recording is downloaded multiple times or when
#' different sections share the same recording.
#'
#' @param transcript_list A tibble containing transcript file information, typically
#'   the output of `load_transcript_files_list()` or similar functions.
#' @param data_folder Overall data folder for your recordings and data. Defaults to 'data'
#' @param transcripts_folder Specific subfolder of the data folder where transcript files are stored.
#'   Defaults to 'transcripts'
#' @param similarity_threshold Threshold for considering transcripts as duplicates (0-1).
#'   Defaults to 0.95 (95% similarity).
#' @param method Method for detecting duplicates. Options:
#'   - "content": Compare actual transcript content
#'   - "metadata": Compare file metadata (size, timestamp, etc.)
#'   - "hybrid": Use both content and metadata
#'   Defaults to "hybrid"
#' @param names_to_exclude Character vector of names to exclude from content comparison.
#'   Defaults to c("dead_air")
#'
#' @return A list containing:
#'   - `duplicate_groups`: List of duplicate groups with file names
#'   - `similarity_matrix`: Matrix of similarity scores between files
#'   - `recommendations`: Suggested actions for each duplicate group
#'   - `summary`: Summary statistics about duplicates found
#'
#' @export
#'
#' @examples
#' # Detect duplicates in a transcript list
#' transcript_list <- load_transcript_files_list()
#' duplicates <- detect_duplicate_transcripts(transcript_list)
#'
#' # View duplicate groups
#' duplicates$duplicate_groups
#'
#' # View recommendations
#' duplicates$recommendations
detect_duplicate_transcripts <- function(
  transcript_list,
  data_folder = "data",
  transcripts_folder = "transcripts",
  similarity_threshold = 0.95,
  method = c("hybrid", "content", "metadata"),
  names_to_exclude = c("dead_air")
) {
  
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
    warning("No transcript files found in the specified directory")
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
    for (i in 1:length(existing_names)) {
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
      tryCatch({
        transcript_data[[i]] <- load_zoom_transcript(existing_files[i])
      }, error = function(e) {
        warning(paste("Could not load transcript:", existing_names[i], "-", e$message))
        transcript_data[[i]] <- NULL
      })
    }
    
    # Compare content
    for (i in 1:length(existing_names)) {
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
  
  for (i in 1:length(existing_names)) {
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
  total_duplicates <- sum(sapply(duplicate_groups, length) - 1)
  
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

#' Calculate Content Similarity Between Two Transcripts
#'
#' Internal function to calculate similarity between two transcript data frames.
#'
#' @param transcript1 First transcript data frame
#' @param transcript2 Second transcript data frame  
#' @param names_to_exclude Names to exclude from comparison
#'
#' @return Similarity score between 0 and 1
calculate_content_similarity <- function(transcript1, transcript2, names_to_exclude = c("dead_air")) {
  
  # Handle NULL transcripts
  if (is.null(transcript1) || is.null(transcript2)) {
    return(0.0)
  }
  
  # Filter out excluded names (only if name column exists)
  if (!is.null(names_to_exclude) && "name" %in% names(transcript1) && "name" %in% names(transcript2)) {
    transcript1 <- transcript1 %>% dplyr::filter(!name %in% names_to_exclude)
    transcript2 <- transcript2 %>% dplyr::filter(!name %in% names_to_exclude)
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
    total_duration1 <- sum(transcript1$duration, na.rm = TRUE)
    total_duration2 <- sum(transcript2$duration, na.rm = TRUE)
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
    comment_sim <- 1.0  # Both empty = identical
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