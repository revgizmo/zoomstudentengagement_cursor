#' Error handling helpers
#'
#' Provides a small wrapper around `rlang::abort()` to standardize
#' error classes within the package for precise testing and user handling.
#'
#' @param message Character message describing the error
#' @param class Additional error class(es) appended after `"zse_error"`
#'
#' @return This function does not return; it signals an error.
#' @keywords internal
#' @examples
#' \dontrun{
#' abort_zse("Invalid input", class = "zse_schema_error")
#' }
abort_zse <- function(message, class = character()) {
  rlang::abort(message, class = c("zse_error", class))
}
