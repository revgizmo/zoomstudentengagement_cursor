test_that("validate_ferpa_compliance works correctly", {
  # Test data with PII
  sample_data <- tibble::tibble(
    student_id = c("12345", "67890"),
    preferred_name = c("Alice Johnson", "Bob Smith"),
    email = c("alice@university.edu", "bob@university.edu"),
    participation_score = c(85, 92)
  )

  # Test basic validation
  result <- validate_ferpa_compliance(sample_data)

  expect_type(result, "list")
  expect_true("compliant" %in% names(result))
  expect_true("pii_detected" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("institution_guidance" %in% names(result))

  # Should detect PII
  expect_false(result$compliant)
  expect_true(length(result$pii_detected) > 0)
  expect_true("student_id" %in% result$pii_detected)
  expect_true("preferred_name" %in% result$pii_detected)
  expect_true("email" %in% result$pii_detected)

  # Test with clean data
  clean_data <- tibble::tibble(
    section = c("A", "B"),
    participation_score = c(85, 92)
  )

  clean_result <- validate_ferpa_compliance(clean_data)
  expect_true(clean_result$compliant)
  expect_equal(length(clean_result$pii_detected), 0)

  # Test institution types
  edu_result <- validate_ferpa_compliance(sample_data, institution_type = "educational")
  expect_true(length(edu_result$institution_guidance) > 0)
  expect_true(any(grepl("FERPA", edu_result$institution_guidance)))

  research_result <- validate_ferpa_compliance(sample_data, institution_type = "research")
  expect_true(any(grepl("IRB", research_result$institution_guidance)))
})

test_that("anonymize_educational_data works correctly", {
  sample_data <- tibble::tibble(
    student_id = c("12345", "67890"),
    preferred_name = c("Alice Johnson", "Bob Smith"),
    section = c("A", "B"),
    participation_score = c(85, 92)
  )

  # Test mask method
  masked <- anonymize_educational_data(sample_data, method = "mask")
  expect_false(identical(masked$preferred_name, sample_data$preferred_name))
  expect_true(all(grepl("Student", masked$preferred_name)))

  # Test hash method
  hashed <- anonymize_educational_data(sample_data, method = "hash")
  expect_false(identical(hashed$preferred_name, sample_data$preferred_name))
  expect_true(all(nchar(hashed$preferred_name) == 8))

  # Test hash method with salt
  hashed_salt <- anonymize_educational_data(sample_data, method = "hash", hash_salt = "test_salt")
  expect_false(identical(hashed_salt$preferred_name, hashed$preferred_name))

  # Test pseudonymize method
  pseudonymized <- anonymize_educational_data(sample_data, method = "pseudonymize")
  expect_true(all(grepl("PSEUDO_", pseudonymized$preferred_name)))

  # Test preserve columns
  preserved <- anonymize_educational_data(sample_data, method = "mask", preserve_columns = "section")
  expect_identical(preserved$section, sample_data$section)

  # Test with no PII
  clean_data <- tibble::tibble(
    section = c("A", "B"),
    participation_score = c(85, 92)
  )

  clean_result <- anonymize_educational_data(clean_data, method = "mask")
  expect_identical(clean_result, clean_data)
})

test_that("generate_ferpa_report works correctly", {
  sample_data <- tibble::tibble(
    student_id = c("12345", "67890"),
    preferred_name = c("Alice Johnson", "Bob Smith"),
    participation_score = c(85, 92)
  )

  # Test basic report generation
  report <- generate_ferpa_report(sample_data)

  expect_type(report, "list")
  expect_true("title" %in% names(report))
  expect_true("generated" %in% names(report))
  expect_true("summary" %in% names(report))
  expect_true("validation_results" %in% names(report))
  expect_true("recommendations" %in% names(report))

  expect_equal(report$title, "FERPA Compliance Report")
  expect_false(report$summary$compliant)
  expect_true(length(report$recommendations) > 0)

  # Test with audit trail
  report_with_audit <- generate_ferpa_report(sample_data, include_audit_trail = TRUE)
  expect_true("audit_trail" %in% names(report_with_audit))
  expect_true("data_rows" %in% names(report_with_audit$audit_trail))
  expect_true("data_columns" %in% names(report_with_audit$audit_trail))

  # Test without audit trail
  report_no_audit <- generate_ferpa_report(sample_data, include_audit_trail = FALSE)
  expect_null(report_no_audit$audit_trail)

  # Test with institution info
  inst_info <- list(name = "Test University", type = "educational")
  report_with_inst <- generate_ferpa_report(sample_data, institution_info = inst_info)
  expect_identical(report_with_inst$institution_info, inst_info)
})

test_that("check_data_retention_policy works correctly", {
  # Test data with dates
  sample_data <- tibble::tibble(
    student_id = c("12345", "67890"),
    session_date = as.Date(c("2024-01-15", "2024-02-20")),
    participation_score = c(85, 92)
  )

  # Test basic retention check
  result <- check_data_retention_policy(
    sample_data,
    retention_period = "academic_year",
    date_column = "session_date"
  )

  expect_type(result, "list")
  expect_true("compliant" %in% names(result))
  expect_true("retention_period_days" %in% names(result))
  expect_true("recommendations" %in% names(result))

  expect_equal(result$retention_period_days, 365)
  expect_true(length(result$recommendations) > 0)

  # Test with old data
  old_data <- tibble::tibble(
    student_id = c("12345", "67890"),
    session_date = as.Date(c("2020-01-15", "2020-02-20")),
    participation_score = c(85, 92)
  )

  old_result <- check_data_retention_policy(
    old_data,
    retention_period = "academic_year",
    date_column = "session_date"
  )

  expect_false(old_result$compliant)
  expect_true("data_to_dispose" %in% names(old_result))
  expect_true(nrow(old_result$data_to_dispose) > 0)

  # Test different retention periods
  semester_result <- check_data_retention_policy(
    sample_data,
    retention_period = "semester",
    date_column = "session_date"
  )
  expect_equal(semester_result$retention_period_days, 180)

  quarter_result <- check_data_retention_policy(
    sample_data,
    retention_period = "quarter",
    date_column = "session_date"
  )
  expect_equal(quarter_result$retention_period_days, 90)

  # Test custom retention period
  custom_result <- check_data_retention_policy(
    sample_data,
    retention_period = "custom",
    custom_retention_days = 30,
    date_column = "session_date"
  )
  expect_equal(custom_result$retention_period_days, 30)

  # Test without date column
  no_date_result <- check_data_retention_policy(sample_data)
  expect_true(no_date_result$compliant)
  expect_null(no_date_result$data_to_dispose)
})

test_that("FERPA privacy levels work correctly", {
  sample_data <- tibble::tibble(
    student_id = c("12345", "67890"),
    preferred_name = c("Alice Johnson", "Bob Smith"),
    email = c("alice@university.edu", "bob@university.edu"),
    instructor_name = c("Dr. Smith", "Dr. Jones"),
    participation_score = c(85, 92)
  )

  # Test ferpa_strict level
  strict_result <- ensure_privacy(sample_data, privacy_level = "ferpa_strict")
  expect_false(identical(strict_result$email, sample_data$email))
  expect_false(identical(strict_result$instructor_name, sample_data$instructor_name))

  # Test ferpa_standard level
  standard_result <- ensure_privacy(sample_data, privacy_level = "ferpa_standard")
  expect_false(identical(standard_result$email, sample_data$email))
  expect_false(identical(standard_result$instructor_name, sample_data$instructor_name))

  # Test mask level (should not mask instructor_name)
  mask_result <- ensure_privacy(sample_data, privacy_level = "mask")
  expect_false(identical(mask_result$email, sample_data$email))
  expect_identical(mask_result$instructor_name, sample_data$instructor_name)
})

test_that("set_privacy_defaults works with new FERPA levels", {
  # Test ferpa_strict (diagnostics now gated; enable verbose for message checks)
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)
  options(zoomstudentengagement.verbose = TRUE)
  expect_message(set_privacy_defaults("ferpa_strict"), "FERPA strict mode enabled")
  expect_equal(getOption("zoomstudentengagement.privacy_level"), "ferpa_strict")

  # Test ferpa_standard
  expect_message(set_privacy_defaults("ferpa_standard"), "FERPA standard mode enabled")
  expect_equal(getOption("zoomstudentengagement.privacy_level"), "ferpa_standard")

  # Test mask
  set_privacy_defaults("mask")
  expect_equal(getOption("zoomstudentengagement.privacy_level"), "mask")

  # Test none
  expect_warning(set_privacy_defaults("none"), "Privacy disabled")
  expect_equal(getOption("zoomstudentengagement.privacy_level"), "none")

  # Restore default
  set_privacy_defaults("mask")
})

test_that("FERPA compliance functions handle edge cases", {
  # Test with empty data frame
  empty_df <- tibble::tibble()
  empty_result <- validate_ferpa_compliance(empty_df)
  expect_true(empty_result$compliant)

  # Test with NULL data
  expect_error(anonymize_educational_data(NULL), "Data must be a data frame")

  # Test with invalid privacy level
  sample_data <- tibble::tibble(name = "test")
  expect_error(ensure_privacy(sample_data, privacy_level = "invalid"), "Invalid privacy_level")

  # Test with invalid retention period
  expect_error(
    check_data_retention_policy(sample_data, retention_period = "invalid"),
    "should be one of"
  )

  # Test with invalid report format
  expect_error(
    generate_ferpa_report(sample_data, report_format = "invalid"),
    "should be one of"
  )
})

test_that("FERPA compliance functions preserve data structure", {
  sample_data <- tibble::tibble(
    student_id = c("12345", "67890"),
    preferred_name = c("Alice Johnson", "Bob Smith"),
    section = c("A", "B"),
    participation_score = c(85, 92)
  )

  # Test that anonymization preserves structure
  anonymized <- anonymize_educational_data(sample_data, method = "mask")
  expect_equal(nrow(anonymized), nrow(sample_data))
  expect_equal(ncol(anonymized), ncol(sample_data))
  expect_equal(names(anonymized), names(sample_data))

  # Test that privacy function preserves structure
  private <- ensure_privacy(sample_data, privacy_level = "ferpa_strict")
  expect_equal(nrow(private), nrow(sample_data))
  expect_equal(ncol(private), ncol(sample_data))
  expect_equal(names(private), names(sample_data))
})
