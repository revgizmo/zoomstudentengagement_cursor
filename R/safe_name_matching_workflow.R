#' Safe Name Matching Workflow
#'
#' Main workflow function for privacy-first name matching. Implements two-stage
#' processing: Stage 1 (unmasked matching in memory) and Stage 2 (privacy masking
#' for outputs). Provides configuration-driven behavior for unmatched names.
#'
#' @param transcript_file_path Path to transcript file to process
#' @param roster_data Data frame containing roster information
#' @param privacy_level Privacy level for processing. One of
#'   `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `getOption("zoomstudentengagement.privacy_level", "mask")`.
#' @param unmatched_names_action Action to take when unmatched names are found.
#'   One of `c("stop", "warn")`. Defaults to `getOption("zoomstudentengagement.unmatched_names_action", "stop")`.
#' @param data_folder Data folder for saving lookup files
#' @param section_names_lookup_file Name of the lookup file
#'
#' @return Processed data with privacy applied
#' @export
#'
#' @examples
#' \dontrun{
#' # Default behavior (maximum privacy)
#' result <- safe_name_matching_workflow(
#'   transcript_file_path = "transcript.vtt",
#'   roster_data = roster_df
#' )
#'
#' # Opt-in for convenience
#' result <- safe_name_matching_workflow(
#'   transcript_file_path = "transcript.vtt",
#'   roster_data = roster_df,
#'   unmatched_names_action = "warn"
#' )
#' }
safe_name_matching_workflow <- function(transcript_file_path,
                                        roster_data,
                                        privacy_level = getOption(
                                          "zoomstudentengagement.privacy_level",
                                          "mask"
                                        ),
                                        unmatched_names_action = getOption(
                                          "zoomstudentengagement.unmatched_names_action",
                                          "stop"
                                        ),
                                        data_folder = ".",
                                        section_names_lookup_file = "section_names_lookup.csv") {
  # Validate inputs
  if (!is.character(transcript_file_path) || length(transcript_file_path) != 1) {
    stop("transcript_file_path must be a single character string", call. = FALSE)
  }

  if (!file.exists(transcript_file_path)) {
    stop("Transcript file not found: ", transcript_file_path, call. = FALSE)
  }

  if (!is.data.frame(roster_data)) {
    stop("roster_data must be a data frame", call. = FALSE)
  }

  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ",
      paste(valid_levels, collapse = ", "),
      call. = FALSE
    )
  }

  valid_actions <- c("stop", "warn")
  if (!unmatched_names_action %in% valid_actions) {
    stop("Invalid unmatched_names_action. Must be one of: ",
      paste(valid_actions, collapse = ", "),
      call. = FALSE
    )
  }

  # defer roster content validation until after basic type checks

  if (!is.character(data_folder) || length(data_folder) != 1) {
    stop("data_folder must be a single character string", call. = FALSE)
  }

  if (!is.character(section_names_lookup_file) || length(section_names_lookup_file) != 1) {
    stop("section_names_lookup_file must be a single character string", call. = FALSE)
  }

  # Validate roster has at least one usable name column and non-empty values
  roster_name_columns <- c(
    "first_last", "preferred_name", "formal_name", "name", "student_name"
  )
  has_roster_name_col <- any(roster_name_columns %in% names(roster_data))
  non_empty_roster_names <- character(0)
  if (has_roster_name_col) {
    first_found <- intersect(roster_name_columns, names(roster_data))[1]
    non_empty_roster_names <- roster_data[[first_found]]
    non_empty_roster_names <- as.character(non_empty_roster_names)
    non_empty_roster_names <- non_empty_roster_names[
      !is.na(non_empty_roster_names) & nchar(trimws(non_empty_roster_names)) > 0
    ]
  }
  if (!has_roster_name_col || length(non_empty_roster_names) == 0) {
    stop(
      paste0(
        "Roster data appears empty or lacks required name columns.\n",
        "Provide a roster with at least one of these columns: ",
        paste(roster_name_columns, collapse = ", "),
        ".\n",
        "See vignette 'roster-cleaning' and example at ",
        "system.file('extdata/roster.csv', package = 'zoomstudentengagement').\n",
        "Tip: You can construct a minimal roster with your own data using ",
        "columns like 'first_last' or 'preferred_name'."
      ),
      call. = FALSE
    )
  }

  # Enhanced empty roster validation
  if (nrow(roster_data) == 0) {
    stop(
      "Roster data is empty. Please provide a valid roster with student information.\n",
      "See vignette('roster-cleaning') for guidance on creating a proper roster.",
      call. = FALSE
    )
  }

  # Stage 1: Load and process with real names in memory (quiet by default)
  diag_message("Stage 1: Loading transcript and performing name matching...")

  # Load transcript (real names in memory only)
  transcript_data <- load_zoom_transcript(transcript_file_path)

  # Validate transcript has a usable name column
  transcript_name_columns <- c(
    "transcript_name", "name", "speaker_name", "participant_name"
  )
  has_transcript_name_col <- any(transcript_name_columns %in% names(transcript_data))
  if (!has_transcript_name_col) {
    stop(
      paste0(
        "Transcript file lacks a usable name column.\n",
        "Expected one of: ",
        paste(transcript_name_columns, collapse = ", "),
        ".\n",
        "Please verify the transcript format. Supported formats include ",
        "Zoom VTT and chat exports with participant names."
      ),
      call. = FALSE
    )
  }

  # Add column existence checks to prevent warnings
  required_columns <- c("user_name", "message", "timestamp")
  missing_cols <- setdiff(required_columns, names(transcript_data))
  if (length(missing_cols) > 0) {
    warning(
      "Missing columns in transcript data: ", paste(missing_cols, collapse = ", "), "\n",
      "This may affect processing. Expected columns: ", paste(required_columns, collapse = ", "),
      call. = FALSE
    )
  }

  # Load existing name mappings
  name_mappings <- tryCatch(
    {
      load_section_names_lookup(
        data_folder = data_folder,
        names_lookup_file = section_names_lookup_file
      )
    },
    error = function(e) {
      # If no mappings exist, create empty data frame
      data.frame(
        transcript_name = character(0),
        preferred_name = character(0),
        formal_name = character(0),
        participant_type = character(0),
        student_id = character(0),
        stringsAsFactors = FALSE
      )
    }
  )

  # Detect unmatched names
  unmatched_names <- detect_unmatched_names(
    transcript_data = transcript_data,
    roster_data = roster_data,
    name_mappings = name_mappings,
    privacy_level = "none" # Need real names for detection
  )

  # Handle unmatched names according to configuration
  if (length(unmatched_names) > 0) {
    handle_unmatched_names(
      unmatched_names = unmatched_names,
      unmatched_names_action = unmatched_names_action,
      privacy_level = privacy_level,
      data_folder = data_folder,
      section_names_lookup_file = section_names_lookup_file
    )
  }

  # Stage 2: Apply privacy masking to outputs (quiet by default)
  diag_message("Stage 2: Applying privacy masking to outputs...")

  # Process transcript with privacy-aware matching
  processed_data <- process_transcript_with_privacy(
    transcript_data = transcript_data,
    roster_data = roster_data,
    name_mappings = name_mappings,
    privacy_level = privacy_level
  )

  # Validate privacy compliance
  validate_privacy_compliance(
    data = processed_data,
    privacy_level = privacy_level,
    real_names = c(
      extract_transcript_names(transcript_data),
      extract_roster_names(roster_data)
    )
  )

  # Explicitly clear real names from memory
  rm(transcript_data, name_mappings, unmatched_names)

  diag_message("Name matching workflow completed successfully.")

  # Return processed data
  processed_data
}

#' Handle Unmatched Names
#'
#' Internal function to handle unmatched names according to configuration.
#'
#' @param unmatched_names Character vector of unmatched names
#' @param unmatched_names_action Action to take ("stop" or "warn")
#' @param privacy_level Privacy level for the session
#' @param data_folder Data folder path
#' @param section_names_lookup_file Name of the lookup file
#'
#' @return Invisibly returns NULL
#' @keywords internal
handle_unmatched_names <- function(unmatched_names,
                                   unmatched_names_action,
                                   privacy_level,
                                   data_folder,
                                   section_names_lookup_file) {
  if (identical(unmatched_names_action, "stop")) {
    # Stop with error for maximum privacy protection
    stop(
      paste0(
        "Found unmatched names: ", paste(unmatched_names, collapse = ", "), "\n",
        "Please update your section_names_lookup.csv file with these mappings.\n",
        "See vignette('name-matching-troubleshooting') for detailed instructions.\n",
        "Example mappings:\n",
        paste(sapply(unmatched_names, function(name) {
          paste0("  ", name, " -> [Your roster name]")
        }), collapse = "\n"), "\n",
        "Lookup file path: ", file.path(data_folder, section_names_lookup_file), "\n",
        "For guided assistance, set unmatched_names_action = 'warn' to receive a template."
      ),
      call. = FALSE
    )
  } else if (identical(unmatched_names_action, "warn")) {
    # Show warning and prompt user for matching
    warning(
      "Some names need matching. Privacy temporarily disabled for matching process.",
      call. = FALSE
    )

    # Prompt user for name matching
    prompt_name_matching(
      unmatched_names = unmatched_names,
      privacy_level = privacy_level,
      data_folder = data_folder,
      section_names_lookup_file = section_names_lookup_file
    )

    # Stop processing to allow user to update mappings
    stop(
      "Please update the name mappings file and re-run the analysis.",
      call. = FALSE
    )
  }
}

#' Process Transcript with Privacy
#'
#' Processes transcript data with privacy-aware name matching. This function
#' implements the two-stage approach: matching with real names in memory,
#' then applying privacy masking to outputs.
#'
#' @param transcript_data Data frame containing transcript data
#' @param roster_data Data frame containing roster data
#' @param name_mappings Data frame containing name mappings
#' @param privacy_level Privacy level for processing
#'
#' @return Processed data with privacy applied
#' @export
#'
#' @examples
#' # Process transcript with privacy
#' transcript_data <- tibble::tibble(
#'   transcript_name = c("Dr. Smith", "John Doe"),
#'   message = c("Hello class", "Good morning")
#' )
#' roster_data <- tibble::tibble(
#'   first_name = c("John"),
#'   last_name = c("Doe")
#' )
#' processed <- process_transcript_with_privacy(
#'   transcript_data = transcript_data,
#'   roster_data = roster_data
#' )
process_transcript_with_privacy <- function(transcript_data,
                                            roster_data,
                                            name_mappings = NULL,
                                            privacy_level = getOption(
                                              "zoomstudentengagement.privacy_level",
                                              "mask"
                                            )) {
  # Validate inputs
  if (!is.data.frame(transcript_data)) {
    stop("transcript_data must be a data frame", call. = FALSE)
  }
  if (!is.data.frame(roster_data)) {
    stop("roster_data must be a data frame", call. = FALSE)
  }

  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ",
      paste(valid_levels, collapse = ", "),
      call. = FALSE
    )
  }

  # Ensure transcript has a usable name column before proceeding
  transcript_name_columns <- c(
    "transcript_name", "name", "speaker_name", "participant_name"
  )
  if (!any(transcript_name_columns %in% names(transcript_data))) {
    stop("No name column found in transcript data", call. = FALSE)
  }

  # Stage 1: Perform name matching with real names in memory
  matched_data <- match_names_with_privacy(
    transcript_data = transcript_data,
    roster_data = roster_data,
    name_mappings = name_mappings,
    privacy_level = "none" # Need real names for matching
  )

  # Stage 2: Apply privacy masking to outputs
  if (!identical(privacy_level, "none")) {
    matched_data <- ensure_privacy(matched_data, privacy_level = privacy_level)
  }

  # Return processed data
  matched_data
}

#' Match Names with Privacy
#'
#' Performs comprehensive name matching with privacy awareness. Uses consistent
#' hashing for cross-session matching while maintaining privacy controls.
#'
#' @param transcript_data Data frame containing transcript data
#' @param roster_data Data frame containing roster data
#' @param name_mappings Data frame containing name mappings
#' @param privacy_level Privacy level for processing
#'
#' @return Matched data with privacy controls applied
#' @export
#'
#' @examples
#' # Match names with privacy
#' transcript_data <- tibble::tibble(
#'   transcript_name = c("Dr. Smith", "John Doe"),
#'   message = c("Hello class", "Good morning")
#' )
#' roster_data <- tibble::tibble(
#'   first_name = c("John"),
#'   last_name = c("Doe")
#' )
#' matched <- match_names_with_privacy(
#'   transcript_data = transcript_data,
#'   roster_data = roster_data
#' )
match_names_with_privacy <- function(transcript_data,
                                     roster_data,
                                     name_mappings = NULL,
                                     privacy_level = getOption(
                                       "zoomstudentengagement.privacy_level",
                                       "mask"
                                     )) {
  # Validate inputs
  if (!is.data.frame(transcript_data)) {
    stop("transcript_data must be a data frame", call. = FALSE)
  }
  if (!is.data.frame(roster_data)) {
    stop("roster_data must be a data frame", call. = FALSE)
  }

  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ",
      paste(valid_levels, collapse = ", "),
      call. = FALSE
    )
  }

  # Extract names for matching
  transcript_names <- extract_transcript_names(transcript_data)
  # If we couldn't extract any names, fail early with clear message
  if (length(transcript_names) == 0) {
    stop("No name column found in transcript data", call. = FALSE)
  }
  roster_names <- extract_roster_names(roster_data)

  # Create name mapping lookup
  name_lookup <- create_name_lookup(
    transcript_names = transcript_names,
    roster_names = roster_names,
    name_mappings = name_mappings
  )

  # Apply name matching to transcript data
  matched_data <- apply_name_matching(
    transcript_data = transcript_data,
    name_lookup = name_lookup,
    roster_data = roster_data
  )

  # Apply privacy masking if needed
  if (!identical(privacy_level, "none")) {
    matched_data <- ensure_privacy(matched_data, privacy_level = privacy_level)
  }

  # Return matched data
  matched_data
}

#' Create Name Lookup
#'
#' Internal function to create a lookup table for name matching.
#'
#' @param transcript_names Character vector of transcript names
#' @param roster_names Character vector of roster names
#' @param name_mappings Data frame containing name mappings
#'
#' @return Data frame with name lookup information
#' @keywords internal
create_name_lookup <- function(transcript_names, roster_names, name_mappings) {
  # Handle empty transcript names gracefully
  if (length(transcript_names) == 0) {
    return(data.frame(
      transcript_name = character(0),
      preferred_name = character(0),
      formal_name = character(0),
      participant_type = character(0),
      student_id = character(0),
      stringsAsFactors = FALSE
    ))
  }
  # Start with transcript names
  lookup <- data.frame(
    transcript_name = transcript_names,
    preferred_name = NA_character_,
    formal_name = NA_character_,
    participant_type = NA_character_,
    student_id = NA_character_,
    stringsAsFactors = FALSE
  )

  # Apply existing mappings
  if (!is.null(name_mappings) && nrow(name_mappings) > 0) {
    for (i in seq_len(nrow(lookup))) {
      transcript_name <- lookup$transcript_name[i]

      # Find matching mapping
      mapping_idx <- which(name_mappings$transcript_name == transcript_name)
      if (length(mapping_idx) > 0) {
        mapping <- name_mappings[mapping_idx[1], ]
        lookup$preferred_name[i] <- mapping$preferred_name
        lookup$formal_name[i] <- mapping$formal_name
        lookup$participant_type[i] <- mapping$participant_type
        lookup$student_id[i] <- mapping$student_id
      }
    }
  }

  # Apply roster matching for unmatched names
  for (i in seq_len(nrow(lookup))) {
    if (is.na(lookup$preferred_name[i])) {
      transcript_name <- lookup$transcript_name[i]

      # Try to match with roster names
      roster_match <- find_roster_match(transcript_name, roster_names)
      if (!is.null(roster_match)) {
        lookup$preferred_name[i] <- roster_match$preferred_name
        lookup$formal_name[i] <- roster_match$formal_name
        lookup$participant_type[i] <- "enrolled_student"
        lookup$student_id[i] <- roster_match$student_id
      }
    }
  }

  # Fill in missing values
  lookup$preferred_name[is.na(lookup$preferred_name)] <- lookup$transcript_name[is.na(lookup$preferred_name)]
  lookup$formal_name[is.na(lookup$formal_name)] <- lookup$transcript_name[is.na(lookup$formal_name)]
  lookup$participant_type[is.na(lookup$participant_type)] <- "unknown"

  lookup
}

#' Find Roster Match
#'
#' Internal function to find a matching name in the roster.
#'
#' @param transcript_name Character string of transcript name
#' @param roster_names Character vector of roster names
#'
#' @return List with match information or NULL if no match
#' @keywords internal
find_roster_match <- function(transcript_name, roster_names) {
  # Normalize names for comparison
  normalized_transcript <- normalize_name_for_matching(transcript_name)
  normalized_roster <- normalize_name_for_matching(roster_names)

  # Find exact matches
  matches <- which(normalized_roster == normalized_transcript)

  if (length(matches) > 0) {
    # Return first match
    return(list(
      preferred_name = roster_names[matches[1]],
      formal_name = roster_names[matches[1]],
      student_id = NA_character_
    ))
  }

  # No match found
  NULL
}

#' Apply Name Matching
#'
#' Internal function to apply name matching to transcript data.
#'
#' @param transcript_data Data frame containing transcript data
#' @param name_lookup Data frame with name lookup information
#' @param roster_data Data frame containing roster data
#'
#' @return Data frame with matched names
#' @keywords internal
apply_name_matching <- function(transcript_data, name_lookup, roster_data) {
  # Create a copy of transcript data
  result <- transcript_data

  # Add name columns if they don't exist
  if (!"transcript_name" %in% names(result)) {
    # Look for existing name column
    name_cols <- c("name", "speaker_name", "participant_name")
    found_cols <- intersect(name_cols, names(result))

    if (length(found_cols) > 0) {
      result$transcript_name <- result[[found_cols[1]]]
    } else {
      stop("No name column found in transcript data", call. = FALSE)
    }
  }

  # Apply name matching
  for (i in seq_len(nrow(result))) {
    transcript_name <- result$transcript_name[i]

    # Find matching lookup entry
    lookup_idx <- which(name_lookup$transcript_name == transcript_name)
    if (length(lookup_idx) > 0) {
      lookup <- name_lookup[lookup_idx[1], ]

      # Add matched name columns
      result$preferred_name[i] <- lookup$preferred_name
      result$formal_name[i] <- lookup$formal_name
      result$participant_type[i] <- lookup$participant_type
      result$student_id[i] <- lookup$student_id
    }
  }

  # Ensure all required columns exist
  if (!"preferred_name" %in% names(result)) {
    result$preferred_name <- result$transcript_name
  }
  if (!"formal_name" %in% names(result)) {
    result$formal_name <- result$transcript_name
  }
  if (!"participant_type" %in% names(result)) {
    result$participant_type <- "unknown"
  }
  if (!"student_id" %in% names(result)) {
    result$student_id <- NA_character_
  }

  # Return result
  result
}
