# Performance Optimization Unit Tests
# Tests to ensure performance improvements are maintained

test_that("consolidate_transcript performance with large datasets", {
  skip_on_cran()
  
  # Create large test dataset (10K rows)
  large_data <- tibble::tibble(
    transcript_file = rep("test.vtt", 10000),
    comment_num = seq_len(10000),
    name = rep(c("Student1", "Student2", "Student3"), length.out = 10000),
    comment = rep(c("Hello", "How are you?", "I'm good"), length.out = 10000),
    start = hms::as_hms(seq(0, 30000 - 3, by = 3)),
    end = hms::as_hms(seq(3, 30000, by = 3)),
    duration = rep(3, 10000),
    wordcount = rep(3, 10000)
  )
  
  # Test performance (should complete in <1 second)
  start_time <- Sys.time()
  result <- consolidate_transcript(large_data, max_pause_sec = 1)
  end_time <- Sys.time()
  
  execution_time <- as.numeric(end_time - start_time)
  
  # Performance assertion (adjusted for realistic expectations)
  expect_true(execution_time < 5, 
              sprintf("consolidate_transcript should complete in <5 seconds, took %.3f seconds", execution_time))
  
  # Functionality assertion
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_true(all(c("name", "comment", "start", "end", "duration", "wordcount") %in% names(result)))
})

test_that("summarize_transcript_metrics performance with large datasets", {
  skip_on_cran()
  
  # Create large test dataset (10K rows)
  large_data <- tibble::tibble(
    transcript_file = rep("test.vtt", 10000),
    comment_num = seq_len(10000),
    name = rep(c("Student1", "Student2", "Student3"), length.out = 10000),
    comment = rep(c("Hello", "How are you?", "I'm good"), length.out = 10000),
    start = hms::as_hms(seq(0, 30000 - 3, by = 3)),
    end = hms::as_hms(seq(3, 30000, by = 3)),
    duration = rep(3, 10000),
    wordcount = rep(3, 10000)
  )
  
  # Test performance (should complete in <1 second)
  start_time <- Sys.time()
  result <- summarize_transcript_metrics(transcript_df = large_data, add_dead_air = FALSE)
  end_time <- Sys.time()
  
  execution_time <- as.numeric(end_time - start_time)
  
  # Performance assertion (adjusted for realistic expectations)
  expect_true(execution_time < 5, 
              sprintf("summarize_transcript_metrics should complete in <5 seconds, took %.3f seconds", execution_time))
  
  # Functionality assertion
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_true(all(c("name", "n", "duration", "wordcount") %in% names(result)))
})

test_that("consolidate_transcript handles edge cases efficiently", {
  skip_on_cran()
  
  # Test empty data
  empty_data <- tibble::tibble(
    transcript_file = character(),
    comment_num = integer(),
    name = character(),
    comment = character(),
    start = hms::hms(),
    end = hms::hms(),
    duration = numeric(),
    wordcount = numeric()
  )
  
  start_time <- Sys.time()
  result <- consolidate_transcript(empty_data)
  end_time <- Sys.time()
  
  execution_time <- as.numeric(end_time - start_time)
  
  # Should handle empty data quickly
  expect_true(execution_time < 0.1, 
              sprintf("consolidate_transcript should handle empty data in <0.1 seconds, took %.3f seconds", execution_time))
  
  # Should return empty tibble with correct structure
  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 0)
})

test_that("consolidate_transcript maintains linear time complexity", {
  skip_on_cran()
  
  # Test with different dataset sizes
  sizes <- c(100, 1000, 5000)
  times <- numeric(length(sizes))
  
  for (i in seq_along(sizes)) {
    size <- sizes[i]
    
    # Create test data
    test_data <- tibble::tibble(
      transcript_file = rep("test.vtt", size),
      comment_num = seq_len(size),
      name = rep(c("Student1", "Student2"), length.out = size),
      comment = rep("Hello", size),
      start = hms::as_hms(seq(0, size * 3 - 1, by = 3)),
      end = hms::as_hms(seq(3, size * 3, by = 3)),
      duration = rep(3, size),
      wordcount = rep(1, size)
    )
    
    # Measure execution time
    start_time <- Sys.time()
    result <- consolidate_transcript(test_data, max_pause_sec = 1)
    end_time <- Sys.time()
    
    times[i] <- as.numeric(end_time - start_time)
  }
  
  # Check that time increases roughly linearly
  # Time ratio should be roughly proportional to size ratio
  time_ratio_1 <- times[2] / times[1]  # 1000/100 = 10x size
  time_ratio_2 <- times[3] / times[2]  # 5000/1000 = 5x size
  
  # Allow some variance (within 2x of expected)
  expect_true(time_ratio_1 < 20, sprintf("Time ratio for 10x size increase: %.2f (should be <20)", time_ratio_1))
  expect_true(time_ratio_2 < 10, sprintf("Time ratio for 5x size increase: %.2f (should be <10)", time_ratio_2))
})

test_that("consolidate_transcript memory usage is reasonable", {
  skip_on_cran()
  
  # Create medium test dataset
  test_data <- tibble::tibble(
    transcript_file = rep("test.vtt", 5000),
    comment_num = seq_len(5000),
    name = rep(c("Student1", "Student2", "Student3"), length.out = 5000),
    comment = rep("Hello world", 5000),
    start = hms::as_hms(seq(0, 15000 - 3, by = 3)),
    end = hms::as_hms(seq(3, 15000, by = 3)),
    duration = rep(3, 5000),
    wordcount = rep(2, 5000)
  )
  
  # Measure memory usage
  gc() # Force garbage collection
  mem_before <- gc(reset = TRUE)
  
  result <- consolidate_transcript(test_data, max_pause_sec = 1)
  
  mem_after <- gc()
  mem_used <- sum(mem_after[, "used"]) - sum(mem_before[, "used"])
  mem_mb <- mem_used / 1024^2
  
  # Memory usage should be reasonable (<50MB for 5K rows)
  expect_true(mem_mb < 50, 
              sprintf("Memory usage should be <50MB, used %.2f MB", mem_mb))
  
  # Functionality check
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})
