test_that("diag helpers are quiet by default and verbose when enabled", {
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = FALSE)
  quiet_out <- capture.output({
    diag_message("hello")
    diag_cat("world\n")
  })
  expect_length(quiet_out, 0)

  options(zoomstudentengagement.verbose = TRUE)
  verbose_out <- capture.output({
    diag_message("hello")
    diag_cat("world\n")
  })
  expect_true(any(grepl("hello", verbose_out)))
  expect_true(any(grepl("world", verbose_out)))
})


