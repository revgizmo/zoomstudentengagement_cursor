test_that("make_metrics_lookup_df returns correct structure and content", {
  result <- make_metrics_lookup_df()
  expect_s3_class(result, "tbl_df")
  expect_true(all(c("metric", "description") %in% names(result)))
  expect_true("session_ct" %in% result$metric)
  expect_true("wpm" %in% result$metric)
  expect_equal(nrow(result), 8)
  expect_true(any(grepl("duration", result$description)))
})

test_that("make_metrics_lookup_df returns same result on repeated calls", {
  result1 <- make_metrics_lookup_df()
  result2 <- make_metrics_lookup_df()
  expect_equal(result1, result2)
})
