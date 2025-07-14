#' Add Dead Air Rows
#'
#' Take a tibble containing the comments from a Zoom recording transcript and return a tibble that adds rows for any time between transcribed comments, labeled with the `dead_air_name` provided (or the default value of 'dead_air').  The resuting tibble will have rows accounting for the time from the beginning of the first comment to the end of the last one.
#'




#' @param df A tibble containing the comments from a Zoom recording transcript.
#' @param dead_air_name Character string to label the `name` column in the added rows. Defaults to 'dead_air'.
#'
#' @return A tibble containing the comments from a Zoom recording transcript, with rows added for dead air.
#' @export
#'
#' @examples
#' add_dead_air_rows(df = "NULL")
#'

# CRAN compliance: global variables handled in package file

add_dead_air_rows <- function(df, dead_air_name = "dead_air") {
  # Removed local NULL assignments; handled by globalVariables above.

  if (tibble::is_tibble(df)) {
    # Ensure time columns are of type Period
    df <- df %>%
      dplyr::mutate(
        start = lubridate::as.period(start),
        end = lubridate::as.period(end)
      )

    # Create dead air rows
    dead_air_rows <- df %>%
      dplyr::mutate(
        prev_end = dplyr::lag(end,
          order_by = start,
          default = lubridate::period(0)
        ),
        prior_dead_air = as.numeric(start - prev_end, "seconds"),
        name = dead_air_name,
        comment = NA,
        duration = prior_dead_air,
        end = start,
        start = prev_end,
        raw_end = NA,
        raw_start = NA,
        wordcount = NA,
        prior_dead_air = NULL,
        prev_end = NULL
      )

    # Combine original and dead air rows
    dplyr::bind_rows(df, dead_air_rows)
  }
}

# duration <-
#   name <-
#   name_flag <-
#   prev_end <-
#   prior_dead_air <-
#   time_flag <- timestamp <- wordcount <- prior_speaker <-
#
