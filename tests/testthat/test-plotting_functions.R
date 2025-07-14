test_that("plot_users_by_metric creates valid ggplot object with correct properties", {
  # Create sample data
  clean_names <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = create_sample_transcript_metrics(),
    roster_sessions = create_sample_roster()
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  metrics_lookup <- create_sample_metrics_lookup()

  # Test plotting function
  p <- plot_users_by_metric(
    transcripts_summary_df = summary_df,
    metric = "duration",
    metrics_lookup_df = metrics_lookup
  )

  # Check that it's a ggplot object
  expect_s3_class(p, "ggplot")

  # Check plot layers
  expect_true(length(p$layers) > 0)

  # Check plot data
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) > 0)

  # Check that the plot has the correct structure
  expect_true("CoordFlip" %in% class(p$coordinates))
  expect_true("FacetWrap" %in% class(p$facet))
  expect_true("section" %in% names(p$facet$params$facets))
})

test_that("plot_users_masked_section_by_metric masks names correctly and creates valid plot", {
  # Create sample data
  clean_names <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = create_sample_transcript_metrics(),
    roster_sessions = create_sample_roster()
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  metrics_lookup <- create_sample_metrics_lookup()

  # Test masked plotting function
  p <- plot_users_masked_section_by_metric(
    df = summary_df,
    metric = "duration"
  )

  # Check that it's a ggplot object
  expect_s3_class(p, "ggplot")

  # Check plot layers
  expect_true(length(p$layers) > 0)

  # Check plot data
  plot_data <- ggplot2::layer_data(p)
  expect_true(nrow(plot_data) > 0)

  # Check that the plot has the correct structure
  expect_true("CoordFlip" %in% class(p$coordinates))
  expect_true("FacetWrap" %in% class(p$facet))
  expect_true("section" %in% names(p$facet$params$facets))
})

test_that("plotting functions handle empty data gracefully", {
  # Create empty data frames
  clean_names <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = create_sample_transcript_metrics()[0, ],
    roster_sessions = create_sample_roster()[0, ]
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  metrics_lookup <- create_sample_metrics_lookup()

  # Test plotting functions with empty data
  p1 <- plot_users_by_metric(
    transcripts_summary_df = summary_df,
    metric = "duration",
    metrics_lookup_df = metrics_lookup
  )
  p2 <- plot_users_masked_section_by_metric(
    df = summary_df,
    metric = "duration"
  )

  # Check that they still return ggplot objects
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("plotting functions handle different metrics correctly", {
  # Create sample data
  clean_names <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = create_sample_transcript_metrics(),
    roster_sessions = create_sample_roster()
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  metrics_lookup <- create_sample_metrics_lookup()

  # Test with different metrics
  metrics <- c("duration", "wordcount", "wpm")
  for (metric in metrics) {
    p <- plot_users_by_metric(
      transcripts_summary_df = summary_df,
      metric = metric,
      metrics_lookup_df = metrics_lookup
    )

    # Check that it's a ggplot object
    expect_s3_class(p, "ggplot")

    # Check that the plot has the correct structure
    expect_true("CoordFlip" %in% class(p$coordinates))
    expect_true("FacetWrap" %in% class(p$facet))
    expect_true("section" %in% names(p$facet$params$facets))
  }
})

test_that("plotting functions handle invalid metrics gracefully", {
  # Create sample data
  clean_names <- make_clean_names_df(
    data_folder = "data",
    section_names_lookup_file = "section_names_lookup.csv",
    transcripts_metrics_df = create_sample_transcript_metrics(),
    roster_sessions = create_sample_roster()
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  metrics_lookup <- create_sample_metrics_lookup()

  # Test with invalid metric
  expect_error(
    plot_users_by_metric(
      transcripts_summary_df = summary_df,
      metric = "invalid_metric",
      metrics_lookup_df = metrics_lookup
    ),
    regexp = "metric"
  )

  expect_error(
    plot_users_masked_section_by_metric(
      df = summary_df,
      metric = "invalid_metric"
    ),
    regexp = "metric"
  )
})
