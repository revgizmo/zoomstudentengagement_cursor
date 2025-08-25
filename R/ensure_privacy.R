#' Ensure Privacy for Outputs
#'
#' Applies privacy rules to objects before they are returned, written, or
#' plotted. By default, masks personally identifiable information in tabular
#' data to FERPA-safe placeholders.
#'
#' **CRITICAL ETHICAL COMPLIANCE**: This function is designed to promote
#' participation equity and educational improvement, NOT surveillance. All
#' outputs are automatically anonymized by default to protect student privacy
#' and ensure FERPA compliance.
#'
#' The default behavior is controlled by the global option
#' `zoomstudentengagement.privacy_level`, which is set to "mask" on package
#' load. Use `set_privacy_defaults()` to change at runtime.
#'
#' @param x An object to make privacy-safe. Currently supports `data.frame` or
#'   `tibble`. Other object types are returned unchanged.
#' @param privacy_level Privacy level to apply. One of `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `getOption("zoomstudentengagement.privacy_level", "mask")`.
#'   **WARNING**: Setting to "none" disables privacy protection and may violate
#'   FERPA requirements.
#' @param id_columns Character vector of column names to treat as identifiers.
#'   Defaults to common name/identifier columns.
#' @param audit_log Whether to log privacy operations for compliance tracking.
#'   Defaults to TRUE for maximum transparency.
#'
#' @return The object with privacy rules applied. For data frames, the same
#'   structure is preserved with identifying fields masked when appropriate.
#'
#' @seealso [set_privacy_defaults()], [validate_ethical_use()]
#' @export
#'
#' @examples
#' # Data frame masking example
#' df <- tibble::tibble(
#'   section = c("A", "A", "B"),
#'   preferred_name = c("Alice Johnson", "Bob Lee", "Cara Diaz"),
#'   session_ct = c(3, 5, 2)
#' )
#' ensure_privacy(df)
ensure_privacy <- function(x,
                           privacy_level = getOption(
                             "zoomstudentengagement.privacy_level",
                             "mask"
                           ),
                           id_columns = c(
                             "preferred_name", "name", "first_last",
                             "name_raw", "student_id", "email", "transcript_name", "formal_name"
                           ),
                           audit_log = TRUE) {
  # Validate privacy level
  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ", paste(valid_levels, collapse = ", "), call. = FALSE)
  }

  # If privacy is explicitly disabled, warn and return unmodified
  if (identical(privacy_level, "none")) {
    warning(
      "CRITICAL: Privacy disabled; outputs may contain identifiable data and violate FERPA requirements.",
      call. = FALSE
    )

    # Log the privacy violation for audit purposes
    if (audit_log) {
      log_privacy_operation(
        operation = "privacy_disabled",
        privacy_level = privacy_level,
        timestamp = Sys.time(),
        warning_issued = TRUE
      )
    }

    return(x)
  }

  # FERPA strict level - most comprehensive masking
  if (identical(privacy_level, "ferpa_strict")) {
    id_columns <- c(
      id_columns,
      "email", "email_address", "e_mail",
      "phone", "phone_number", "telephone",
      "address", "street_address", "home_address",
      "ssn", "social_security", "social_security_number",
      "birth_date", "birthday", "date_of_birth",
      "parent_name", "guardian_name",
      "instructor_name", "instructor_id"
    )
  }

  # FERPA standard level - standard educational compliance
  if (identical(privacy_level, "ferpa_standard")) {
    id_columns <- c(
      id_columns,
      "email", "email_address", "e_mail",
      "phone", "phone_number", "telephone",
      "instructor_name", "instructor_id"
    )
  }

  # Only handle tabular data for MVP; return other objects unchanged
  if (!is.data.frame(x)) {
    return(x)
  }

  # Log privacy operation for audit purposes
  if (audit_log) {
    log_privacy_operation(
      operation = "privacy_applied",
      privacy_level = privacy_level,
      data_rows = nrow(x),
      data_columns = ncol(x),
      timestamp = Sys.time()
    )
  }

  df <- x

  # Identify columns to mask while preserving structure
  columns_to_mask <- intersect(id_columns, names(df))
  if (length(columns_to_mask) == 0) {
    # Nothing to mask; return as-is
    if (tibble::is_tibble(x)) {
      return(tibble::as_tibble(df))
    } else {
      return(df)
    }
  }

  mask_values <- function(values) {
    # Convert to character for stable mapping; preserve NAs and empty strings
    chr <- as.character(values)
    # Unique non-empty, non-NA values for deterministic mapping
    unique_vals <- unique(chr[!is.na(chr) & nzchar(chr)])
    unique_vals <- sort(unique_vals)
    if (length(unique_vals) == 0) {
      return(chr)
    }
    labels <- paste(
      "Student",
      stringr::str_pad(seq_along(unique_vals), width = 2, pad = "0")
    )
    mapping <- stats::setNames(labels, unique_vals)
    to_mask <- !is.na(chr) & nzchar(chr)
    chr[to_mask] <- unname(mapping[chr[to_mask]])
    chr
  }

  for (col_name in columns_to_mask) {
    # Mask only character or factor columns
    if (is.character(df[[col_name]]) || is.factor(df[[col_name]])) {
      df[[col_name]] <- mask_values(df[[col_name]])
    }
  }

  # Preserve tibble class if input was a tibble
  if (tibble::is_tibble(x)) {
    df <- tibble::as_tibble(df)
  }

  df
}

#' Log Privacy Operations
#'
#' Internal function to log privacy operations for audit and compliance purposes.
#' This function maintains a record of privacy-related operations for institutional
#' review and FERPA compliance.
#'
#' @param operation Type of operation performed
#' @param privacy_level Privacy level used
#' @param timestamp When the operation occurred
#' @param data_rows Number of rows processed (if applicable)
#' @param data_columns Number of columns processed (if applicable)
#' @param warning_issued Whether a warning was issued
#'
#' @keywords internal
log_privacy_operation <- function(operation,
                                  privacy_level,
                                  timestamp = Sys.time(),
                                  data_rows = NULL,
                                  data_columns = NULL,
                                  warning_issued = FALSE) {
  # Create log entry
  log_entry <- list(
    timestamp = timestamp,
    operation = operation,
    privacy_level = privacy_level,
    data_rows = data_rows,
    data_columns = data_columns,
    warning_issued = warning_issued,
    session_id = Sys.getpid()
  )

  # Store in global environment for session tracking
  log_key <- paste0("zse_privacy_log_", format(timestamp, "%Y%m%d_%H%M%S"))
  assign(log_key, log_entry, envir = .GlobalEnv)

  # Optionally write to file if logging is enabled
  log_file <- getOption("zoomstudentengagement.privacy_log_file", NULL)
  if (!is.null(log_file) && is.character(log_file)) {
    tryCatch(
      {
        log_line <- paste(
          format(timestamp, "%Y-%m-%d %H:%M:%S"),
          operation,
          privacy_level,
          ifelse(is.null(data_rows), "NA", data_rows),
          ifelse(is.null(data_columns), "NA", data_columns),
          ifelse(warning_issued, "WARNING", "OK"),
          sep = "\t"
        )
        write(log_line, file = log_file, append = TRUE)
      },
      error = function(e) {
        # Silently fail if logging fails
        NULL
      }
    )
  }

  invisible(log_entry)
}
