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
add_dead_air_rows <- function(df, dead_air_name = 'dead_air') {

  . <- comment_num <- end <- prev_end <- prior_dead_air <- start <- NULL

  if (tibble::is_tibble(df)) {
    df %>%
      dplyr::mutate(
        prev_end = dplyr::lag(end,
                              order_by = start,
                              default = hms::hms(0)),
        prior_dead_air = start - prev_end,
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
        # ,
        # comment_num = paste("dead_air", comment_num)
      ) %>%
      dplyr::bind_rows(df, .)
  }
}

# duration <-
#   name <-
#   name_flag <-
#   prev_end <-
#   prior_dead_air <-
#   time_flag <- timestamp <- wordcount <- prior_speaker <-
#

