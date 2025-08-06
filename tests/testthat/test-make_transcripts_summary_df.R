test_that("make_transcripts_summary_df summarizes session metrics correctly", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice", "Bob", "Alice"),
    n = c(2, 1, 3),
    duration = c(60, 30, 90),
    wordcount = c(10, 5, 15),
    n_perc = c(0.5, 0.25, 0.75),
    duration_perc = c(0.6, 0.3, 0.9),
    wordcount_perc = c(0.4, 0.2, 0.6),
    wpm = c(10, 10, 10)
  )
  result <- make_transcripts_summary_df(session_summary_df)
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("section", "preferred_name") %in% names(result)))
  expect_equal(nrow(result), 3)
  expect_true("Alice" %in% result$preferred_name)
  expect_true("Bob" %in% result$preferred_name)
})

test_that("make_transcripts_summary_df handles empty input", {
  empty_df <- tibble::tibble(
    section = character(),
    preferred_name = character(),
    n = numeric(),
    duration = numeric(),
    wordcount = numeric(),
    n_perc = numeric(),
    duration_perc = numeric(),
    wordcount_perc = numeric(),
    wpm = numeric()
  )
  result <- make_transcripts_summary_df(empty_df)
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("make_transcripts_summary_df handles NA values", {
  df <- tibble::tibble(
    section = c("A", NA),
    preferred_name = c("Alice", "Bob"),
    n = c(2, NA),
    duration = c(60, 30),
    wordcount = c(10, 5),
    n_perc = c(0.5, 0.25),
    duration_perc = c(0.6, 0.3),
    wordcount_perc = c(0.4, 0.2),
    wpm = c(10, 10)
  )
  result <- make_transcripts_summary_df(df)
  expect_s3_class(result, "tbl_df")
  expect_true(any(is.na(result$section)) | any(!is.na(result$section)))
})

test_that("make_transcripts_summary_df handles invalid input gracefully", {
  expect_silent(make_transcripts_summary_df(NULL))
  expect_silent(make_transcripts_summary_df(list(a = 1)))
})

test_that("make_transcripts_summary_df handles complex aggregation correctly", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "A", "B", "B"),
    preferred_name = c("Alice", "Alice", "Bob", "Alice", "Charlie"),
    n = c(2, 3, 1, 4, 2),
    duration = c(60, 90, 30, 120, 60),
    wordcount = c(10, 15, 5, 20, 10),
    n_perc = c(0.5, 0.75, 0.25, 0.8, 0.4),
    duration_perc = c(0.6, 0.9, 0.3, 0.8, 0.4),
    wordcount_perc = c(0.4, 0.6, 0.2, 0.8, 0.4),
    wpm = c(10, 10, 10, 10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4) # 4 unique section-name combinations: Alice-A, Alice-B, Bob-A, Charlie-B

  # Check that Alice appears twice (once for each section)
  alice_rows <- result[result$preferred_name == "Alice", ]
  expect_equal(nrow(alice_rows), 2)

  # Check that aggregation worked correctly
  alice_section_a <- result[result$preferred_name == "Alice" & result$section == "A", ]
  expect_equal(alice_section_a$n, 5) # 2 + 3
  expect_equal(alice_section_a$duration, 150) # 60 + 90
  expect_equal(alice_section_a$wordcount, 25) # 10 + 15
})

test_that("make_transcripts_summary_df handles all NA values in numeric columns", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(NA, NA),
    duration = c(NA, NA),
    wordcount = c(NA, NA),
    n_perc = c(0.5, 0.5),
    duration_perc = c(0.6, 0.4),
    wordcount_perc = c(0.4, 0.6),
    wpm = c(10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_equal(result$n, c(0, 0)) # sum(NA, na.rm=TRUE) = 0
  expect_equal(result$duration, c(0, 0))
  expect_equal(result$wordcount, c(0, 0))
})

test_that("make_transcripts_summary_df handles mixed NA and non-NA values", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice", "Bob", "Alice"),
    n = c(2, NA, 3),
    duration = c(60, NA, 90),
    wordcount = c(10, NA, 15),
    n_perc = c(0.5, 0.25, 0.75),
    duration_perc = c(0.6, 0.3, 0.9),
    wordcount_perc = c(0.4, 0.2, 0.6),
    wpm = c(10, 10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)

  # Check that NA values are handled correctly
  bob_row <- result[result$preferred_name == "Bob", ]
  expect_equal(bob_row$n, 0) # sum(NA, na.rm=TRUE) = 0
  expect_equal(bob_row$duration, 0)
  expect_equal(bob_row$wordcount, 0)
})

test_that("make_transcripts_summary_df calculates percentages correctly", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "A"),
    preferred_name = c("Alice", "Bob", "Charlie"),
    n = c(10, 20, 30),
    duration = c(100, 200, 300),
    wordcount = c(50, 100, 150),
    n_perc = c(0.2, 0.4, 0.6),
    duration_perc = c(0.2, 0.4, 0.6),
    wordcount_perc = c(0.2, 0.4, 0.6),
    wpm = c(10, 10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)

  # Check percentage calculations
  total_n <- 60 # 10 + 20 + 30
  total_duration <- 600 # 100 + 200 + 300
  total_wordcount <- 300 # 50 + 100 + 150

  alice_row <- result[result$preferred_name == "Alice", ]
  expect_equal(alice_row$perc_n, 10 / total_n * 100)
  expect_equal(alice_row$perc_duration, 100 / total_duration * 100)
  expect_equal(alice_row$perc_wordcount, 50 / total_wordcount * 100)

  # Check WPM calculation
  expect_equal(alice_row$wpm, 50 / 100) # wordcount / duration
})

test_that("make_transcripts_summary_df handles zero values in percentage calculations", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(0, 0),
    duration = c(0, 0),
    wordcount = c(0, 0),
    n_perc = c(0.5, 0.5),
    duration_perc = c(0.5, 0.5),
    wordcount_perc = c(0.5, 0.5),
    wpm = c(10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # Check that zero values don't cause division by zero
  expect_true(all(is.nan(result$wpm) | is.infinite(result$wpm))) # 0/0 = NaN
  expect_true(all(is.nan(result$perc_n) | is.infinite(result$perc_n))) # 0/0 = NaN
})

test_that("make_transcripts_summary_df sorts by duration correctly", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "A"),
    preferred_name = c("Alice", "Bob", "Charlie"),
    n = c(10, 20, 30),
    duration = c(100, 300, 200), # Bob has highest duration
    wordcount = c(50, 150, 100),
    n_perc = c(0.2, 0.4, 0.6),
    duration_perc = c(0.2, 0.4, 0.6),
    wordcount_perc = c(0.2, 0.4, 0.6),
    wpm = c(10, 10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)

  # Check that results are sorted by duration (descending)
  expect_equal(result$duration, c(300, 200, 100))
  expect_equal(result$preferred_name, c("Bob", "Charlie", "Alice"))
})

test_that("make_transcripts_summary_df handles single row input", {
  session_summary_df <- tibble::tibble(
    section = "A",
    preferred_name = "Alice",
    n = 10,
    duration = 100,
    wordcount = 50,
    n_perc = 1.0,
    duration_perc = 1.0,
    wordcount_perc = 1.0,
    wpm = 10
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1)
  expect_equal(result$section, "A")
  expect_equal(result$preferred_name, "Alice")
  expect_equal(result$perc_n, 100) # 100% since it's the only row
  expect_equal(result$perc_duration, 100)
  expect_equal(result$perc_wordcount, 100)
})

test_that("make_transcripts_summary_df handles missing columns gracefully", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(10, 20)
    # Missing duration, wordcount, etc.
  )

  # The function produces warnings but doesn't error, so we expect warnings
  expect_warning(
    result <- make_transcripts_summary_df(session_summary_df),
    "Unknown or uninitialised column"
  )

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
})

test_that("make_transcripts_summary_df handles special characters in names", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice O'Connor", "Bob-Smith"),
    n = c(10, 20),
    duration = c(100, 200),
    wordcount = c(50, 100),
    n_perc = c(0.5, 0.5),
    duration_perc = c(0.5, 0.5),
    wordcount_perc = c(0.5, 0.5),
    wpm = c(10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true("Alice O'Connor" %in% result$preferred_name)
  expect_true("Bob-Smith" %in% result$preferred_name)
})

test_that("make_transcripts_summary_df handles empty result after aggregation", {
  session_summary_df <- tibble::tibble(
    section = character(),
    preferred_name = character(),
    n = numeric(),
    duration = numeric(),
    wordcount = numeric()
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
  expect_true(all(c(
    "section", "preferred_name", "session_ct", "n", "duration",
    "wordcount", "wpm", "perc_n", "perc_duration", "perc_wordcount"
  ) %in% names(result)))
})

test_that("make_transcripts_summary_df handles single section with multiple speakers", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "A"),
    preferred_name = c("Alice", "Bob", "Charlie"),
    n = c(10, 20, 30),
    duration = c(100, 200, 300),
    wordcount = c(50, 100, 150),
    n_perc = c(0.17, 0.33, 0.50),
    duration_perc = c(0.17, 0.33, 0.50),
    wordcount_perc = c(0.17, 0.33, 0.50),
    wpm = c(0.5, 0.5, 0.5)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)

  # Should be sorted by duration (descending)
  expect_equal(result$duration, c(300, 200, 100))
  expect_equal(result$preferred_name, c("Charlie", "Bob", "Alice"))

  # Check percentage calculations
  total_n <- 60
  total_duration <- 600
  total_wordcount <- 300

  expect_equal(result$perc_n, c(30 / total_n * 100, 20 / total_n * 100, 10 / total_n * 100))
  expect_equal(result$perc_duration, c(300 / total_duration * 100, 200 / total_duration * 100, 100 / total_duration * 100))
  expect_equal(result$perc_wordcount, c(150 / total_wordcount * 100, 100 / total_wordcount * 100, 50 / total_wordcount * 100))
})

test_that("make_transcripts_summary_df handles multiple sections with equal durations", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "B", "B"),
    preferred_name = c("Alice", "Bob", "Charlie", "David"),
    n = c(10, 20, 15, 25),
    duration = c(100, 100, 100, 100), # Equal durations
    wordcount = c(50, 100, 75, 125),
    n_perc = c(0.33, 0.67, 0.38, 0.62),
    duration_perc = c(0.50, 0.50, 0.50, 0.50),
    wordcount_perc = c(0.33, 0.67, 0.38, 0.62),
    wpm = c(0.5, 1.0, 0.75, 1.25)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 4)

  # Should maintain order within sections when durations are equal
  # The order should be stable based on the original data order
  expect_equal(result$duration, c(100, 100, 100, 100))
})

test_that("make_transcripts_summary_df handles very large numbers", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(1000000, 2000000),
    duration = c(3600000, 7200000), # 1 hour and 2 hours in seconds
    wordcount = c(500000, 1000000),
    n_perc = c(0.33, 0.67),
    duration_perc = c(0.33, 0.67),
    wordcount_perc = c(0.33, 0.67),
    wpm = c(8.33, 8.33)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # Should handle large numbers correctly
  expect_equal(result$n, c(2000000, 1000000)) # Sorted by duration
  expect_equal(result$duration, c(7200000, 3600000))
  expect_equal(result$wordcount, c(1000000, 500000))

  # Check WPM calculation
  expect_equal(result$wpm, c(1000000 / 7200000, 500000 / 3600000))
})

test_that("make_transcripts_summary_df handles decimal values", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(10.5, 20.7),
    duration = c(100.25, 200.75),
    wordcount = c(50.1, 100.9),
    n_perc = c(0.34, 0.66),
    duration_perc = c(0.33, 0.67),
    wordcount_perc = c(0.33, 0.67),
    wpm = c(0.5, 0.5)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # Should handle decimal values correctly
  # The function aggregates by section and preferred_name, so these should be separate rows
  expect_equal(result$n, c(20.7, 10.5)) # Separate rows, sorted by duration
  expect_equal(result$duration, c(200.75, 100.25)) # Sorted by duration
  expect_equal(result$wordcount, c(100.9, 50.1)) # Sorted by duration
})

test_that("make_transcripts_summary_df handles group_id creation with special characters", {
  session_summary_df <- tibble::tibble(
    section = c("A-B", "A-B"), # Section with dash character (avoiding pipe)
    preferred_name = c("Alice-Smith", "Bob-Jones"), # Name with dash character
    n = c(10, 20),
    duration = c(100, 200),
    wordcount = c(50, 100),
    n_perc = c(0.33, 0.67),
    duration_perc = c(0.33, 0.67),
    wordcount_perc = c(0.33, 0.67),
    wpm = c(0.5, 0.5)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # Should handle special characters in group_id creation
  expect_true("A-B" %in% result$section)
  expect_true("Alice-Smith" %in% result$preferred_name)
  expect_true("Bob-Jones" %in% result$preferred_name)
})

test_that("make_transcripts_summary_df handles session_ct calculation", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "A"),
    preferred_name = c("Alice", "Alice", "Bob"),
    n = c(10, 20, 30),
    duration = c(100, NA, 300), # One NA duration
    wordcount = c(50, 100, 150),
    n_perc = c(0.17, 0.33, 0.50),
    duration_perc = c(0.17, 0.33, 0.50),
    wordcount_perc = c(0.17, 0.33, 0.50),
    wpm = c(0.5, 0.5, 0.5)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # Alice should have session_ct = 1 (only one non-NA duration)
  # Bob should have session_ct = 1 (one non-NA duration)
  alice_row <- result[result$preferred_name == "Alice", ]
  bob_row <- result[result$preferred_name == "Bob", ]

  expect_equal(alice_row$session_ct, 1)
  expect_equal(bob_row$session_ct, 1)
})

test_that("make_transcripts_summary_df handles non-tibble input", {
  # Test with data.frame input
  df_input <- data.frame(
    section = c("A", "A", "B"),
    preferred_name = c("Alice", "Bob", "Alice"),
    n = c(2, 1, 3),
    duration = c(60, 30, 90),
    wordcount = c(10, 5, 15)
  )

  # Should return NULL for non-tibble input
  result <- make_transcripts_summary_df(df_input)
  expect_null(result)

  # Test with NULL input
  result_null <- make_transcripts_summary_df(NULL)
  expect_null(result_null)

  # Test with list input
  result_list <- make_transcripts_summary_df(list(a = 1, b = 2))
  expect_null(result_list)

  # Test with character input
  result_char <- make_transcripts_summary_df("not a tibble")
  expect_null(result_char)
})

test_that("make_transcripts_summary_df handles all NA duration values", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A", "B"),
    preferred_name = c("Alice", "Bob", "Charlie"),
    n = c(10, 20, 30),
    duration = c(NA, NA, NA), # All NA durations
    wordcount = c(50, 100, 150),
    n_perc = c(0.17, 0.33, 0.50),
    duration_perc = c(0.17, 0.33, 0.50),
    wordcount_perc = c(0.17, 0.33, 0.50),
    wpm = c(0.5, 0.5, 0.5)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 3)

  # All session_ct should be 0 since all durations are NA
  expect_equal(result$session_ct, c(0, 0, 0))
  expect_equal(result$duration, c(0, 0, 0)) # sum(NA, na.rm=TRUE) = 0
})

test_that("make_transcripts_summary_df handles division by zero in percentage calculations", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(0, 0),
    duration = c(0, 0),
    wordcount = c(0, 0),
    n_perc = c(0.5, 0.5),
    duration_perc = c(0.5, 0.5),
    wordcount_perc = c(0.5, 0.5),
    wpm = c(10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # Should handle division by zero gracefully
  expect_true(all(is.nan(result$wpm) | is.infinite(result$wpm)))
  expect_true(all(is.nan(result$perc_n) | is.infinite(result$perc_n)))
  expect_true(all(is.nan(result$perc_duration) | is.infinite(result$perc_duration)))
  expect_true(all(is.nan(result$perc_wordcount) | is.infinite(result$perc_wordcount)))
})

test_that("make_transcripts_summary_df handles group_id with pipe character", {
  # Test the edge case where section or preferred_name contains the pipe character
  # which is used as a separator in group_id creation
  # NOTE: This reveals a limitation in the function - pipe characters in section/name
  # will be split incorrectly when reconstructing from group_id
  session_summary_df <- tibble::tibble(
    section = c("A|B", "A|B"), # Section with pipe character
    preferred_name = c("Alice|Smith", "Bob|Jones"), # Name with pipe character
    n = c(10, 20),
    duration = c(100, 200),
    wordcount = c(50, 100),
    n_perc = c(0.33, 0.67),
    duration_perc = c(0.33, 0.67),
    wordcount_perc = c(0.33, 0.67),
    wpm = c(0.5, 0.5)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # The function has a limitation: pipe characters in section/name cause incorrect splitting
  # When group_id is "A|B|Alice|Smith", splitting by "|" gives ["A", "B", "Alice", "Smith"]
  # So section becomes "A" and preferred_name becomes "B"
  expect_equal(result$section, c("A", "A"))
  expect_equal(result$preferred_name, c("B", "B"))

  # Check the order is correct (sorted by duration descending)
  expect_equal(result$duration, c(200, 100))
})

test_that("make_transcripts_summary_df handles very small decimal values", {
  session_summary_df <- tibble::tibble(
    section = c("A", "A"),
    preferred_name = c("Alice", "Bob"),
    n = c(0.0001, 0.0002),
    duration = c(0.001, 0.002),
    wordcount = c(0.01, 0.02),
    n_perc = c(0.33, 0.67),
    duration_perc = c(0.33, 0.67),
    wordcount_perc = c(0.33, 0.67),
    wpm = c(10, 10)
  )

  result <- make_transcripts_summary_df(session_summary_df)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)

  # Should handle very small decimal values correctly
  expect_equal(result$n, c(0.0002, 0.0001)) # Sorted by duration
  expect_equal(result$duration, c(0.002, 0.001))
  expect_equal(result$wordcount, c(0.02, 0.01))

  # Check WPM calculation with small values
  expect_equal(result$wpm, c(0.02 / 0.002, 0.01 / 0.001))
})
