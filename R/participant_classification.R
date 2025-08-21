#' Classify Participants (Pure, Privacy-Aware)
#'
#' Given transcript utterances, a student roster, and an optional lookup,
#' returns a data frame with classification columns that identify each
#' utterance's `clean_name`, `participant_type`, `student_id`, and
#' `is_matched`. This function is pure and performs no filesystem writes.
#'
#' Privacy defaults are applied to outputs. Use this to classify participants
#' BEFORE computing metrics so that downstream functions operate on a
#' privacy-safe, idempotent representation.
#'
#' @param transcript_df Data frame of transcript utterances.
#'   Must contain one of: `transcript_name`, `name`, `speaker_name`, `participant_name`.
#' @param roster_df Data frame of enrolled students.
#'   Should contain one of: `first_last`, `preferred_name`, `formal_name`, `name`, `student_name`,
#'   and optionally `student_id`.
#' @param lookup_df Optional data frame of name mappings as produced by
#'   `read_lookup_safely()`.
#' @param privacy_level One of `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `getOption("zoomstudentengagement.privacy_level", "mask")`.
#'
#' @return The `transcript_df` augmented with columns:
#'   `clean_name`, `participant_type`, `student_id`, `is_matched`.
#' @export
classify_participants <- function(transcript_df,
                                  roster_df,
                                  lookup_df = NULL,
                                  privacy_level = getOption(
                                    "zoomstudentengagement.privacy_level",
                                    "mask"
                                  )) {
  # Validate inputs
  if (!is.data.frame(transcript_df)) {
    stop("transcript_df must be a data frame", call. = FALSE)
  }
  if (!is.data.frame(roster_df)) {
    stop("roster_df must be a data frame", call. = FALSE)
  }

  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ",
      paste(valid_levels, collapse = ", "),
      call. = FALSE
    )
  }

  # Ensure transcript has a name column
  transcript_name_columns <- c("transcript_name", "name", "speaker_name", "participant_name")
  name_col <- intersect(transcript_name_columns, names(transcript_df))
  if (length(name_col) == 0) {
    stop("Transcript data lacks a usable name column", call. = FALSE)
  }
  name_col <- name_col[1]

  # Extract names
  extract_transcript_names <- function(df) {
    vals <- df[[name_col]]
    if (is.factor(vals)) vals <- as.character(vals)
    enc2utf8(as.character(vals))
  }
  transcript_names <- extract_transcript_names(transcript_df)

  # Build roster name vector
  roster_name_columns <- c("first_last", "preferred_name", "formal_name", "name", "student_name")
  roster_name_col <- intersect(roster_name_columns, names(roster_df))
  if (length(roster_name_col) == 0 || nrow(roster_df) == 0) {
    stop("Roster appears empty or lacks required name columns.", call. = FALSE)
  }
  roster_name_col <- roster_name_col[1]
  roster_names <- enc2utf8(as.character(roster_df[[roster_name_col]]))

  # Normalize lookup if provided
  if (!is.null(lookup_df)) {
    lookup_df <- tryCatch(.normalize_lookup_df(lookup_df), error = function(e) lookup_df)
  }

  # Create lookup table: existing mappings take precedence
  create_lookup <- function(transcript_names, roster_names, lookup_df) {
    base <- data.frame(
      transcript_name = enc2utf8(as.character(transcript_names)),
      preferred_name = NA_character_,
      formal_name = NA_character_,
      participant_type = NA_character_,
      student_id = NA_character_,
      stringsAsFactors = FALSE
    )
    if (!is.null(lookup_df) && nrow(lookup_df) > 0) {
      for (i in seq_len(nrow(base))) {
        nm <- base$transcript_name[i]
        idx <- which(lookup_df$transcript_name == nm)
        if (length(idx) > 0) {
          m <- lookup_df[idx[1], ]
          base$preferred_name[i] <- m$preferred_name
          base$formal_name[i] <- m$formal_name
          base$participant_type[i] <- m$participant_type
          base$student_id[i] <- m$student_id
        }
      }
    }
    # Fill from roster exact matches where still missing
    normalize_name <- function(x) {
      x <- tolower(enc2utf8(as.character(x)))
      x <- gsub("\\s+", " ", trimws(x))
      x
    }
    norm_roster <- normalize_name(roster_names)
    for (i in seq_len(nrow(base))) {
      if (is.na(base$preferred_name[i]) || trimws(base$preferred_name[i]) == "") {
        nm <- base$transcript_name[i]
        idx <- which(norm_roster == normalize_name(nm))
        if (length(idx) > 0) {
          base$preferred_name[i] <- roster_names[idx[1]]
          base$formal_name[i] <- roster_names[idx[1]]
          base$participant_type[i] <- "enrolled_student"
          # If roster has student_id, map it
          if ("student_id" %in% names(roster_df)) {
            base$student_id[i] <- as.character(roster_df$student_id[idx[1]])
          }
        }
      }
    }
    # Default fill-ins
    base$preferred_name[is.na(base$preferred_name)] <- base$transcript_name[is.na(base$preferred_name)]
    base$formal_name[is.na(base$formal_name)] <- base$transcript_name[is.na(base$formal_name)]
    base$participant_type[is.na(base$participant_type)] <- "unknown"
    base
  }

  lookup <- create_lookup(transcript_names, roster_names, lookup_df)

  # Join back to transcript_df
  result <- transcript_df
  # Ensure transcript_name column is present for join
  if (!"transcript_name" %in% names(result)) {
    result$transcript_name <- result[[name_col]]
  }

  # Row-wise fill from lookup
  result$clean_name <- NA_character_
  result$participant_type <- NA_character_
  result$student_id <- NA_character_
  result$is_matched <- FALSE
  for (i in seq_len(nrow(result))) {
    nm <- result$transcript_name[i]
    idx <- which(lookup$transcript_name == nm)
    if (length(idx) > 0) {
      lk <- lookup[idx[1], ]
      result$clean_name[i] <- if (!is.na(lk$preferred_name)) lk$preferred_name else nm
      result$participant_type[i] <- if (!is.na(lk$participant_type)) lk$participant_type else "unknown"
      result$student_id[i] <- if (!is.na(lk$student_id)) lk$student_id else NA_character_
      result$is_matched[i] <- !is.na(lk$preferred_name) && lk$preferred_name != nm
    } else {
      result$clean_name[i] <- nm
      result$participant_type[i] <- "unknown"
      result$student_id[i] <- NA_character_
      result$is_matched[i] <- FALSE
    }
  }

  # Apply privacy defaults to outputs unless 'none'
  if (!identical(privacy_level, "none")) {
    result <- ensure_privacy(result, privacy_level = privacy_level)
  }
  result
}


