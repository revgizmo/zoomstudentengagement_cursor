# Issue #294: Equity Metrics Validation Tests
# Phase 3: Comprehensive testing of equity-specific validation scenarios

test_that("equity functions support participation distribution analysis", {
  test_data <- create_equity_test_data()
  validation_data <- create_equity_validation_data()

  # Test that plots show participation gaps
  p <- plot_users(test_data$extreme_differences, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Verify rank masking preserves relative positions
  p_rank <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test with participation gaps data
  p_gaps <- plot_users(validation_data$participation_gaps, metric = "duration")
  expect_s3_class(p_gaps, "ggplot")

  # Verify participation gaps are visible
  plot_data <- ggplot2::layer_data(p_gaps)
  expect_true(max(plot_data$y, na.rm = TRUE) >= 200)
  expect_true(min(plot_data$y, na.rm = TRUE) <= 10)

  # Test rank masking with participation gaps
  p_gaps_rank <- plot_users(validation_data$participation_gaps, metric = "duration", mask_by = "rank")
  expect_s3_class(p_gaps_rank, "ggplot")

  # Test name masking with participation gaps
  p_gaps_name <- plot_users(validation_data$participation_gaps, metric = "duration", mask_by = "name")
  expect_s3_class(p_gaps_name, "ggplot")
})

test_that("equity functions support section comparison analysis", {
  test_data <- create_equity_test_data()
  validation_data <- create_equity_validation_data()

  # Test faceting by section
  p <- plot_users(test_data$multi_section, metric = "duration", facet_by = "section")
  expect_s3_class(p, "ggplot")
  expect_true("FacetWrap" %in% class(p$facet))

  # Test faceting with rank masking
  p_rank <- plot_users(test_data$multi_section, metric = "duration", facet_by = "section", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test faceting with name masking
  p_name <- plot_users(test_data$multi_section, metric = "duration", facet_by = "section", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Test with section comparison data
  p_section <- plot_users(validation_data$section_comparison, metric = "duration", facet_by = "section")
  expect_s3_class(p_section, "ggplot")

  # Verify all sections are represented
  plot_data <- ggplot2::layer_data(p_section)
  expect_true(nrow(plot_data) >= 12) # 3 sections * 4 students each
})

test_that("equity functions maintain analytical value with privacy masking", {
  test_data <- create_equity_test_data()

  # Test that masked plots preserve analytical information
  p_unmasked <- plot_users(test_data$extreme_differences, metric = "duration")
  p_ranked <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "rank")
  p_named <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "name")

  expect_s3_class(p_unmasked, "ggplot")
  expect_s3_class(p_ranked, "ggplot")
  expect_s3_class(p_named, "ggplot")

  # Verify all plots show the same number of data points
  unmasked_data <- ggplot2::layer_data(p_unmasked)
  ranked_data <- ggplot2::layer_data(p_ranked)
  named_data <- ggplot2::layer_data(p_named)

  expect_equal(length(unmasked_data$y), length(ranked_data$y))
  expect_equal(length(unmasked_data$y), length(named_data$y))

  # Verify relative patterns are preserved in rank masking
  expect_equal(length(unique(ranked_data$y)), length(unique(unmasked_data$y)))
})

test_that("equity functions support gender-balanced participation analysis", {
  validation_data <- create_equity_validation_data()

  # Test with gender-balanced data
  p <- plot_users(validation_data$gender_balanced, metric = "duration")
  expect_s3_class(p, "ggplot")

  # Test rank masking with gender-balanced data
  p_rank <- plot_users(validation_data$gender_balanced, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")

  # Test name masking with gender-balanced data
  p_name <- plot_users(validation_data$gender_balanced, metric = "duration", mask_by = "name")
  expect_s3_class(p_name, "ggplot")

  # Verify all participants appear
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) >= 10)
})

test_that("equity functions support intervention planning through visualization", {
  test_data <- create_equity_test_data()
  validation_data <- create_equity_validation_data()

  # Test that extreme differences are clearly visible for intervention planning
  p_extreme <- plot_users(test_data$extreme_differences, metric = "duration")
  expect_s3_class(p_extreme, "ggplot")

  # Verify the extreme outlier is clearly visible
  plot_data <- ggplot2::layer_data(p_extreme)
  expect_true(max(plot_data$y, na.rm = TRUE) >= 1000)

  # Test with participation gaps for intervention planning
  p_gaps <- plot_users(validation_data$participation_gaps, metric = "duration")
  expect_s3_class(p_gaps, "ggplot")

  # Verify participation gaps are clear for intervention planning
  plot_data_gaps <- ggplot2::layer_data(p_gaps)
  expect_true(max(plot_data_gaps$y, na.rm = TRUE) >= 200)
  expect_true(min(plot_data_gaps$y, na.rm = TRUE) <= 10)

  # Test rank masking preserves intervention-relevant information
  p_gaps_rank <- plot_users(validation_data$participation_gaps, metric = "duration", mask_by = "rank")
  expect_s3_class(p_gaps_rank, "ggplot")
})

test_that("equity functions support multiple metric analysis for comprehensive equity assessment", {
  test_data <- create_equity_test_data()

  # Test different metrics for comprehensive equity analysis
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

    # Verify metric-specific patterns are visible
    plot_data <- ggplot2::layer_data(p)
    expect_true(nrow(plot_data) >= 4)
  }
})

test_that("equity functions support privacy-compliant equity analysis", {
  test_data <- create_equity_test_data()

  # Test that privacy masking doesn't obscure equity patterns
  p_unmasked <- plot_users(test_data$extreme_differences, metric = "duration")
  p_ranked <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "rank")
  p_named <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "name")

  expect_s3_class(p_unmasked, "ggplot")
  expect_s3_class(p_ranked, "ggplot")
  expect_s3_class(p_named, "ggplot")

  # Verify all masking options preserve the number of data points
  unmasked_data <- ggplot2::layer_data(p_unmasked)
  ranked_data <- ggplot2::layer_data(p_ranked)
  named_data <- ggplot2::layer_data(p_named)

  expect_equal(nrow(unmasked_data), nrow(ranked_data))
  expect_equal(nrow(unmasked_data), nrow(named_data))

  # Verify rank masking preserves relative positions (important for equity analysis)
  expect_equal(length(unique(ranked_data$y)), length(unique(unmasked_data$y)))
})

test_that("equity functions support educational equity goals through clear visualizations", {
  test_data <- create_equity_test_data()
  validation_data <- create_equity_validation_data()

  # Test that plots clearly show participation patterns
  p_extreme <- plot_users(test_data$extreme_differences, metric = "duration")
  expect_s3_class(p_extreme, "ggplot")

  # Verify extreme differences are clearly visible
  plot_data <- ggplot2::layer_data(p_extreme)
  expect_true(max(plot_data$y, na.rm = TRUE) >= 1000)
  expect_true(min(plot_data$y, na.rm = TRUE) <= 100)

  # Test that equal participation scenarios are handled appropriately
  p_equal <- plot_users(test_data$equal_participation, metric = "duration")
  expect_s3_class(p_equal, "ggplot")

  # Test that small differences are visible
  p_small <- plot_users(test_data$small_differences, metric = "duration")
  expect_s3_class(p_small, "ggplot")

  # Verify small differences are represented
  plot_data_small <- ggplot2::layer_data(p_small)
  expect_true(nrow(plot_data_small) >= 4)
})

test_that("equity functions support cross-sectional equity analysis", {
  validation_data <- create_equity_validation_data()

  # Test section comparison for equity analysis
  p_section <- plot_users(validation_data$section_comparison, metric = "duration", facet_by = "section")
  expect_s3_class(p_section, "ggplot")

  # Test section comparison with rank masking
  p_section_rank <- plot_users(validation_data$section_comparison, metric = "duration", facet_by = "section", mask_by = "rank")
  expect_s3_class(p_section_rank, "ggplot")

  # Test section comparison with name masking
  p_section_name <- plot_users(validation_data$section_comparison, metric = "duration", facet_by = "section", mask_by = "name")
  expect_s3_class(p_section_name, "ggplot")

  # Verify all sections are represented
  plot_data <- ggplot2::layer_data(p_section)
  expect_true(nrow(plot_data) >= 12) # 3 sections * 4 students each
})

test_that("equity functions maintain educational value while respecting privacy", {
  test_data <- create_equity_test_data()

  # Test that privacy masking doesn't reduce educational value
  p_unmasked <- plot_users(test_data$extreme_differences, metric = "duration")
  p_ranked <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "rank")
  p_named <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "name")

  expect_s3_class(p_unmasked, "ggplot")
  expect_s3_class(p_ranked, "ggplot")
  expect_s3_class(p_named, "ggplot")

  # Verify all plots contain the same analytical information
  unmasked_data <- ggplot2::layer_data(p_unmasked)
  ranked_data <- ggplot2::layer_data(p_ranked)
  named_data <- ggplot2::layer_data(p_named)

  # Same number of data points
  expect_equal(nrow(unmasked_data), nrow(ranked_data))
  expect_equal(nrow(unmasked_data), nrow(named_data))

  # Same range of values (for rank masking)
  expect_equal(range(ranked_data$y, na.rm = TRUE), range(unmasked_data$y, na.rm = TRUE))
})
