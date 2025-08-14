#' Privacy Audit
#'
#' Summarize which identifier columns were present and how many values were masked.
#'
#' @param data A tibble to audit.
#' @param id_columns Columns treated as identifiers (same default as ensure_privacy).
#' @return A tibble with columns: column, values, non_empty, masked_estimate.
#' @export
privacy_audit <- function(
    data,
    id_columns = c("preferred_name", "name", "first_last", "name_raw", "student_id", "email")) {
  if (!tibble::is_tibble(data)) stop("`data` must be a tibble")
  present <- intersect(id_columns, names(data))
  if (length(present) == 0) {
    return(tibble::tibble(
      column = character(0),
      values = integer(0),
      non_empty = integer(0),
      masked_estimate = integer(0)
    ))
  }
  rows <- lapply(present, function(col) {
    v <- data[[col]]
    total <- length(v)
    non_empty <- sum(!is.na(v) & nzchar(as.character(v)))
    masked <- sum(grepl("^Student\\s+\\d+$", as.character(v)))
    tibble::tibble(column = col, values = total, non_empty = non_empty, masked_estimate = masked)
  })
  dplyr::bind_rows(rows)
}
