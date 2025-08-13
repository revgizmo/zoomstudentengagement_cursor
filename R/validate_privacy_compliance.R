#' Validate Privacy Compliance
#'
#' Scans data objects to ensure no real names appear in outputs when privacy
#' masking is enabled. This function performs exact matching to detect privacy
#' violations and stops processing if real names are found.
#'
#' @param data Data object to validate (data.frame, tibble, or list)
#' @param privacy_level Privacy level to validate against. One of
#'   `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `getOption("zoomstudentengagement.privacy_level", "mask")`.
#' @param real_names Character vector of real names to check against.
#'   If NULL, uses common name patterns to detect potential violations.
#' @param stop_on_violation Logical, whether to stop with error on privacy violation.
#'   Defaults to TRUE for maximum privacy protection.
#'
#' @return TRUE if compliant, error if violation found and stop_on_violation = TRUE
#' @export
#'
#' @examples
#' # Validate privacy compliance
#' df <- tibble::tibble(
#'   name = c("Student_01", "Student_02"),
#'   score = c(85, 92)
#' )
#' validate_privacy_compliance(df)
#'
#' # Check with specific real names
#' real_names <- c("John Smith", "Jane Doe")
#' validate_privacy_compliance(df, real_names = real_names)
validate_privacy_compliance <- function(data,
                                        privacy_level = getOption(
                                          "zoomstudentengagement.privacy_level",
                                          "mask"
                                        ),
                                        real_names = NULL,
                                        stop_on_violation = TRUE) {
  # Validate inputs
  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ",
      paste(valid_levels, collapse = ", "),
      call. = FALSE
    )
  }

  if (!is.logical(stop_on_violation) || length(stop_on_violation) != 1) {
    stop("stop_on_violation must be a single logical value", call. = FALSE)
  }

  # If privacy is disabled, always return TRUE
  if (identical(privacy_level, "none")) {
    return(TRUE)
  }

  # If no data provided, return TRUE
  if (is.null(data)) {
    return(TRUE)
  }

  # Extract all character values from the data
  character_values <- extract_character_values(data)

  # If no character values found, return TRUE
  if (length(character_values) == 0) {
    return(TRUE)
  }

  # Check for privacy violations
  violations <- detect_privacy_violations(
    character_values,
    real_names,
    privacy_level
  )

  # If violations found, handle according to stop_on_violation
  if (length(violations) > 0) {
    violation_msg <- paste(
      "Privacy violation detected:",
      "Real names found in output data:",
      paste(violations, collapse = ", "),
      "\nThis indicates a bug in the privacy implementation.",
      "Please report this issue immediately."
    )

    if (stop_on_violation) {
      stop(violation_msg, call. = FALSE)
    } else {
      warning(violation_msg, call. = FALSE)
    }
  }

  # Return TRUE if no violations
  TRUE
}

#' Extract Character Values from Data Object
#'
#' Internal function to extract all character values from various data types
#' for privacy validation.
#'
#' @param data Data object to extract character values from
#'
#' @return Character vector of all character values found
#' @keywords internal
extract_character_values <- function(data) {
  # Handle different data types
  if (is.data.frame(data)) {
    # Extract character columns
    char_cols <- sapply(data, is.character)
    if (any(char_cols)) {
      values <- unlist(data[char_cols], use.names = FALSE)
      return(values[!is.na(values) & nchar(trimws(values)) > 0])
    }
  } else if (is.list(data)) {
    # Recursively extract from list elements
    values <- unlist(lapply(data, extract_character_values), use.names = FALSE)
    return(values[!is.na(values) & nchar(trimws(values)) > 0])
  } else if (is.character(data)) {
    # Direct character vector
    return(data[!is.na(data) & nchar(trimws(data)) > 0])
  }

  # Return empty character vector for unsupported types
  character(0)
}

#' Detect Privacy Violations
#'
#' Internal function to detect privacy violations by checking for real names
#' in character values.
#'
#' @param character_values Character vector to check
#' @param real_names Specific real names to check against (optional)
#' @param privacy_level Privacy level for validation
#'
#' @return Character vector of detected violations
#' @keywords internal
detect_privacy_violations <- function(character_values, real_names, privacy_level) {
  violations <- character(0)

  # If specific real names provided, check for exact matches
  if (!is.null(real_names) && length(real_names) > 0) {
    # Normalize both sets for comparison
    normalized_values <- normalize_name_for_matching(character_values)
    normalized_names <- normalize_name_for_matching(real_names)

    # Find exact matches
    matches <- normalized_values %in% normalized_names
    if (any(matches)) {
      violations <- c(violations, character_values[matches])
    }
  }

  # Check for common name patterns that might indicate privacy violations
  # This is a conservative approach - only flag obvious violations
  name_patterns <- c(
    # Common name patterns (first + last) - more specific to avoid false positives
    "^[A-Z][a-z]{1,20}\\s+[A-Z][a-z]{1,20}$",
    # Names with titles
    "^(Dr|Prof|Professor|Mr|Mrs|Ms|Miss)\\.?\\s+[A-Z][a-z]{1,20}\\s+[A-Z][a-z]{1,20}$",
    # Names with middle initials
    "^[A-Z][a-z]{1,20}\\s+[A-Z]\\.\\s+[A-Z][a-z]{1,20}$"
  )

  for (pattern in name_patterns) {
    matches <- grepl(pattern, character_values, perl = TRUE)
    if (any(matches)) {
      # Only flag if they don't look like masked names
      potential_violations <- character_values[matches]
      # Exclude obvious masked names (Student_XX, etc.)
      not_masked <- !grepl("^(Student|Guest|Instructor)_\\d+$", potential_violations)

      # Exclude common non-name phrases that might match patterns
      common_phrases <- c(
        "World Testing Report", "Test Results Summary", "Test Report",
        "Data Analysis", "Report Summary", "Analysis Results",
        "Testing Report", "Results Summary", "Summary Report",
        "Test Summary", "Report Results", "Analysis Report"
      )
      not_common_phrase <- !potential_violations %in% common_phrases

      # Only flag if both conditions are met
      final_violations <- potential_violations[not_masked & not_common_phrase]
      if (length(final_violations) > 0) {
        violations <- c(violations, final_violations)
      }
    }
  }

  # Remove duplicates and return
  unique(violations)
}
