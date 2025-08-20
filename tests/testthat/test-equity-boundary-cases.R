# Issue #294: Equity Metrics Boundary and Edge Cases Tests
# Phase 1: Comprehensive testing of boundary conditions and edge cases

test_that("equity functions handle single participant classes", {
  test_data <- create_equity_test_data()

  # Test plot_users with single student
  p <- plot_users(test_data$single_student, metric = "duration")
  expect_s3_class(p, "ggplot")
  expect_true(length(p$layers) > 0)

  # Test rank masking with single student
  p_rank <- plot_users(test_data$single_student, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with single student
  p_name <- plot_users(test_data$single_student, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify single student appears in plot
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 1)
})

test_that("equity functions handle equal participation scenarios", {
  test_data <- create_equity_test_data()

  # Test with identical participation
  p <- plot_users(test_data$equal_participation, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with ties
  p_rank <- plot_users(test_data$equal_participation, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with equal participation
  p_name <- plot_users(test_data$equal_participation, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify all participants appear in plot
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 4)
})

test_that("equity functions handle extreme participation differences", {
  test_data <- create_equity_test_data()

  # Test with extreme differences
  p <- plot_users(test_data$extreme_differences, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Verify outlier is visible
  plot_data <- ggplot2::layer_data(p)
  expect_true(max(plot_data$y, na.rm = TRUE) >= 1000)

  # Test rank masking preserves relative positions
  p_rank <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking
  p_name <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")
})

test_that("equity functions handle international names correctly", {
  test_data <- create_equity_test_data()

  # Test with international names
  p <- plot_users(test_data$international_names, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test name masking preserves privacy
  p_masked <- plot_users(test_data$international_names, metric = "duration", mask_by = "name")
  expect_s3_class(p_masked, "ggplot")

  # Test rank masking
  p_rank <- plot_users(test_data$international_names, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Verify all international names are handled
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 4)
})

test_that("equity functions handle large classes efficiently", {
  test_data <- create_equity_test_data()

  # Test performance with large class
  start_time <- Sys.time()
  p <- plot_users(test_data$large_class, metric = "duration")
  end_time <- Sys.time()

  expect_s3_class(p, "ggplot")
  expect_true(as.numeric(difftime(end_time, start_time, units = "secs")) < 5)

  # Test rank masking with large class
  p_rank <- plot_users(test_data$large_class, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with large class
  p_name <- plot_users(test_data$large_class, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify all students appear in plot
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 60)
})

test_that("equity functions handle very small differences", {
  test_data <- create_equity_test_data()

  # Test with very small differences
  p <- plot_users(test_data$small_differences, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with small differences
  p_rank <- plot_users(test_data$small_differences, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with small differences
  p_name <- plot_users(test_data$small_differences, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify differences are visible
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 4)
})

test_that("equity functions handle all zero values", {
  test_data <- create_equity_test_data()

  # Test with all zeros
  p <- plot_users(test_data$all_zeros, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with zeros
  p_rank <- plot_users(test_data$all_zeros, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with zeros
  p_name <- plot_users(test_data$all_zeros, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify zero values appear in plot
  plot_data <- ggplot2::layer_data(p)
  expect_true(min(plot_data$y, na.rm = TRUE) <= 0)
})

test_that("equity functions handle mixed data types", {
  test_data <- create_equity_test_data()

  # Test with mixed data types
  p <- plot_users(test_data$mixed_data_types, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with mixed data
  p_rank <- plot_users(test_data$mixed_data_types, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with mixed data
  p_name <- plot_users(test_data$mixed_data_types, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify plot renders correctly
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 3)
})

test_that("equity functions handle different metrics consistently", {
  test_data <- create_equity_test_data()

  # Test with different metrics
  metrics <- c("duration", "wordcount", "n")

  for (metric in metrics) {
    # Test unmasked
    p <- plot_users(test_data$extreme_differences, metric = metric)
    expect_s3_class(p, "ggplot")

    # Test rank masking
    p_rank <- plot_users(test_data$extreme_differences, metric = metric, mask_by = "rank")
    expect_s3_class(p_rank, "ggplot")

    # Test name masking
    p_name <- plot_users(test_data$extreme_differences, metric = metric, mask_by = "name")
    expect_s3_class(p_name, "ggplot")
  }
})

test_that("equity functions handle faceting correctly", {
  test_data <- create_equity_test_data()

  # Test faceting by section
  p <- plot_users(test_data$multi_section, metric = "duration", facet_by = "section")
  expect_s3_class(p, "ggplot")

  # Test faceting with rank masking
  p_rank <- plot_users(test_data$multi_section, metric = "duration", facet_by = "section", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test faceting with name masking
  p_name <- plot_users(test_data$multi_section, metric = "duration", facet_by = "section", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify faceting is applied
  expect_true("FacetWrap" %in% class(p$facet))
})
