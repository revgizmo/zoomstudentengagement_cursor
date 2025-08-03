#' Make a DF of Class Sections from the Student Roster
#'
#' This function creates a tibble that includes rows for each section (grouped by dept and course number) and student count in each.
#' @keywords sections
#'
#' @param roster_df A tibble listing the students enrolled in the class or classes.
#'   Must contain the following columns:
#'   - dept: character
#'   - course: character
#'   - section: character
#'
#' @return A tibble with the following columns:
#'   - dept: character
#'   - course: character
#'   - section: character
#'   - n: integer (count of students in each section)
#' @export
#'
#' @examples
#' # Load a sample roster from the package's extdata directory
#' roster_file <- system.file("extdata/roster.csv", package = "zoomstudentengagement")
#' roster_df <- readr::read_csv(roster_file, show_col_types = FALSE)
#' make_sections_df(roster_df = roster_df)
make_sections_df <- function(roster_df) {
  dept <- course <- section <- n <- NULL

  # Defensive: check for valid input
  if (!tibble::is_tibble(roster_df)) {
    stop("roster_df must be a tibble")
  }

  # Defensive: check for required columns
  required_cols <- c("dept", "course", "section")
  missing_cols <- setdiff(required_cols, names(roster_df))
  if (length(missing_cols) > 0) {
    stop("roster_df must contain columns: ", paste(missing_cols, collapse = ", "))
  }

  # Handle empty input
  if (nrow(roster_df) == 0) {
    return(tibble::tibble(
      dept = character(),
      course = character(),
      section = character(),
      n = integer()
    ))
  }

  # Ensure correct column types using base R
  roster_df$dept <- as.character(roster_df$dept)
  roster_df$course <- as.character(roster_df$course)
  roster_df$section <- as.character(roster_df$section)

  # Count students by section using base R
  # Create a unique identifier for each group
  roster_df$group_id <- paste(roster_df$dept, roster_df$course, roster_df$section, sep = "|")

  # Count occurrences of each group
  group_counts <- table(roster_df$group_id)

  # Create result dataframe
  group_names <- names(group_counts)
  group_parts <- strsplit(group_names, "\\|")

  result <- data.frame(
    dept = sapply(group_parts, function(x) x[1]),
    course = sapply(group_parts, function(x) x[2]),
    section = sapply(group_parts, function(x) x[3]),
    n = as.integer(group_counts),
    stringsAsFactors = FALSE
  )

  # Sort by dept, course, section using base R
  result <- result[order(result$dept, result$course, result$section), , drop = FALSE]

  # Convert to tibble to maintain expected return type
  return(tibble::as_tibble(result))
}
