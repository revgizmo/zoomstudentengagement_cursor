test_that("validate_ethical_use works correctly", {
  # Test basic functionality
  result <- validate_ethical_use(
    usage_context = "research",
    data_scope = "section"
  )

  expect_true(is.list(result))
  expect_true("ethically_compliant" %in% names(result))
  expect_true("risk_level" %in% names(result))
  expect_true("recommendations" %in% names(result))
  expect_true("required_documentation" %in% names(result))
  expect_true("institutional_guidance" %in% names(result))

  # Test that research context is compliant by default
  expect_true(result$ethically_compliant)
  expect_equal(result$risk_level, "low")
})

test_that("validate_ethical_use detects surveillance terms", {
  # Test with surveillance-related purpose statement and high-risk context
  result <- validate_ethical_use(
    usage_context = "assessment",
    data_scope = "individual",
    purpose_statement = "Monitoring student behavior for surveillance purposes"
  )

  expect_false(result$ethically_compliant)
  expect_equal(result$risk_level, "critical")
  expect_true(any(grepl("surveillance", result$recommendations)))
})

test_that("validate_ethical_use handles different contexts", {
  # Test assessment context (higher risk)
  result <- validate_ethical_use(
    usage_context = "assessment",
    data_scope = "section"
  )

  expect_true(result$ethically_compliant) # Should still be compliant
  expect_equal(result$risk_level, "medium")
  expect_true(any(grepl("assessment", result$recommendations)))

  # Test individual scope (higher risk)
  result <- validate_ethical_use(
    usage_context = "research",
    data_scope = "individual"
  )

  expect_true(result$ethically_compliant) # Should still be compliant
  expect_equal(result$risk_level, "medium")
  expect_true(any(grepl("individual", result$recommendations)))
})

test_that("validate_ethical_use handles equity-focused terms", {
  # Test with equity-focused purpose statement
  result <- validate_ethical_use(
    usage_context = "research",
    data_scope = "section",
    purpose_statement = "Improving participation equity in online discussions"
  )

  expect_true(result$ethically_compliant)
  expect_equal(result$risk_level, "low")
  expect_true(any(grepl("equity", result$recommendations)))
})

test_that("validate_ethical_use handles multi-institution scope", {
  # Test multi-institution scope with higher risk context
  result <- validate_ethical_use(
    usage_context = "assessment",
    data_scope = "multi_institution"
  )

  expect_true(result$ethically_compliant) # Should still be compliant
  expect_equal(result$risk_level, "high")
  expect_true(any(grepl("IRB", result$recommendations)))
})

test_that("create_ethical_use_report works correctly", {
  # Test basic report generation
  report <- create_ethical_use_report(
    usage_context = "research",
    data_scope = "section",
    purpose_statement = "Improving teaching methods",
    institution_name = "Test University",
    contact_person = "Dr. Test"
  )

  expect_true(is.character(report))
  expect_true(length(report) == 1)
  expect_true(grepl("ETHICAL USE REPORT", report))
  expect_true(grepl("Test University", report))
  expect_true(grepl("Dr. Test", report))
  expect_true(grepl("research", report))
  expect_true(grepl("section", report))
})

test_that("create_ethical_use_report includes validation results", {
  # Test that report includes validation results
  report <- create_ethical_use_report(
    usage_context = "research",
    data_scope = "section"
  )

  expect_true(grepl("ETHICAL VALIDATION", report))
  expect_true(grepl("Compliant:", report))
  expect_true(grepl("Risk Level:", report))
})

test_that("create_ethical_use_report handles different contexts", {
  # Test with different contexts
  report <- create_ethical_use_report(
    usage_context = "teaching",
    data_scope = "course"
  )

  expect_true(grepl("teaching", report))
  expect_true(grepl("course", report))
})

test_that("audit_ethical_usage works correctly", {
  # Test basic audit functionality
  audit <- audit_ethical_usage(
    function_calls = c("analyze_transcripts", "plot_users"),
    data_sizes = c(100, 150),
    privacy_settings = c("ferpa_strict", "ferpa_strict"),
    time_period = 30
  )

  expect_true(is.list(audit))
  expect_true("usage_patterns" %in% names(audit))
  expect_true("ethical_concerns" %in% names(audit))
  expect_true("recommendations" %in% names(audit))
  expect_true("compliance_score" %in% names(audit))

  # Test that good usage gets high score
  expect_true(audit$compliance_score >= 90)
})

test_that("audit_ethical_usage detects concerning patterns", {
  # Test with privacy disabled
  audit <- audit_ethical_usage(
    function_calls = c("analyze_transcripts", "write_metrics"),
    data_sizes = c(100, 150),
    privacy_settings = c("none", "ferpa_strict"),
    time_period = 30
  )

  expect_true(audit$compliance_score < 90)
  expect_true(any(grepl("Privacy disabled", audit$ethical_concerns)))
})

test_that("audit_ethical_usage handles large datasets", {
  # Test with large dataset
  audit <- audit_ethical_usage(
    function_calls = c("analyze_transcripts"),
    data_sizes = c(1500), # Large dataset
    privacy_settings = c("ferpa_strict"),
    time_period = 30
  )

  expect_true(audit$compliance_score < 100)
  expect_true(any(grepl("Large datasets", audit$ethical_concerns)))
})

test_that("audit_ethical_usage handles high export frequency", {
  # Test with high export frequency
  audit <- audit_ethical_usage(
    function_calls = rep("write_metrics", 15), # High frequency
    data_sizes = rep(100, 15),
    privacy_settings = rep("ferpa_strict", 15),
    time_period = 30
  )

  expect_true(audit$compliance_score < 100)
  expect_true(any(grepl("export", audit$ethical_concerns)))
})

test_that("validate_ethical_use handles edge cases", {
  # Test with NULL purpose statement
  result <- validate_ethical_use(
    usage_context = "research",
    data_scope = "section",
    purpose_statement = NULL
  )

  expect_true(is.list(result))
  expect_true(result$ethically_compliant)

  # Test with empty purpose statement
  result <- validate_ethical_use(
    usage_context = "research",
    data_scope = "section",
    purpose_statement = ""
  )

  expect_true(is.list(result))
  expect_true(result$ethically_compliant)
})

test_that("create_ethical_use_report handles edge cases", {
  # Test with minimal parameters
  report <- create_ethical_use_report(
    usage_context = "research",
    data_scope = "section"
  )

  expect_true(is.character(report))
  expect_true(grepl("ETHICAL USE REPORT", report))

  # Test with NULL parameters
  report <- create_ethical_use_report(
    usage_context = "research",
    data_scope = "section",
    purpose_statement = NULL,
    institution_name = NULL,
    contact_person = NULL
  )

  expect_true(is.character(report))
  expect_true(grepl("ETHICAL USE REPORT", report))
})

test_that("audit_ethical_usage handles edge cases", {
  # Test with empty vectors
  audit <- audit_ethical_usage(
    function_calls = character(0),
    data_sizes = numeric(0),
    privacy_settings = character(0),
    time_period = 30
  )

  expect_true(is.list(audit))
  expect_true("usage_patterns" %in% names(audit))
  expect_true("compliance_score" %in% names(audit))

  # Test with single operation
  audit <- audit_ethical_usage(
    function_calls = "analyze_transcripts",
    data_sizes = 100,
    privacy_settings = "ferpa_strict",
    time_period = 30
  )

  expect_true(is.list(audit))
  expect_true(audit$compliance_score >= 90)
})

test_that("ethical compliance functions maintain privacy", {
  # Test that functions don't expose sensitive information
  result <- validate_ethical_use(
    usage_context = "research",
    data_scope = "section",
    purpose_statement = "Testing with sensitive student data"
  )

  # Should not contain any actual student data in output
  expect_false(any(grepl("sensitive student data", result$recommendations)))

  # Test audit function with sensitive data
  audit <- audit_ethical_usage(
    function_calls = c("analyze_transcripts"),
    data_sizes = c(100),
    privacy_settings = c("ferpa_strict"),
    time_period = 30
  )

  # Should not expose sensitive information
  expect_true(is.list(audit))
  expect_false(any(grepl("sensitive", audit$recommendations)))
})

test_that("ethical compliance functions provide helpful guidance", {
  # Test that functions provide actionable recommendations
  result <- validate_ethical_use(
    usage_context = "assessment",
    data_scope = "individual",
    purpose_statement = "Grading student participation"
  )

  expect_true(length(result$recommendations) > 0)
  expect_true(any(grepl("consent", result$recommendations)))
  expect_true(any(grepl("individual", result$recommendations)))

  # Test that audit provides helpful guidance
  audit <- audit_ethical_usage(
    function_calls = c("write_metrics", "write_metrics", "write_metrics"),
    data_sizes = c(100, 200, 300),
    privacy_settings = c("none", "ferpa_strict", "ferpa_strict"),
    time_period = 30
  )

  expect_true(length(audit$recommendations) > 0)
  expect_true(any(grepl("privacy", audit$recommendations)))
})
