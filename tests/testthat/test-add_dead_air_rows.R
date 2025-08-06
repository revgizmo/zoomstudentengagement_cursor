# Test Plan for add_dead_air_rows function
#
# Function Behavior:
# 1. Returns NULL for non-tibble input
# 2. Converts start/end times to hms objects (not Period objects)
# 3. Adds dead air rows only for gaps between comments (prior_dead_air > 0)
# 4. Only adds optional columns (raw_end, raw_start, wordcount) if they exist in original dataframe
# 5. Uses custom dead air name if provided
# 6. Sorts by start time
# 7. Preserves original column structure

test_that("add_dead_air_rows returns NULL for non-tibble input", {
  # Test with data.frame input
  df <- data.frame(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:02:30"),
    end = c("00:01:30", "00:03:00"),
    duration = c(30, 30)
  )

  result <- add_dead_air_rows(df)
  expect_null(result)

  # Test with NULL input
  result_null <- add_dead_air_rows(NULL)
  expect_null(result_null)

  # Test with list input
  result_list <- add_dead_air_rows(list(a = 1, b = 2))
  expect_null(result_list)

  # Test with character input
  result_char <- add_dead_air_rows("not a tibble")
  expect_null(result_char)
})

test_that("add_dead_air_rows handles empty input", {
  # Test with empty tibble
  df <- tibble::tibble(
    name = character(),
    comment = character(),
    start = character(),
    end = character(),
    duration = numeric()
  )

  # The function returns empty tibble without optional columns for empty input
  result <- add_dead_air_rows(df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  # Empty tibble should not have optional columns since they don't exist in original
  expect_false(any(c("raw_end", "raw_start", "wordcount") %in% names(result)))
})

test_that("add_dead_air_rows handles single comment", {
  df <- tibble::tibble(
    name = "Alice",
    comment = "Hello",
    start = "00:01:00",
    end = "00:01:30",
    duration = 30
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2) # 1 original + 1 dead air row (gap from 0 to first comment)

  # Check that time columns are converted to hms objects
  expect_s3_class(result[["start"]], "hms")
  expect_s3_class(result[["end"]], "hms")

  # Check that optional columns are NOT added since they don't exist in original
  expect_false(any(c("raw_end", "raw_start", "wordcount") %in% names(result)))

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 1)
})

test_that("add_dead_air_rows handles two comments with gap", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:02:30"),
    end = c("00:01:30", "00:03:00"),
    duration = c(30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows (from 0 to first, and between first and second)

  # Check that time columns are converted to hms objects
  expect_s3_class(result[["start"]], "hms")
  expect_s3_class(result[["end"]], "hms")

  # Check that optional columns are NOT added since they don't exist in original
  expect_false(any(c("raw_end", "raw_start", "wordcount") %in% names(result)))

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 2)
})

test_that("add_dead_air_rows handles three comments with gaps", {
  df <- tibble::tibble(
    name = c("Alice", "Bob", "Charlie"),
    comment = c("Hello", "Hi there", "Goodbye"),
    start = c("00:01:00", "00:02:30", "00:04:00"),
    end = c("00:01:30", "00:03:00", "00:04:30"),
    duration = c(30, 30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 6) # 3 original + 3 dead air rows (from 0 to first, between first and second, between second and third)

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 3)
})

test_that("add_dead_air_rows handles consecutive comments (no gaps)", {
  df <- tibble::tibble(
    name = c("Alice", "Bob", "Charlie"),
    comment = c("Hello", "Hi there", "Goodbye"),
    start = c("00:01:00", "00:01:30", "00:02:00"),
    end = c("00:01:30", "00:02:00", "00:02:30"),
    duration = c(30, 30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 3 original + 1 dead air row (only gap from 0 to first comment)

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 1)
})

test_that("add_dead_air_rows handles custom dead air name", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:02:30"),
    end = c("00:01:30", "00:03:00"),
    duration = c(30, 30)
  )

  result <- add_dead_air_rows(df, dead_air_name = "silence")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check that custom dead air name is used
  dead_air_rows <- result[result$name == "silence", ]
  expect_equal(nrow(dead_air_rows), 2)
})

test_that("add_dead_air_rows handles unsorted input", {
  df <- tibble::tibble(
    name = c("Charlie", "Alice", "Bob"),
    comment = c("Goodbye", "Hello", "Hi there"),
    start = c("00:03:00", "00:01:00", "00:02:00"), # Unsorted
    end = c("00:03:30", "00:01:30", "00:02:30"),
    duration = c(30, 30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 6) # 3 original + 3 dead air rows

  # Check that result is sorted by start time
  expect_equal(result$name[1:3], c("Alice", "Bob", "Charlie"))
})

test_that("add_dead_air_rows handles existing optional columns", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:02:30"),
    end = c("00:01:30", "00:03:00"),
    duration = c(30, 30),
    raw_start = c("00:01:00", "00:02:30"),
    raw_end = c("00:01:30", "00:03:00"),
    wordcount = c(1, 2)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check that optional columns are preserved
  expect_true(all(c("raw_start", "raw_end", "wordcount") %in% names(result)))

  # Check that dead air rows have NA values for optional columns
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 2)
  expect_true(all(is.na(dead_air_rows$raw_start)))
  expect_true(all(is.na(dead_air_rows$raw_end)))
  expect_true(all(is.na(dead_air_rows$wordcount)))
})

test_that("add_dead_air_rows handles overlapping times", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:01:15"), # Overlapping
    end = c("00:01:30", "00:01:45"),
    duration = c(30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3) # 2 original + 1 dead air row (only gap from 0 to first comment)

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 1)
})

test_that("add_dead_air_rows preserves original column order", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:02:30"),
    end = c("00:01:30", "00:03:00"),
    duration = c(30, 30),
    transcript_file = c("file1.vtt", "file1.vtt")
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check that original columns are preserved in order
  original_cols <- c("name", "comment", "start", "end", "duration", "transcript_file")
  expect_equal(names(result)[1:6], original_cols)

  # Check that optional columns are NOT added since they don't exist in original
  expect_false(any(c("raw_end", "raw_start", "wordcount") %in% names(result)))
})

test_that("add_dead_air_rows handles hms time format", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = hms::as_hms(c("00:01:00", "00:02:30")),
    end = hms::as_hms(c("00:01:30", "00:03:00")),
    duration = c(30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check that time columns remain as hms objects
  expect_s3_class(result[["start"]], "hms")
  expect_s3_class(result[["end"]], "hms")
})

test_that("add_dead_air_rows handles large gaps", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:10:00"), # 8.5 minute gap
    end = c("00:01:30", "00:10:30"),
    duration = c(30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 2)
})

test_that("add_dead_air_rows handles very small gaps", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:01:30.5"), # 0.5 second gap
    end = c("00:01:30", "00:01:59.5"),
    duration = c(30, 29.5)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 2)
})

test_that("add_dead_air_rows handles edge case with zero duration", {
  df <- tibble::tibble(
    name = c("Alice", "Bob"),
    comment = c("Hello", "Hi there"),
    start = c("00:01:00", "00:02:30"),
    end = c("00:01:00", "00:02:30"), # Zero duration
    duration = c(0, 0)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 2)
})

test_that("add_dead_air_rows handles special characters in names and comments", {
  df <- tibble::tibble(
    name = c("José García", "O'Connor"),
    comment = c("¡Hola!", "Hello there!"),
    start = c("00:01:00", "00:02:30"),
    end = c("00:01:30", "00:03:00"),
    duration = c(30, 30)
  )

  result <- add_dead_air_rows(df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 2 original + 2 dead air rows

  # Check that original names and comments are preserved
  expect_equal(result$name[1:2], c("José García", "O'Connor"))
  expect_equal(result$comment[1:2], c("¡Hola!", "Hello there!"))

  # Check dead air rows
  dead_air_rows <- result[result$name == "dead_air", ]
  expect_equal(nrow(dead_air_rows), 2)
})
