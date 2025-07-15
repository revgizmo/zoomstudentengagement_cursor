test_that("make_new_analysis_template copies the template file and prints a message", {
  temp_dir <- tempdir()
  old_wd <- setwd(temp_dir)
  on.exit(setwd(old_wd))
  # Create a dummy template file
  template_file <- file.path(temp_dir, "dummy_template.Rmd")
  writeLines(c("# Dummy Template", "Some content."), template_file)
  new_template_file <- file.path(temp_dir, "copied_template.Rmd")
  # Should copy the file and print a message
  expect_output(make_new_analysis_template(new_template_file_name = new_template_file, template_file = template_file), "created")
  expect_true(file.exists(new_template_file))
  expect_equal(readLines(new_template_file), readLines(template_file))
  unlink(template_file)
  unlink(new_template_file)
})

test_that("make_new_analysis_template handles missing template file gracefully", {
  temp_dir <- tempdir()
  old_wd <- setwd(temp_dir)
  on.exit(setwd(old_wd))
  missing_file <- file.path(temp_dir, "does_not_exist.Rmd")
  new_template_file <- file.path(temp_dir, "should_not_exist.Rmd")
  expect_false(file.exists(missing_file))
  expect_false(file.exists(new_template_file))
  expect_false(make_new_analysis_template(new_template_file_name = new_template_file, template_file = missing_file))
  expect_false(file.exists(new_template_file))
})
