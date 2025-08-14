test_that("validate_schema validates presence and types", {
  df <- tibble::tibble(timestamp = hms::as_hms("00:00:01"), speaker = "A", text = "hi")
  expect_silent(validate_schema(df, zse_schema$transcript$required, zse_schema$transcript$types))
})

test_that("validate_schema aborts on missing columns", {
  df <- tibble::tibble(speaker = "A", text = "hi")
  expect_error(
    validate_schema(df, zse_schema$transcript$required),
    class = "zse_schema_error"
  )
})

test_that("validate_schema aborts on wrong types", {
  df <- tibble::tibble(timestamp = "00:00:01", speaker = "A", text = "hi")
  expect_error(
    validate_schema(df, zse_schema$transcript$required, zse_schema$transcript$types),
    class = "zse_schema_error"
  )
})