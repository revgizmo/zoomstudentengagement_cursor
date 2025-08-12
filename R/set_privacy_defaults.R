#' Set Privacy Defaults
#'
#' Configure global privacy behavior for the package. The default on package
#' load is `mask`, which replaces personally identifiable fields with
#' FERPA-safe placeholders. Set to `"none"` to disable masking (not
#' recommended).
#'
#' @param privacy_level One of `c("ferpa_strict", "ferpa_standard", "mask", "none")`.
#'   Defaults to `"mask"`. Use `"ferpa_strict"` for maximum FERPA compliance.
#' @param unmatched_names_action Action to take when unmatched names are found.
#'   One of `c("stop", "warn")`. Defaults to `"stop"` for maximum privacy protection.
#'   Use `"warn"` for guided matching with user intervention.
#'
#' @return Invisibly returns a list with the chosen privacy level and unmatched names action.
#'
#' @seealso [ensure_privacy()], [safe_name_matching_workflow()]
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
#'
#' # Configure unmatched names behavior
#' set_privacy_defaults(
#'   privacy_level = "mask",
#'   unmatched_names_action = "warn"
#' )
set_privacy_defaults <- function(privacy_level = c("ferpa_strict", "ferpa_standard", "mask", "none"),
                                 unmatched_names_action = c("stop", "warn")) {
  privacy_level <- match.arg(privacy_level)
  unmatched_names_action <- match.arg(unmatched_names_action)

  # Validate privacy level
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

  # Validate unmatched names action
  if (identical(unmatched_names_action, "stop")) {
    message(
      "Unmatched names action set to 'stop' - maximum privacy protection enabled.",
      call. = FALSE
    )
  } else if (identical(unmatched_names_action, "warn")) {
    message(
      "Unmatched names action set to 'warn' - guided matching enabled.",
      call. = FALSE
    )
  }

  # Set global options
  options(
    zoomstudentengagement.privacy_level = privacy_level,
    zoomstudentengagement.unmatched_names_action = unmatched_names_action
  )
  
  # Return configuration invisibly
  invisible(list(
    privacy_level = privacy_level,
    unmatched_names_action = unmatched_names_action
  ))
}
