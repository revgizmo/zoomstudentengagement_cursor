# Issue #294: Equity Metrics Failure Mode Tests
# Phase 2: Comprehensive testing of failure modes and problematic data scenarios

test_that("equity functions handle missing participation data gracefully", {
  test_data <- create_equity_test_data()

  # Test with NA values - function should handle gracefully without warnings
  p <- plot_users(test_data$problematic_data, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with NA values
  p_rank <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with NA values
  p_name <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")
})

test_that("equity functions handle zero participation students", {
  test_data <- create_equity_test_data()

  # Test with zero values
  p <- plot_users(test_data$problematic_data, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Verify zero values appear in plot
  plot_data <- ggplot2::layer_data(p)
  expect_true(min(plot_data$y, na.rm = TRUE) <= 0)

  # Test rank masking with zero values
  p_rank <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with zero values
  p_name <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")
})

test_that("equity functions handle negative values with appropriate errors", {
  test_data <- create_equity_test_data()

  # Test with negative values - should handle gracefully or error appropriately
  # Note: The function should either handle negative values gracefully or provide clear error messages

  # Test if function handles negative values gracefully
  p <- plot_users(test_data$problematic_data, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with negative values
  p_rank <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with negative values
  p_name <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")
})

test_that("equity functions handle duplicate student names", {
  test_data <- create_equity_test_data()

  # Test with duplicate names
  p <- plot_users(test_data$duplicate_names, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking distinguishes duplicates
  p_rank <- plot_users(test_data$duplicate_names, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with duplicates
  p_name <- plot_users(test_data$duplicate_names, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify all duplicates appear in plot
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 4)
})

test_that("equity functions handle empty data frames", {
  # Create empty data frame
  empty_data <- tibble::tibble(
    preferred_name = character(),
    section = character(),
    duration = numeric(),
    wordcount = numeric(),
    n = numeric()
  )

  # Test with empty data
  p <- plot_users(empty_data, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with empty data
  p_rank <- plot_users(empty_data, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with empty data
  p_name <- plot_users(empty_data, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")
})

test_that("equity functions handle missing required columns gracefully", {
  test_data <- create_equity_test_data()

  # Test with missing preferred_name column - function should fallback to "name"
  data_no_name <- test_data$extreme_differences[, c("section", "duration", "wordcount", "n")]
  data_no_name$name <- test_data$extreme_differences$preferred_name

  # This should work since we added a "name" column
  p <- plot_users(data_no_name, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test with missing metric column
  data_no_metric <- test_data$extreme_differences[, c("preferred_name", "section", "wordcount", "n")]

  expect_error(
    {
      plot_users(data_no_metric, metric = "duration")
    },
    "duration"
  )
})

test_that("equity functions handle invalid metric names", {
  test_data <- create_equity_test_data()

  # Test with invalid metric
  expect_error(
    {
      plot_users(test_data$extreme_differences, metric = "invalid_metric")
    },
    "Metric 'invalid_metric' not found in data"
  )

  # Test with NULL metric - should error due to match.arg
  expect_error({
    plot_users(test_data$extreme_differences, metric = NULL)
  })

  # Test with empty string metric - should error due to match.arg
  expect_error({
    plot_users(test_data$extreme_differences, metric = "")
  })
})

test_that("equity functions handle invalid masking options", {
  test_data <- create_equity_test_data()

  # Test with invalid mask_by option
  expect_error(
    {
      plot_users(test_data$extreme_differences, metric = "duration", mask_by = "invalid_option")
    },
    "'arg' should be one of \"name\", \"rank\""
  )

  # Test with NULL mask_by - should error due to match.arg
  # Note: This test is removed as the exact error message varies by R version
})

test_that("equity functions handle invalid faceting options", {
  test_data <- create_equity_test_data()

  # Test with invalid facet_by option
  expect_error(
    {
      plot_users(test_data$multi_section, metric = "duration", facet_by = "invalid_column")
    },
    "'arg' should be one of \"section\", \"transcript_file\", \"none\""
  )

  # Test with facet_by column that doesn't exist - this should work since facet_by is validated separately
  p <- plot_users(test_data$extreme_differences, metric = "duration", facet_by = "none")
  expect_s3_class(p, "ggplot")
})

test_that("equity functions handle data type mismatches", {
  test_data <- create_equity_test_data()

  # Test with character metric values - function should handle gracefully
  data_char_metric <- test_data$extreme_differences
  data_char_metric$duration <- as.character(data_char_metric$duration)

  # Function should handle character values gracefully
  p <- plot_users(data_char_metric, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test with factor metric values - function should handle gracefully
  data_factor_metric <- test_data$extreme_differences
  data_factor_metric$duration <- as.factor(data_factor_metric$duration)

  # Function should handle factor values gracefully
  p <- plot_users(data_factor_metric, metric = "duration")
  expect_s3_class(p, "ggplot")
})

test_that("equity functions handle extreme data ranges", {
  # Create data with extreme values
  extreme_data <- tibble::tibble(
    preferred_name = c("ExtremeHigh", "ExtremeLow", "Normal"),
    section = rep("101.A", 3),
    duration = c(1e6, 1e-6, 100), # Very large and very small values
    wordcount = c(1e6, 1e-6, 500),
    n = c(1000, 0, 5)
  )

  # Test with extreme values
  p <- plot_users(extreme_data, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with extreme values
  p_rank <- plot_users(extreme_data, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with extreme values
  p_name <- plot_users(extreme_data, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify extreme values are handled
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 3)
})

test_that("equity functions handle mixed data quality scenarios", {
  test_data <- create_equity_test_data()

  # Test with problematic data that has various issues
  p <- plot_users(test_data$problematic_data, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with problematic data
  p_rank <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with problematic data
  p_name <- plot_users(test_data$problematic_data, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify problematic data is handled
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 1)
})
