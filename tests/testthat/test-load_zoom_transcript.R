test_that("load_zoom_transcript loads valid VTT file correctly", {
  # Create a temporary VTT file
  vtt_content <- c(
    "WEBVTT",
    "",
    "1",
    "00:00:00.000 --> 00:00:03.000",
    "Student1: Hello",
    "",
    "2",
    "00:00:05.000 --> 00:00:08.000",
    "Student2: Hi there",
    "",
    "3",
    "00:00:10.000 --> 00:00:13.000",
    "Student1: How are you?"
  )

  temp_file <- tempfile(fileext = ".vtt")
  writeLines(vtt_content, temp_file)

  # Test loading the file
  result <- load_zoom_transcript(temp_file)

  # Check basic structure
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("comment_num", "name", "comment", "start", "end", "duration", "wordcount") %in% names(result)))

  # Check content
  expect_equal(nrow(result), 3)
  expect_equal(result$name, c("Student1", "Student2", "Student1"))
  expect_equal(result$comment, c("Hello", "Hi there", "How are you?"))
  expect_equal(unname(result$wordcount), c(1, 2, 3))

  # Check time handling
  expect_s3_class(result$start, "hms")
  expect_s3_class(result$end, "hms")
  expect_equal(as.numeric(result$duration), c(3, 3, 3))

  # Clean up
  unlink(temp_file)
})

test_that("load_zoom_transcript handles non-existent file", {
  # Test with non-existent file
  expect_error(
    load_zoom_transcript("nonexistent_file.vtt"),
    "file.exists\\(transcript_file_path\\) is not TRUE"
  )
})

test_that("load_zoom_transcript handles malformed VTT file", {
  # Create a malformed VTT file
  malformed_content <- c(
    "WEBVTT",
    "",
    "1",
    "00:00:00.000 --> 00:00:03.000", # Missing comment
    "",
    "2",
    "00:00:05.000 --> 00:00:08.000",
    "Student2: Hi there"
  )

  temp_file <- tempfile(fileext = ".vtt")
  writeLines(malformed_content, temp_file)

  # Test loading the file
  result <- load_zoom_transcript(temp_file)

  # Check that it handles the malformed entry gracefully
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1) # Only one valid entry

  # Clean up
  unlink(temp_file)
})

test_that("load_zoom_transcript handles empty VTT file", {
  # Create an empty VTT file
  empty_content <- c("WEBVTT", "")

  temp_file <- tempfile(fileext = ".vtt")
  writeLines(empty_content, temp_file)

  # Test loading the file
  result <- load_zoom_transcript(temp_file)

  # Check that it returns NULL for empty files
  expect_null(result)

  # Clean up
  unlink(temp_file)
})

test_that("load_zoom_transcript handles comments without names", {
  # Create a VTT file with unnamed comments
  vtt_content <- c(
    "WEBVTT",
    "",
    "1",
    "00:00:00.000 --> 00:00:03.000",
    "Hello", # No name
    "",
    "2",
    "00:00:05.000 --> 00:00:08.000",
    "Student2: Hi there"
  )

  temp_file <- tempfile(fileext = ".vtt")
  writeLines(vtt_content, temp_file)

  # Test loading the file
  result <- load_zoom_transcript(temp_file)

  # Check that it handles unnamed comments correctly
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_true(is.na(result$name[1])) # First comment should have NA name

  # Clean up
  unlink(temp_file)
})
