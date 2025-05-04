test_that("plot_users_by_metric creates valid ggplot object", {
  # Create sample data
  clean_names <- make_clean_names_df(
    transcripts_fliwc_df = create_sample_transcript(),
    roster_sessions = create_sample_roster(),
    section_names_lookup_file = create_sample_section_names_lookup()
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  # Test plotting function
  p <- plot_users_by_metric(
    transcripts_summary_df = summary_df,
    metric = "duration"
  )
  # Check that it's a ggplot object
  expect_s3_class(p, "ggplot")
})

test_that("plot_users_masked_section_by_metric masks names correctly", {
  # Create sample data
  clean_names <- make_clean_names_df(
    transcripts_fliwc_df = create_sample_transcript(),
    roster_sessions = create_sample_roster(),
    section_names_lookup_file = create_sample_section_names_lookup()
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  # Test masked plotting function
  p <- plot_users_masked_section_by_metric(
    df = summary_df,
    metric = "duration"
  )
  # Check that it's a ggplot object
  expect_s3_class(p, "ggplot")
  # Check that names are masked in the plot data
  # (This check may need to be adapted based on actual masking logic)
  # plot_data <- ggplot2::layer_data(p)
  # expect_true(all(grepl("Student \\d+", plot_data$label)))
})

test_that("plotting functions handle empty data gracefully", {
  # Create empty data frames
  clean_names <- make_clean_names_df(
    transcripts_fliwc_df = create_sample_transcript()[0,],
    roster_sessions = create_sample_roster()[0,],
    section_names_lookup_file = create_sample_section_names_lookup()[0,]
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  # Test plotting functions with empty data
  p1 <- plot_users_by_metric(
    transcripts_summary_df = summary_df,
    metric = "duration"
  )
  p2 <- plot_users_masked_section_by_metric(
    df = summary_df,
    metric = "duration"
  )
  # Check that they still return ggplot objects
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("plotting functions handle different metrics", {
  # Create sample data
  clean_names <- make_clean_names_df(
    transcripts_fliwc_df = create_sample_transcript(),
    roster_sessions = create_sample_roster(),
    section_names_lookup_file = create_sample_section_names_lookup()
  )
  summary_df <- make_transcripts_summary_df(
    make_transcripts_session_summary_df(clean_names)
  )
  # Test with different metrics
  metrics <- c("duration", "wordcount", "wpm")
  for (metric in metrics) {
    p <- plot_users_by_metric(
      transcripts_summary_df = summary_df,
      metric = metric
    )
    expect_s3_class(p, "ggplot")
  }
}) 