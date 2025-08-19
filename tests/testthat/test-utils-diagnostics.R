test_that("diag helpers are quiet by default and verbose when enabled", {
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = FALSE)
  quiet_out_std <- capture.output({ diag_cat("world\n") })
  quiet_out_msg <- capture.output({ diag_message("hello") }, type = "message")
  expect_length(quiet_out_std, 0)
  expect_length(quiet_out_msg, 0)

  options(zoomstudentengagement.verbose = TRUE)
  verbose_out_msg <- capture.output({ diag_message("hello") }, type = "message")
  verbose_out_std <- capture.output({ diag_cat("world\n") })
  expect_true(any(grepl("hello", verbose_out_msg)))
  expect_true(any(grepl("world", verbose_out_std)))
})


