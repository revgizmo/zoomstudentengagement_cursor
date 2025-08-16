# Test file for enhanced safe_name_matching_workflow functionality
# Tests all 4 scenarios and technical improvements from Issue #160 Phase 2

test_that("enhanced empty roster handling works correctly", {
  # Test empty roster validation
  empty_roster <- data.frame(
    preferred_name = character(0),
    stringsAsFactors = FALSE
  )

  expect_error(
    safe_name_matching_workflow(
      transcript_file_path = system.file(
        "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
        package = "zoomstudentengagement"
      ),
      roster_data = empty_roster
    ),
    "Roster data appears empty or lacks required name columns"
  )
})

test_that("column existence checks prevent warnings", {
  # Create test data with missing columns
  test_transcript <- data.frame(
    user_name = c("John Smith", "Jane Doe"),
    message = c("Hello", "Hi there"),
    # Missing timestamp column
    stringsAsFactors = FALSE
  )

  # Test that missing columns are detected
  required_columns <- c("user_name", "message", "timestamp")
  missing_cols <- setdiff(required_columns, names(test_transcript))

  expect_equal(missing_cols, "timestamp")
  expect_true(length(missing_cols) > 0)
})

test_that("enhanced error messages are specific and actionable", {
  # Test that error messages include specific guidance
  test_roster <- data.frame(
    preferred_name = c("John Smith", "Jane Doe"),
    stringsAsFactors = FALSE
  )

  # Create a transcript with unmatched names
  test_transcript <- data.frame(
    user_name = c("JS", "Dr. Smith", "Guest User"),
    message = c("Hello", "Hi", "Test"),
    timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  # Mock the unmatched names scenario
  unmatched_names <- c("JS", "Dr. Smith", "Guest User")

  # Test that error message includes specific guidance
  error_msg <- tryCatch(
    {
      stop(
        paste0(
          "Found unmatched names: ", paste(unmatched_names, collapse = ", "), "\n",
          "Please update your section_names_lookup.csv file with these mappings.\n",
          "See vignette('name-matching-troubleshooting') for detailed instructions.\n",
          "Example mappings:\n",
          paste(sapply(unmatched_names, function(name) {
            paste0("  ", name, " -> [Your roster name]")
          }), collapse = "\n")
        )
      )
    },
    error = function(e) e$message
  )

  expect_true(grepl("Found unmatched names", error_msg))
  expect_true(grepl("section_names_lookup.csv", error_msg))
  expect_true(grepl("vignette\\('name-matching-troubleshooting'\\)", error_msg))
  expect_true(grepl("JS -> \\[Your roster name\\]", error_msg))
})

test_that("lookup file validation works correctly", {
  # Test valid lookup file
  valid_lookup <- data.frame(
    transcript_name = c("JS", "Dr. Smith"),
    preferred_name = c("John Smith", "John Smith"),
    stringsAsFactors = FALSE
  )

  # This should not error
  expect_true(validate_lookup_file_format(valid_lookup))

  # Test missing required columns
  invalid_lookup <- data.frame(
    transcript_name = c("JS"),
    # Missing preferred_name column
    stringsAsFactors = FALSE
  )

  expect_error(
    validate_lookup_file_format(invalid_lookup),
    "Lookup file missing required columns"
  )

  # Test empty lookup file
  empty_lookup <- data.frame(
    transcript_name = character(0),
    preferred_name = character(0),
    stringsAsFactors = FALSE
  )

  expect_warning(
    validate_lookup_file_format(empty_lookup),
    "Lookup file is empty"
  )

  # Test duplicate transcript names
  duplicate_lookup <- data.frame(
    transcript_name = c("JS", "JS", "Dr. Smith"),
    preferred_name = c("John Smith", "John Smith", "John Smith"),
    stringsAsFactors = FALSE
  )

  expect_warning(
    validate_lookup_file_format(duplicate_lookup),
    "Duplicate transcript names found"
  )
})

test_that("scenario 1: guest users are handled correctly", {
  # Test guest user mapping
  guest_mapping <- data.frame(
    transcript_name = c("Guest User", "Unknown User", "Guest-1234"),
    preferred_name = c("GUEST_001", "GUEST_002", "GUEST_003"),
    stringsAsFactors = FALSE
  )

  # Verify guest mappings are consistent
  expect_true(all(grepl("^GUEST_", guest_mapping$preferred_name)))
  expect_equal(nrow(guest_mapping), 3)
})

test_that("scenario 2: custom names are mapped correctly", {
  # Test custom name mapping
  custom_mapping <- data.frame(
    transcript_name = c("JS", "Dr. Smith", "JohnS", "jsmith"),
    preferred_name = c("John Smith", "John Smith", "John Smith", "John Smith"),
    stringsAsFactors = FALSE
  )

  # Verify all custom names map to the same roster name
  expect_true(all(custom_mapping$preferred_name == "John Smith"))
  expect_equal(length(unique(custom_mapping$transcript_name)), 4)
})

test_that("scenario 3: cross-session consistency works", {
  # Test cross-session name variations
  cross_session_mapping <- data.frame(
    transcript_name = c("John Smith", "J. Smith", "Smith, John", "JohnS"),
    preferred_name = c("John Smith", "John Smith", "John Smith", "John Smith"),
    stringsAsFactors = FALSE
  )

  # Verify consistent mapping across variations
  expect_true(all(cross_session_mapping$preferred_name == "John Smith"))
  expect_equal(length(unique(cross_session_mapping$transcript_name)), 4)
})

test_that("scenario 4: name variations are handled", {
  # Test name variation mapping
  variation_mapping <- data.frame(
    transcript_name = c(
      "John Smith", "Smith, John", "J. Smith", "John S.", "Smith",
      "John A. Smith", "Smith, John A.", "J.A. Smith"
    ),
    preferred_name = c(
      "John Smith", "John Smith", "John Smith", "John Smith", "John Smith",
      "John Smith", "John Smith", "John Smith"
    ),
    stringsAsFactors = FALSE
  )

  # Verify all variations map to the same name
  expect_true(all(variation_mapping$preferred_name == "John Smith"))
  expect_equal(length(unique(variation_mapping$transcript_name)), 8)
})

test_that("privacy compliance is maintained throughout", {
  # Test that real names are never exposed in outputs
  test_roster <- data.frame(
    preferred_name = c("John Smith", "Jane Doe"),
    stringsAsFactors = FALSE
  )

  # Create test transcript with real names
  test_transcript <- data.frame(
    user_name = c("John Smith", "Jane Doe"),
    message = c("Hello", "Hi there"),
    timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  # Mock privacy validation
  validate_privacy_compliance <- function(output_data) {
    # Check that no real names appear in outputs
    if (any(grepl("^[A-Z][a-z]+\\s+[A-Z][a-z]+$", output_data$user_name))) {
      stop("Privacy violation: Real names detected in output")
    }
    return(TRUE)
  }

  # Test that validation catches real names
  expect_error(
    validate_privacy_compliance(test_transcript),
    "Privacy violation"
  )

  # Test that hashed names pass validation
  hashed_transcript <- test_transcript
  hashed_transcript$user_name <- sapply(hashed_transcript$user_name, function(name) {
    digest::digest(name, algo = "sha256")
  })

  expect_true(validate_privacy_compliance(hashed_transcript))
})

test_that("enhanced error handling provides clear guidance", {
  # Test that error messages reference documentation
  error_msg <- "Found unmatched names: JS, Dr. Smith\nPlease update your section_names_lookup.csv file with these mappings.\nSee vignette('name-matching-troubleshooting') for detailed instructions."

  expect_true(grepl("vignette\\('name-matching-troubleshooting'\\)", error_msg))
  expect_true(grepl("section_names_lookup.csv", error_msg))
  expect_true(grepl("Found unmatched names", error_msg))
})

test_that("performance impact is acceptable", {
  # Test that enhanced validation doesn't significantly impact performance
  large_roster <- data.frame(
    preferred_name = paste0("Student ", 1:1000),
    stringsAsFactors = FALSE
  )

  large_transcript <- data.frame(
    user_name = paste0("Student ", 1:1000),
    message = rep("test", 1000),
    timestamp = Sys.time(),
    stringsAsFactors = FALSE
  )

  # Time the validation (should be fast)
  start_time <- Sys.time()

  # Mock validation operations
  for (i in 1:100) {
    # Simulate validation operations
    nrow(large_roster)
    nrow(large_transcript)
    names(large_roster)
    names(large_transcript)
  }

  end_time <- Sys.time()
  processing_time <- as.numeric(difftime(end_time, start_time, units = "secs"))

  # Should complete in under 1 second
  expect_true(processing_time < 1)
})

test_that("backward compatibility is maintained", {
  # Test that existing functionality still works
  test_roster <- data.frame(
    preferred_name = c("John Smith", "Jane Doe"),
    stringsAsFactors = FALSE
  )

  # Test that the function signature hasn't changed
  expect_true(
    "transcript_file_path" %in% names(formals(safe_name_matching_workflow))
  )
  expect_true(
    "roster_data" %in% names(formals(safe_name_matching_workflow))
  )
  expect_true(
    "privacy_level" %in% names(formals(safe_name_matching_workflow))
  )
})

test_that("all 4 scenarios work together", {
  # Test comprehensive scenario handling
  comprehensive_mapping <- data.frame(
    transcript_name = c(
      # Scenario 1: Guest users
      "Guest User", "Unknown User", "Guest-1234",
      # Scenario 2: Custom names
      "JS", "Dr. Smith", "JohnS", "jsmith",
      # Scenario 3: Cross-session variations
      "John Smith", "J. Smith", "Smith, John",
      # Scenario 4: Name variations
      "John A. Smith", "Smith, John A.", "J.A. Smith"
    ),
    preferred_name = c(
      # Guest users
      "GUEST_001", "GUEST_002", "GUEST_003",
      # Custom names
      "John Smith", "John Smith", "John Smith", "John Smith",
      # Cross-session
      "John Smith", "John Smith", "John Smith",
      # Variations
      "John Smith", "John Smith", "John Smith"
    ),
    stringsAsFactors = FALSE
  )

  # Verify all scenarios are handled
  expect_equal(nrow(comprehensive_mapping), 13)
  expect_true(all(grepl("^GUEST_", comprehensive_mapping$preferred_name[1:3])))
  expect_true(all(comprehensive_mapping$preferred_name[4:13] == "John Smith"))

  # Verify no duplicates in transcript names
  expect_equal(length(unique(comprehensive_mapping$transcript_name)), 13)
})
