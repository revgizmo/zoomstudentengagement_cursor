test_that("privacy_audit reports masked estimates", {
  df <- tibble::tibble(
    preferred_name = c("Alice", "Bob", NA, ""),
    student_id = c("123", "456", NA, "")
  )
  masked <- ensure_privacy(df)
  audit <- privacy_audit(masked)
  expect_true(all(c("column","values","non_empty","masked_estimate") %in% names(audit)))
  expect_true(any(audit$masked_estimate > 0))
})