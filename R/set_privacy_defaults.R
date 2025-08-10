#' Set Privacy Defaults
#'
#' Configure global privacy behavior for the package. The default on package
#' load is `mask`, which replaces personally identifiable fields with
#' FERPA-safe placeholders. Set to `"none"` to disable masking (not
#' recommended).
#'
#' @param privacy_level One of `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `"mask"`. Use `"ferpa_strict"` for maximum FERPA compliance.
#'
#' @return Invisibly returns the chosen privacy level.
#'
#' @seealso [ensure_privacy()]
#' @export
#'
#' @examples
#' # Set privacy to mask (default)
#' set_privacy_defaults("mask")
#'
#' # Set FERPA standard compliance
#' set_privacy_defaults("ferpa_standard")
#'
#' # Set maximum FERPA compliance
#' set_privacy_defaults("ferpa_strict")
#'
#' # Temporarily disable masking (will emit a warning)
#' set_privacy_defaults("none")
set_privacy_defaults <- function(privacy_level = c("ferpa_strict", "ferpa_standard", "mask", "none")) {
  privacy_level <- match.arg(privacy_level)

  if (identical(privacy_level, "none")) {
    warning(
      "Privacy disabled globally; outputs may contain identifiable data.",
      call. = FALSE
    )
  } else if (identical(privacy_level, "ferpa_strict")) {
    message(
      "FERPA strict mode enabled; maximum privacy protection applied.",
      call. = FALSE
    )
  } else if (identical(privacy_level, "ferpa_standard")) {
    message(
      "FERPA standard mode enabled; educational compliance protection applied.",
      call. = FALSE
    )
  }

  options(zoomstudentengagement.privacy_level = privacy_level)
  invisible(privacy_level)
}
