test_that("validate_privacy_compliance works correctly", {
  # Test with privacy-safe data
  safe_df <- tibble::tibble(
    name = c("Student_01", "Student_02"),
    score = c(85, 92)
  )
  
  expect_true(validate_privacy_compliance(safe_df))
  
  # Test with real names (should fail)
  real_names_df <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    score = c(85, 92)
  )
  
  expect_error(
    validate_privacy_compliance(real_names_df),
    "Privacy violation detected"
  )
  
  # Test with privacy disabled (should pass)
  expect_true(validate_privacy_compliance(real_names_df, privacy_level = "none"))
  
  # Test with specific real names to check against (should pass since safe_df has no real names)
  real_names <- c("John Smith", "Jane Doe")
  expect_true(validate_privacy_compliance(safe_df, real_names = real_names))
  
  # Test with real names in data (should fail)
  real_names_df <- tibble::tibble(
    name = c("John Smith", "Jane Doe"),
    score = c(85, 92)
  )
  expect_error(
    validate_privacy_compliance(real_names_df, real_names = real_names),
    "Privacy violation detected"
  )
  
  # Test with stop_on_violation = FALSE (should warn instead of error)
  expect_warning(
    validate_privacy_compliance(real_names_df, stop_on_violation = FALSE),
    "Privacy violation detected"
  )
})

test_that("validate_privacy_compliance handles different data types", {
  # Test with list
  safe_list <- list(
    df1 = tibble::tibble(name = c("Student_01", "Student_02")),
    df2 = tibble::tibble(name = c("Student_03", "Student_04"))
  )
  expect_true(validate_privacy_compliance(safe_list))
  
  # Test with character vector
  safe_chars <- c("Student_01", "Student_02", "Student_03")
  expect_true(validate_privacy_compliance(safe_chars))
  
  # Test with NULL
  expect_true(validate_privacy_compliance(NULL))
  
  # Test with non-data frame
  expect_true(validate_privacy_compliance(123))
})

test_that("validate_privacy_compliance validates inputs correctly", {
  # Test invalid privacy level
  expect_error(
    validate_privacy_compliance(tibble::tibble(), privacy_level = "invalid"),
    "Invalid privacy_level"
  )
  
  # Test invalid stop_on_violation
  expect_error(
    validate_privacy_compliance(tibble::tibble(), stop_on_violation = "invalid"),
    "stop_on_violation must be a single logical value"
  )
})

test_that("extract_character_values works correctly", {
  # Test with data frame
  df <- tibble::tibble(
    name = c("Student_01", "Student_02"),
    score = c(85, 92),
    numeric_col = c(1, 2)
  )
  
  chars <- extract_character_values(df)
  expect_equal(chars, c("Student_01", "Student_02"))
  
  # Test with list
  test_list <- list(
    df1 = tibble::tibble(name = c("A", "B")),
    df2 = tibble::tibble(name = c("C", "D"))
  )
  
  chars <- extract_character_values(test_list)
  expect_equal(chars, c("A", "B", "C", "D"))
  
  # Test with character vector
  chars <- extract_character_values(c("A", "B", "C"))
  expect_equal(chars, c("A", "B", "C"))
  
  # Test with no character data
  df_no_chars <- tibble::tibble(
    score = c(85, 92),
    numeric_col = c(1, 2)
  )
  
  chars <- extract_character_values(df_no_chars)
  expect_equal(chars, character(0))
})

test_that("detect_privacy_violations works correctly", {
  # Test with specific real names
  real_names <- c("John Smith", "Jane Doe")
  safe_values <- c("Student_01", "Student_02", "Guest_01")
  
  violations <- detect_privacy_violations(safe_values, real_names, "mask")
  expect_equal(length(violations), 0)
  
  # Test with real names in values
  mixed_values <- c("Student_01", "John Smith", "Student_02")
  violations <- detect_privacy_violations(mixed_values, real_names, "mask")
  expect_equal(violations, "John Smith")
  
  # Test with name patterns
  pattern_values <- c("Student_01", "Dr. John Smith", "Guest_01")
  violations <- detect_privacy_violations(pattern_values, NULL, "mask")
  expect_equal(violations, "Dr. John Smith")
  
  # Test with exact name match
  exact_values <- c("Student_01", "John Smith", "Guest_01")
  violations <- detect_privacy_violations(exact_values, c("John Smith"), "mask")
  expect_equal(violations, "John Smith")
  
  # Test with masked names (should not be flagged)
  masked_values <- c("Student_01", "Guest_01", "Instructor_01")
  violations <- detect_privacy_violations(masked_values, NULL, "mask")
  expect_equal(length(violations), 0)
})
