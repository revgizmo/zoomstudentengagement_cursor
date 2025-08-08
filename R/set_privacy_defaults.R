#' Set Privacy Defaults
#'
#' Configure global privacy behavior for the package. The default on package
#' load is `mask`, which replaces personally identifiable fields with
#' FERPA-safe placeholders. Set to `"none"` to disable masking (not
#' recommended).
#'
#' @param privacy_level One of `c("mask", "none")`. Defaults to `"mask"`.
#'
#' @return Invisibly returns the chosen privacy level.
#' @export
#'
#' @examples
#' # Set privacy to mask (default)
#' set_privacy_defaults("mask")
#'
#' # Temporarily disable masking (will emit a warning)
#' set_privacy_defaults("none")
set_privacy_defaults <- function(privacy_level = c("mask", "none")) {
  privacy_level <- match.arg(privacy_level)
  if (identical(privacy_level, "none")) {
    warning(
      "Privacy disabled globally; outputs may contain identifiable data.",
      call. = FALSE
    )
  }
  options(zoomstudentengagement.privacy_level = privacy_level)
  invisible(privacy_level)
}

