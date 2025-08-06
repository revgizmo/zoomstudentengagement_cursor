test_that("calculate_content_similarity handles NULL transcripts", {
  # Test with NULL transcripts
  expect_equal(calculate_content_similarity(NULL, NULL), 0.0)
  expect_equal(calculate_content_similarity(NULL, data.frame()), 0.0)
  expect_equal(calculate_content_similarity(data.frame(), NULL), 0.0)
})

test_that("calculate_content_similarity handles empty transcripts", {
  # Test with empty transcripts
  empty_df <- data.frame()
  expect_equal(calculate_content_similarity(empty_df, empty_df), 0.0)
})

test_that("calculate_content_similarity handles transcripts with no meaningful data", {
  # Create transcripts with no meaningful similarity data
  transcript1 <- data.frame(
    name = c("Student A", "Student B"),
    duration = c(0, 0),  # No duration
    wordcount = c(0, 0),  # No words
    stringsAsFactors = FALSE
  )
  
  transcript2 <- data.frame(
    name = c("Student C", "Student D"),  # Different speakers
    duration = c(0, 0),  # No duration
    wordcount = c(0, 0),  # No words
    stringsAsFactors = FALSE
  )
  
  # Should return 0.0 when no meaningful similarity data exists
  result <- calculate_content_similarity(transcript1, transcript2)
  expect_equal(result, 0.0)
})

test_that("calculate_content_similarity filters excluded names", {
  # Create transcripts with dead_air entries
  transcript1 <- data.frame(
    name = c("Student A", "dead_air", "Student B"),
    duration = c(10, 5, 15),
    wordcount = c(20, 0, 30),
    stringsAsFactors = FALSE
  )
  
  transcript2 <- data.frame(
    name = c("Student A", "dead_air", "Student C"),
    duration = c(12, 3, 18),
    wordcount = c(22, 0, 35),
    stringsAsFactors = FALSE
  )
  
  # Should filter out dead_air entries
  result <- calculate_content_similarity(transcript1, transcript2, names_to_exclude = c("dead_air"))
  expect_true(result > 0.0)
})

test_that("calculate_content_similarity calculates similarity correctly", {
  # Create similar transcripts
  transcript1 <- data.frame(
    name = c("Student A", "Student B"),
    duration = c(10, 15),
    wordcount = c(20, 30),
    stringsAsFactors = FALSE
  )
  
  transcript2 <- data.frame(
    name = c("Student A", "Student B"),
    duration = c(12, 18),
    wordcount = c(22, 35),
    stringsAsFactors = FALSE
  )
  
  # Should return high similarity for similar transcripts
  result <- calculate_content_similarity(transcript1, transcript2)
  expect_true(result > 0.5)
  expect_true(result <= 1.0)
}) 