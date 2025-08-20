#' Internal diagnostics helpers (quiet-by-default)
#'
#' These helpers centralize diagnostic output policy. By default, diagnostics
#' are suppressed. Users can enable verbose diagnostics by setting the option
#' `options(zoomstudentengagement.verbose = TRUE)`.
#'
#' @name zse_diagnostics
#' @keywords internal
NULL

# Return TRUE if verbose diagnostics are enabled
is_verbose <- function() {
  isTRUE(getOption("zoomstudentengagement.verbose", FALSE))
}

# Conditionally emit a message when verbose is enabled
diag_message <- function(...) {
  if (is_verbose() && Sys.getenv("TESTTHAT") != "true") {
    message(...)
  }
  invisible(NULL)
}

# Conditionally emit cat-style output when verbose is enabled
diag_cat <- function(...) {
  if (is_verbose() && Sys.getenv("TESTTHAT") != "true") {
    cat(...)
  }
  invisible(NULL)
}
