#' Ensure Privacy for Outputs
#'
#' Applies privacy rules to objects before they are returned, written, or
#' plotted. By default, masks personally identifiable information in tabular
#' data to FERPA-safe placeholders.
#'
#' The default behavior is controlled by the global option
#' `zoomstudentengagement.privacy_level`, which is set to "mask" on package
#' load. Use `set_privacy_defaults()` to change at runtime.
#'
#' @param x An object to make privacy-safe. Currently supports `data.frame` or
#'   `tibble`. Other object types are returned unchanged.
#' @param privacy_level Privacy level to apply. One of `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `getOption("zoomstudentengagement.privacy_level", "mask")`.
#' @param id_columns Character vector of column names to treat as identifiers.
#'   Defaults to common name/identifier columns.
#'
#' @return The object with privacy rules applied. For data frames, the same
#'   structure is preserved with identifying fields masked when appropriate.
#'
#' @seealso [set_privacy_defaults()]
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
                             "name_raw", "student_id", "email"
                           )) {
  # Validate privacy level
  valid_levels <- c("ferpa_strict", "ferpa_standard", "mask", "none")
  if (!privacy_level %in% valid_levels) {
    stop("Invalid privacy_level. Must be one of: ", paste(valid_levels, collapse = ", "), call. = FALSE)
  }

  # If privacy is explicitly disabled, warn and return unmodified
  if (identical(privacy_level, "none")) {
    warning(
      "Privacy disabled; outputs may contain identifiable data.",
      call. = FALSE
    )
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
