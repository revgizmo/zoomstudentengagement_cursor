#' Lookup Merge Utilities (Safe, Transactional, UTF-8)
#'
#' Utilities to safely read, merge, and write the participant lookup
#' configuration (`section_names_lookup.csv`). All operations are
#' read-then-merge in memory; writes are opt-in and transactional with
#' timestamped backups to prevent accidental data loss.
#'
#' Expected columns in lookup data frame:
#'   - transcript_name
#'   - preferred_name
#'   - formal_name
#'   - participant_type (e.g., instructor, enrolled_student, guest, unknown)
#'   - student_id
#'   - notes (optional)
#'
#' @family lookup_utils
NULL

.lookup_expected_columns <- function() {
  c(
    "transcript_name",
    "preferred_name",
    "formal_name",
    "participant_type",
    "student_id",
    "notes"
  )
}

.coerce_to_utf8 <- function(x) {
  if (is.null(x)) return(x)
  if (is.factor(x)) x <- as.character(x)
  if (!is.character(x)) return(x)
  enc2utf8(x)
}

.normalize_lookup_df <- function(df) {
  if (is.null(df)) {
    df <- data.frame(stringsAsFactors = FALSE)
  }
  # Ensure UTF-8 and expected columns exist
  expected <- .lookup_expected_columns()
  for (col in expected) {
    if (!col %in% names(df)) {
      df[[col]] <- rep(NA_character_, nrow(df))
    }
  }
  # Subset and order columns deterministically
  df <- df[expected]
  # Coerce character columns to UTF-8
  for (nm in names(df)) {
    df[[nm]] <- .coerce_to_utf8(df[[nm]])
  }
  # Replace NA student_id for instructors with constant
  is_instructor <- !is.na(df$participant_type) & df$participant_type == "instructor"
  df$student_id[is_instructor & is.na(df$student_id)] <- "INSTRUCTOR"
  # Ensure participant_type known set
  df$participant_type[is.na(df$participant_type)] <- "unknown"
  # Remove completely empty rows (no transcript_name and no preferred_name)
  empty_rows <- (is.na(df$transcript_name) | trimws(df$transcript_name) == "") &
    (is.na(df$preferred_name) | trimws(df$preferred_name) == "")
  if (length(empty_rows) > 0 && any(empty_rows)) {
    df <- df[!empty_rows, , drop = FALSE]
  }
  df
}

#' Read Lookup Safely
#'
#' Reads a lookup CSV safely: normalizes columns, coerces to UTF-8, and
#' returns an empty (0-row) normalized data frame if the file is missing.
#'
#' @param path Character. Path to the lookup CSV file.
#'
#' @return A normalized data frame with expected columns.
#' @export
read_lookup_safely <- function(path) {
  if (!is.character(path) || length(path) != 1) {
    stop("path must be a single character string", call. = FALSE)
  }
  if (!file.exists(path)) {
    return(.normalize_lookup_df(data.frame(stringsAsFactors = FALSE)))
  }
  df <- utils::read.csv(path, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
  .normalize_lookup_df(df)
}

#' Merge Lookup Preserving Existing Rows
#'
#' Merges an additional lookup data frame into an existing one while
#' preserving existing rows. New information fills only missing fields.
#' Duplicates are removed deterministically by `transcript_name` keeping
#' the first non-empty values per field.
#'
#' @param existing_df Data frame. Existing normalized lookup.
#' @param add_df Data frame. Additional rows to merge (will be normalized).
#'
#' @return A merged, normalized, de-duplicated data frame.
#' @export
merge_lookup_preserve <- function(existing_df, add_df) {
  base <- .normalize_lookup_df(existing_df)
  add <- .normalize_lookup_df(add_df)

  combined <- rbind(base, add)
  # Deterministic ordering by transcript_name then participant_type
  ord <- order(tolower(ifelse(is.na(combined$transcript_name), "", combined$transcript_name)),
               combined$participant_type, na.last = TRUE)
  combined <- combined[ord, , drop = FALSE]

  # Deduplicate by transcript_name: keep first non-empty values per column
  if (nrow(combined) == 0) return(combined)
  keep_idx <- rep(FALSE, nrow(combined))
  last_name <- NULL
  aggregator <- NULL
  out <- list()

  flush_row <- function(agg) {
    # Fill preferred/formal with transcript_name if still empty
    if (is.na(agg$preferred_name) || trimws(agg$preferred_name) == "") {
      agg$preferred_name <- agg$transcript_name
    }
    if (is.na(agg$formal_name) || trimws(agg$formal_name) == "") {
      agg$formal_name <- agg$transcript_name
    }
    # Ensure participant_type
    if (is.na(agg$participant_type) || trimws(agg$participant_type) == "") {
      agg$participant_type <- "unknown"
    }
    agg
  }

  for (i in seq_len(nrow(combined))) {
    row <- combined[i, , drop = FALSE]
    name <- ifelse(is.na(row$transcript_name), "", row$transcript_name)
    if (is.null(last_name) || !identical(tolower(last_name), tolower(name))) {
      if (!is.null(aggregator)) out[[length(out) + 1]] <- flush_row(aggregator)
      aggregator <- row
      last_name <- name
    } else {
      # Fill only missing fields from new row
      fields <- names(row)
      for (col in fields) {
        if (is.na(aggregator[[col]]) || trimws(aggregator[[col]]) == "") {
          aggregator[[col]] <- row[[col]]
        }
      }
    }
  }
  if (!is.null(aggregator)) out[[length(out) + 1]] <- flush_row(aggregator)

  result <- do.call(rbind, out)
  .normalize_lookup_df(result)
}

#' Transactional Write with Backup
#'
#' Writes the lookup data frame to CSV with a timestamped backup of any
#' existing file and an atomic replace (write to temp, then rename).
#'
#' @param df Data frame. The lookup to write (will be normalized).
#' @param path Character. Target CSV path.
#'
#' @return Invisibly returns the path written.
#' @export
write_lookup_transactional <- function(df, path) {
  if (!is.character(path) || length(path) != 1) {
    stop("path must be a single character string", call. = FALSE)
  }
  df <- .normalize_lookup_df(df)
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  # Backup if exists
  if (file.exists(path)) {
    backup <- paste0(path, ".backup.", format(Sys.time(), "%Y%m%d_%H%M%S"))
    ok <- file.copy(path, backup, overwrite = FALSE)
    if (!isTRUE(ok)) {
      stop("Failed to create backup for ", path, call. = FALSE)
    }
  }
  # Write to temp file first
  tmp <- paste0(path, ".tmp.", Sys.getpid())
  utils::write.csv(df, tmp, row.names = FALSE, fileEncoding = "UTF-8")
  # Atomic-ish replace
  ok <- file.rename(tmp, path)
  if (!isTRUE(ok)) {
    # Attempt fallback: remove and rename
    if (file.exists(path)) unlink(path)
    ok2 <- file.rename(tmp, path)
    if (!isTRUE(ok2)) {
      unlink(tmp)
      stop("Failed to write lookup file atomically: ", path, call. = FALSE)
    }
  }
  invisible(path)
}

#' Conditionally Write Lookup (Read-Only Gate)
#'
#' Helper that writes the lookup only when `allow_write` is TRUE. Useful for
#' scripts and Rmds to prevent accidental overwrites. When `allow_write` is
#' FALSE, performs no side effects and returns `FALSE`.
#'
#' @param df Data frame. Lookup to write (normalized internally).
#' @param path Character. Target CSV path.
#' @param allow_write Logical. Default `FALSE` (read-only).
#'
#' @return Logical indicating whether a write occurred.
#' @export
conditionally_write_lookup <- function(df, path, allow_write = FALSE) {
  if (!isTRUE(allow_write)) return(FALSE)
  write_lookup_transactional(df, path)
  TRUE
}

#' Ensure Instructor Rows (Pure Merge)
#'
#' Returns a merged lookup that includes instructor rows for a given
#' instructor name, preserving all existing rows. No side effects.
#'
#' @param existing_df Data frame. Existing lookup.
#' @param instructor_name Character. Instructor display name.
#'
#' @return A merged lookup including instructor rows.
#' @export
ensure_instructor_rows <- function(existing_df, instructor_name) {
  if (!is.character(instructor_name) || length(instructor_name) != 1) {
    stop("instructor_name must be a single character string", call. = FALSE)
  }
  base <- .normalize_lookup_df(existing_df)
  instructor_df <- data.frame(
    transcript_name = instructor_name,
    preferred_name = instructor_name,
    formal_name = instructor_name,
    participant_type = "instructor",
    student_id = "INSTRUCTOR",
    notes = "Primary instructor name - add variations manually if needed",
    stringsAsFactors = FALSE
  )
  merge_lookup_preserve(base, instructor_df)
}


