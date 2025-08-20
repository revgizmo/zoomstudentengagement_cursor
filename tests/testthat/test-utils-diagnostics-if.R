test_that("diag_message_if and diag_cat_if respect local verbose flag and global option", {
  old_opt <- getOption("zoomstudentengagement.verbose", NULL)
  on.exit(options(zoomstudentengagement.verbose = old_opt), add = TRUE)

  options(zoomstudentengagement.verbose = FALSE)

  # When both local and global are FALSE, no output
  out_msg_quiet <- capture.output({
    diag_message_if(FALSE, "hello quiet")
  }, type = "message")
  out_cat_quiet <- capture.output({
    diag_cat_if(FALSE, "world quiet\n")
  })
  expect_length(out_msg_quiet, 0)
  expect_length(out_cat_quiet, 0)

  # When local is TRUE, output occurs regardless of global option
  out_msg_verbose <- capture.output({
    diag_message_if(TRUE, "hello verbose")
  }, type = "message")
  out_cat_verbose <- capture.output({
    diag_cat_if(TRUE, "world verbose\n")
  })
  expect_true(any(grepl("hello verbose", out_msg_verbose)))
  expect_true(any(grepl("world verbose", out_cat_verbose)))

  # When global option is TRUE, output occurs even if local FALSE
  options(zoomstudentengagement.verbose = TRUE)
  out_msg_global <- capture.output({
    diag_message_if(FALSE, "hello global")
  }, type = "message")
  out_cat_global <- capture.output({
    diag_cat_if(FALSE, "world global\n")
  })
  expect_true(any(grepl("hello global", out_msg_global)))
  expect_true(any(grepl("world global", out_cat_global)))
})


