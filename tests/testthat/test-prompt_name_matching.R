test_that("prompt_name_matching works correctly", {
  # Test with unmatched names
  unmatched <- c("Dr. Smith", "Tom", "Guest1")

  # Mock the make_blank_section_names_lookup_csv function
  with_mocked_bindings(
    make_blank_section_names_lookup_csv = function(...) {
      tibble::tibble(
        course_section = character(),
        day = character(),
        time = character(),
        course = character(),
        section = character(),
        preferred_name = character(),
        formal_name = character(),
        transcript_name = character(),
        student_id = character()
      )
    },
    {
      expect_output(
        prompt_name_matching(unmatched),
        "Found 3 unmatched names that need manual mapping"
      )
    }
  )

  # Test with no unmatched names
  expect_message(
    prompt_name_matching(character(0)),
    "No unmatched names found"
  )

  # Test with custom settings
  with_mocked_bindings(
    make_blank_section_names_lookup_csv = function(...) {
      tibble::tibble(
        course_section = character(),
        day = character(),
        time = character(),
        course = character(),
        section = character(),
        preferred_name = character(),
        formal_name = character(),
        transcript_name = character(),
        student_id = character()
      )
    },
    {
      expect_output(
        prompt_name_matching(
          unmatched_names = c("John Doe"),
          data_folder = "test_data",
          section_names_lookup_file = "test_lookup.csv"
        ),
        "Found 1 unmatched name"
      )
    }
  )
})

test_that("prompt_name_matching validates inputs correctly", {
  # Test invalid unmatched_names
  expect_error(
    prompt_name_matching(123),
    "unmatched_names must be a character vector"
  )

  # Test invalid privacy_level
  expect_error(
    prompt_name_matching(c("test"), privacy_level = "invalid"),
    "Invalid privacy_level"
  )

  # Test invalid data_folder
  expect_error(
    prompt_name_matching(c("test"), data_folder = 123),
    "data_folder must be a single character string"
  )

  # Test invalid section_names_lookup_file
  expect_error(
    prompt_name_matching(c("test"), section_names_lookup_file = 123),
    "section_names_lookup_file must be a single character string"
  )

  # Test invalid include_instructions
  expect_error(
    prompt_name_matching(c("test"), include_instructions = "invalid"),
    "include_instructions must be a single logical value"
  )
})

test_that("generate_name_matching_guidance works correctly", {
  # Test with single unmatched name
  guidance <- generate_name_matching_guidance(c("Dr. Smith"), "mask", TRUE)
  expect_true(grepl("Found 1 unmatched name", guidance))
  expect_true(grepl("Dr. Smith", guidance))
  expect_true(grepl("PRIVACY WARNING", guidance))
  expect_true(grepl("INSTRUCTIONS", guidance))

  # Test with multiple unmatched names
  guidance <- generate_name_matching_guidance(c("Dr. Smith", "Tom"), "mask", TRUE)
  expect_true(grepl("Found 2 unmatched names", guidance))
  expect_true(grepl("Dr. Smith, Tom", guidance))

  # Test with privacy disabled
  guidance <- generate_name_matching_guidance(c("Dr. Smith"), "none", TRUE)
  expect_false(grepl("PRIVACY WARNING", guidance))

  # Test without instructions
  guidance <- generate_name_matching_guidance(c("Dr. Smith"), "mask", FALSE)
  expect_false(grepl("INSTRUCTIONS", guidance))
})

test_that("detect_unmatched_names works correctly", {
  # Create test data
  transcript_df <- tibble::tibble(
    transcript_name = c("Dr. Smith", "John Doe", "Guest1"),
    course_section = c("101.A", "101.A", "101.A")
  )

  roster_df <- tibble::tibble(
    first_last = c("John Doe", "Jane Smith"),
    course_section = c("101.A", "101.A")
  )

  # Test with privacy enabled (should return hashed names)
  unmatched <- detect_unmatched_names(transcript_df, roster_df)
  expect_equal(length(unmatched), 2) # Dr. Smith and Guest1 should be unmatched
  expect_true(all(grepl("^[a-f0-9]{8}$", unmatched))) # Should be hashed

  # Test with privacy disabled (should return real names)
  unmatched <- detect_unmatched_names(transcript_df, roster_df, privacy_level = "none")
  expect_equal(length(unmatched), 2)
  expect_true(all(unmatched %in% c("Dr. Smith", "Guest1")))

  # Test with name mappings
  mappings_df <- tibble::tibble(
    transcript_name = c("Dr. Smith"),
    preferred_name = c("Dr. Smith"),
    formal_name = c("Dr. Smith"),
    participant_type = c("instructor"),
    student_id = c("")
  )

  unmatched <- detect_unmatched_names(transcript_df, roster_df, mappings_df)
  expect_equal(length(unmatched), 1) # Only Guest1 should be unmatched
})

test_that("detect_unmatched_names validates inputs correctly", {
  # Test invalid transcript_data
  expect_error(
    detect_unmatched_names("invalid", tibble::tibble()),
    "transcript_data must be a data frame"
  )

  # Test invalid roster_data
  expect_error(
    detect_unmatched_names(tibble::tibble(), "invalid"),
    "roster_data must be a data frame"
  )

  # Test invalid privacy_level
  expect_error(
    detect_unmatched_names(tibble::tibble(), tibble::tibble(), privacy_level = "invalid"),
    "Invalid privacy_level"
  )
})

test_that("extract_transcript_names works correctly", {
  # Test with transcript_name column
  df1 <- tibble::tibble(
    transcript_name = c("Dr. Smith", "John Doe"),
    other_col = c(1, 2)
  )
  names <- extract_transcript_names(df1)
  expect_equal(names, c("Dr. Smith", "John Doe"))

  # Test with name column
  df2 <- tibble::tibble(
    name = c("Dr. Smith", "John Doe"),
    other_col = c(1, 2)
  )
  names <- extract_transcript_names(df2)
  expect_equal(names, c("Dr. Smith", "John Doe"))

  # Test with no name columns
  df3 <- tibble::tibble(
    other_col = c(1, 2)
  )
  names <- extract_transcript_names(df3)
  expect_equal(names, character(0))

  # Test with NA and empty values
  df4 <- tibble::tibble(
    transcript_name = c("Dr. Smith", NA, "", "John Doe")
  )
  names <- extract_transcript_names(df4)
  expect_equal(names, c("Dr. Smith", "John Doe"))
})

test_that("extract_roster_names works correctly", {
  # Test with first_last column
  df1 <- tibble::tibble(
    first_last = c("John Doe", "Jane Smith"),
    other_col = c(1, 2)
  )
  names <- extract_roster_names(df1)
  expect_equal(names, c("John Doe", "Jane Smith"))

  # Test with preferred_name column
  df2 <- tibble::tibble(
    preferred_name = c("John Doe", "Jane Smith"),
    other_col = c(1, 2)
  )
  names <- extract_roster_names(df2)
  expect_equal(names, c("John Doe", "Jane Smith"))

  # Test with no name columns
  df3 <- tibble::tibble(
    other_col = c(1, 2)
  )
  names <- extract_roster_names(df3)
  expect_equal(names, character(0))
})

test_that("extract_mapped_names works correctly", {
  # Test with preferred_name column
  df1 <- tibble::tibble(
    preferred_name = c("John Doe", "Jane Smith"),
    other_col = c(1, 2)
  )
  names <- extract_mapped_names(df1)
  expect_equal(names, c("John Doe", "Jane Smith"))

  # Test with formal_name column
  df2 <- tibble::tibble(
    formal_name = c("John Doe", "Jane Smith"),
    other_col = c(1, 2)
  )
  names <- extract_mapped_names(df2)
  expect_equal(names, c("John Doe", "Jane Smith"))

  # Test with no name columns
  df3 <- tibble::tibble(
    other_col = c(1, 2)
  )
  names <- extract_mapped_names(df3)
  expect_equal(names, character(0))
})
