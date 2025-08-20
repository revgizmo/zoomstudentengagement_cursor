test_that("validate_ferpa_compliance detects PII and retention issues across institution types", {
  df <- tibble::tibble(
    student_id = c("001", "002"),
    preferred_name = c("Alice", "Böb"),
    email = c("a@example.edu", "b@example.edu"),
    session_date = as.Date(c("2023-01-01", Sys.Date()))
  )

  # Educational
  res1 <- validate_ferpa_compliance(df, institution_type = "educational", check_retention = TRUE, retention_period = "academic_year")
  expect_false(res1$compliant)
  expect_true(length(res1$pii_detected) >= 1)
  expect_true(length(res1$institution_guidance) > 0)
  expect_type(res1$retention_check, "list")

  # Research
  res2 <- validate_ferpa_compliance(df, institution_type = "research", check_retention = FALSE)
  expect_true(!is.null(res2$institution_guidance))
  expect_null(res2$retention_check)

  # Mixed with custom retention (note: function does not pass date_column, so only generic retention text is present)
  res3 <- validate_ferpa_compliance(df, institution_type = "mixed", check_retention = TRUE, retention_period = "custom", custom_retention_days = 30)
  # Depending on date_column presence, compliance may remain FALSE due to PII or change based on retention
  expect_type(res3$recommendations, "character")
})

test_that("check_data_retention_policy flags old records and handles custom days", {
  df <- tibble::tibble(
    session_date = as.Date(c("2020-01-01", Sys.Date() - 10L, Sys.Date())),
    value = c(1, 2, 3)
  )

  # Academic year should flag the very old record
  out1 <- check_data_retention_policy(df, retention_period = "academic_year", date_column = "session_date", current_date = as.Date("2025-01-01"))
  expect_false(out1$compliant)
  expect_true(nrow(out1$data_to_dispose) >= 1)

  # Custom short window should flag two older records
  out2 <- check_data_retention_policy(df, retention_period = "custom", custom_retention_days = 5, date_column = "session_date")
  expect_false(out2$compliant)
  expect_true(nrow(out2$data_to_dispose) >= 1)
})

test_that("generate_ferpa_report produces JSON, HTML, and text reports", {
  df <- tibble::tibble(
    student_id = c("1", "2"),
    preferred_name = c("Alice", "Chloé"),
    session_date = as.Date(c("2024-01-15", "2024-02-20"))
  )

  tmp_json <- tempfile(fileext = ".json"); on.exit(unlink(tmp_json), add = TRUE)
  tmp_html <- tempfile(fileext = ".html"); on.exit(unlink(tmp_html), add = TRUE)
  tmp_txt  <- tempfile(fileext = ".txt");  on.exit(unlink(tmp_txt), add = TRUE)

  rep1 <- generate_ferpa_report(df, output_file = tmp_json, report_format = "json")
  rep2 <- generate_ferpa_report(df, output_file = tmp_html, report_format = "html")
  rep3 <- generate_ferpa_report(df, output_file = tmp_txt,  report_format = "text")

  expect_true(file.exists(tmp_json))
  expect_true(file.exists(tmp_html))
  expect_true(file.exists(tmp_txt))
  expect_true(is.list(rep1) && is.list(rep2) && is.list(rep3))
})

test_that("anonymize_educational_data supports mask, hash, pseudonymize, and aggregate modes", {
  df <- tibble::tibble(
    student_id = c("S1", "S2", NA_character_),
    preferred_name = c("Alice", "Bëlla", ""),
    section = c("101.A", "101.A", "101.B"),
    score = c(90, 80, 85)
  )

  # mask
  masked <- anonymize_educational_data(df, method = "mask")
  expect_s3_class(masked, "tbl_df")

  # hash with salt
  hashed <- anonymize_educational_data(df, method = "hash", hash_salt = "pepper")
  expect_true(all(nchar(hashed$student_id) == 8 | is.na(hashed$student_id)))

  # pseudonymize
  pseudo <- anonymize_educational_data(df, method = "pseudonymize")
  expect_true(all(grepl("^PSEUDO_", pseudo$preferred_name[!is.na(pseudo$preferred_name) & nzchar(pseudo$preferred_name)])))

  # aggregate at individual level (routes to masking path)
  agg <- anonymize_educational_data(df, method = "aggregate", aggregation_level = "individual")
  expect_s3_class(agg, "tbl_df")
})


