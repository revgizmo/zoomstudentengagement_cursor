test_that("plot_users_by_metric creates valid ggplot object", {
  # Create sample data
  sample_transcript <- create_sample_transcript()
  sample_roster <- create_sample_roster()
  
  # Test plotting function
  p <- plot_users_by_metric(
    transcripts_df = sample_transcript,
    roster_df = sample_roster,
    metric = "duration"
  )
  
  # Check that it's a ggplot object
  expect_s3_class(p, "ggplot")
})

test_that("plot_users_masked_section_by_metric masks names correctly", {
  # Create sample data
  sample_transcript <- create_sample_transcript()
  sample_roster <- create_sample_roster()
  
  # Test masked plotting function
  p <- plot_users_masked_section_by_metric(
    transcripts_df = sample_transcript,
    roster_df = sample_roster,
    metric = "duration"
  )
  
  # Check that it's a ggplot object
  expect_s3_class(p, "ggplot")
  
  # Check that names are masked in the plot data
  plot_data <- ggplot2::layer_data(p)
  expect_true(all(grepl("Student \\d+", plot_data$label)))
})

test_that("plotting functions handle empty data gracefully", {
  # Create empty data frames
  empty_transcript <- tibble::tibble(
    begin = lubridate::hms(),
    end = lubridate::hms(),
    name = character(),
    text = character(),
    duration = numeric()
  )
  empty_roster <- tibble::tibble(
    student_id = character(),
    name = character(),
    section = character()
  )
  
  # Test plotting functions with empty data
  p1 <- plot_users_by_metric(
    transcripts_df = empty_transcript,
    roster_df = empty_roster,
    metric = "duration"
  )
  
  p2 <- plot_users_masked_section_by_metric(
    transcripts_df = empty_transcript,
    roster_df = empty_roster,
    metric = "duration"
  )
  
  # Check that they still return ggplot objects
  expect_s3_class(p1, "ggplot")
  expect_s3_class(p2, "ggplot")
})

test_that("plotting functions handle different metrics", {
  # Create sample data
  sample_transcript <- create_sample_transcript()
  sample_roster <- create_sample_roster()
  
  # Test with different metrics
  metrics <- c("duration", "wordcount", "wpm")
  
  for (metric in metrics) {
    p <- plot_users_by_metric(
      transcripts_df = sample_transcript,
      roster_df = sample_roster,
      metric = metric
    )
    expect_s3_class(p, "ggplot")
  }
}) 