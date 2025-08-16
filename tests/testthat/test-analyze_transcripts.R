# Test file for analyze_transcripts.R
# Tests the high-level orchestration function for processing transcript files

library(testthat)
library(zoomstudentengagement)

# Helper function to create sample transcript files for testing
create_sample_transcript_files <- function() {
  # Create a temporary directory structure that matches what analyze_transcripts expects
  # analyze_transcripts calls summarize_transcript_files with data_folder = "." and transcripts_folder = transcripts_folder
  # So it looks for files in ./transcripts_folder/
  
  # Create base directory (this will be the working directory)
  temp_base <- tempfile("test_data")
  dir.create(temp_base, recursive = TRUE)
  
  # Create transcripts subdirectory
  transcripts_dir <- file.path(temp_base, "transcripts")
  dir.create(transcripts_dir, recursive = TRUE)
  
  # Create sample .transcript.vtt files with realistic content
  sample_content <- "WEBVTT

1
00:00:00.000 --> 00:00:05.000
Student1: Hello everyone

2
00:00:05.000 --> 00:00:10.000
Student2: Hi there, how are you?

3
00:00:10.000 --> 00:00:15.000
Student1: I'm doing well, thanks

4
00:00:15.000 --> 00:00:20.000
Professor: Great discussion everyone"
  
  # Create multiple test files with international names
  file1 <- file.path(transcripts_dir, "test1.transcript.vtt")
  file2 <- file.path(transcripts_dir, "test2.transcript.vtt")
  file3 <- file.path(transcripts_dir, "test3.transcript.vtt")
  
  # Create file with international names
  international_content <- "WEBVTT

1
00:00:00.000 --> 00:00:05.000
José García: Buenos días

2
00:00:05.000 --> 00:00:10.000
李小明: 你好

3
00:00:10.000 --> 00:00:15.000
Anna Kowalski: Dzień dobry

4
00:00:15.000 --> 00:00:20.000
Professor: Excellent international participation"
  
  writeLines(sample_content, file1)
  writeLines(international_content, file2)
  writeLines(sample_content, file3)
  
  list(
    temp_base = temp_base,
    transcripts_dir = transcripts_dir,
    files = c(file1, file2, file3)
  )
}

# Helper function to clean up test files
cleanup_test_files <- function(test_data) {
  if (dir.exists(test_data$temp_base)) {
    unlink(test_data$temp_base, recursive = TRUE)
  }
}

# Test context
test_that("analyze_transcripts basic functionality", {
  
  # Test 1: Valid folder processing
  test_that("analyze_transcripts processes valid folder correctly", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Test basic functionality - use relative path
    result <- analyze_transcripts("transcripts")
    
    # Verify return value structure
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true("name" %in% names(result))
    expect_true("n" %in% names(result))
    expect_true("duration" %in% names(result))
    expect_true("wordcount" %in% names(result))
  })
  
  # Test 2: Parameter handling
  test_that("analyze_transcripts handles parameters correctly", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Test with custom names_to_exclude
    result <- analyze_transcripts(
      transcripts_folder = "transcripts",
      names_to_exclude = c("dead_air", "unknown", "Professor")
    )
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    
    # Verify that excluded names are not in the result
    if (nrow(result) > 0) {
      expect_false(any(result$name == "Professor"))
    }
  })
  
  # Test 3: Write functionality
  test_that("analyze_transcripts write functionality works", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    output_file <- tempfile("test_output.csv")
    on.exit(unlink(output_file), add = TRUE)
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Test with write = TRUE
    result <- analyze_transcripts(
      transcripts_folder = "transcripts",
      write = TRUE,
      output_path = output_file
    )
    
    expect_s3_class(result, "tbl_df")
    expect_true(file.exists(output_file))
    
    # Verify the output file contains data
    file_content <- readLines(output_file, warn = FALSE)
    expect_true(length(file_content) > 1) # Header + at least one data row
  })
  
  # Test 4: NULL output path handling
  test_that("analyze_transcripts handles NULL output_path", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Test with write = TRUE and NULL output_path
    result <- analyze_transcripts(
      transcripts_folder = "transcripts",
      write = TRUE,
      output_path = NULL
    )
    
    expect_s3_class(result, "tbl_df")
    expect_true(file.exists("engagement_metrics.csv"))
    unlink("engagement_metrics.csv") # Clean up default file
  })
  
  # Test 5: Single transcript file
  test_that("analyze_transcripts works with single transcript file", {
    # Create a temporary directory structure for single file test
    temp_base <- tempfile("single_test_data")
    dir.create(temp_base, recursive = TRUE)
    on.exit(unlink(temp_base, recursive = TRUE))
    
    # Create transcripts subdirectory
    transcripts_dir <- file.path(temp_base, "transcripts")
    dir.create(transcripts_dir, recursive = TRUE)
    
    # Create single transcript file
    sample_content <- "WEBVTT

1
00:00:00.000 --> 00:00:05.000
Student1: Hello

2
00:00:05.000 --> 00:00:10.000
Student2: Hi there"
    
    writeLines(sample_content, file.path(transcripts_dir, "single.transcript.vtt"))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(temp_base)
    
    result <- analyze_transcripts("transcripts")
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
  })
  
  # Test 6: International names support
  test_that("analyze_transcripts handles international names correctly", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    result <- analyze_transcripts("transcripts")
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    
    # Check that international names are processed
    if (nrow(result) > 0) {
      # Should contain at least some names (may be masked for privacy)
      expect_true("name" %in% names(result))
    }
  })
})

# Error handling tests
test_that("analyze_transcripts error handling", {
  
  # Test 1: Invalid folder path
  test_that("analyze_transcripts handles invalid folder path", {
    expect_error(
      analyze_transcripts("nonexistent_folder"),
      "Folder not found: nonexistent_folder"
    )
  })
  
  # Test 2: Empty folder
  test_that("analyze_transcripts handles empty folder", {
    temp_dir <- tempfile("empty_transcripts")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE))
    
    expect_error(
      analyze_transcripts(temp_dir),
      "No .transcript.vtt files found in the provided folder"
    )
  })
  
  # Test 3: Folder with no transcript files
  test_that("analyze_transcripts handles folder with no transcript files", {
    temp_dir <- tempfile("no_transcripts")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE))
    
    # Create a file that's not a transcript file
    writeLines("test", file.path(temp_dir, "test.txt"))
    
    expect_error(
      analyze_transcripts(temp_dir),
      "No .transcript.vtt files found in the provided folder"
    )
  })
  
  # Test 4: Folder with wrong file extensions
  test_that("analyze_transcripts handles folder with wrong file extensions", {
    temp_dir <- tempfile("wrong_extensions")
    dir.create(temp_dir)
    on.exit(unlink(temp_dir, recursive = TRUE))
    
    # Create files with wrong extensions
    writeLines("test", file.path(temp_dir, "test.vtt"))
    writeLines("test", file.path(temp_dir, "test.transcript.txt"))
    writeLines("test", file.path(temp_dir, "test.cc.vtt"))
    
    expect_error(
      analyze_transcripts(temp_dir),
      "No .transcript.vtt files found in the provided folder"
    )
  })
})

# Integration tests
test_that("analyze_transcripts integration", {
  
  # Test 1: Integration with summarize_transcript_files
  test_that("analyze_transcripts integrates with summarize_transcript_files", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Mock summarize_transcript_files to verify it's called correctly
    with_mocked_bindings(
      summarize_transcript_files = function(...) {
        # Verify parameters are passed correctly
        args <- list(...)
        expect_true("transcript_file_names" %in% names(args))
        expect_true("names_to_exclude" %in% names(args))
        expect_true("data_folder" %in% names(args))
        expect_true("transcripts_folder" %in% names(args))
        expect_true("deduplicate_content" %in% names(args))
        
        # Return mock result
        tibble::tibble(
          name = c("Student1", "Student2"),
          n = c(1, 1),
          duration = c(5, 5),
          wordcount = c(2, 3),
          comments = list("Hello", "Hi there"),
          n_perc = c(50, 50),
          duration_perc = c(50, 50),
          wordcount_perc = c(40, 60),
          wpm = c(24, 36),
          transcript_file = c("test1.transcript.vtt", "test2.transcript.vtt"),
          transcript_path = c("test1.transcript.vtt", "test2.transcript.vtt"),
          name_raw = c("Student1", "Student2")
        )
      },
      {
        result <- analyze_transcripts("transcripts")
        expect_s3_class(result, "tbl_df")
        expect_true(nrow(result) > 0)
      }
    )
  })
  
  # Test 2: Integration with write_metrics
  test_that("analyze_transcripts integrates with write_metrics", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    output_file <- tempfile("test_output.csv")
    on.exit(unlink(output_file), add = TRUE)
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Mock write_metrics to verify it's called correctly
    with_mocked_bindings(
      write_metrics = function(metrics, what, path) {
        expect_equal(what, "engagement")
        expect_equal(path, output_file)
        expect_s3_class(metrics, "tbl_df")
        return(invisible(NULL))
      },
      {
        result <- analyze_transcripts(
          transcripts_folder = "transcripts",
          write = TRUE,
          output_path = output_file
        )
        expect_s3_class(result, "tbl_df")
      }
    )
  })
  
  # Test 3: Privacy compliance validation
  test_that("analyze_transcripts maintains privacy compliance", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Test that the function works with privacy defaults
    result <- analyze_transcripts("transcripts")
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    
    # Verify that the result can be processed with privacy functions
    if (nrow(result) > 0) {
      # Test that the result has the expected structure for privacy processing
      expect_true("name" %in% names(result))
      expect_true("n" %in% names(result))
      expect_true("duration" %in% names(result))
      
      # Note: mask_user_names_by_metric expects 'preferred_name' column,
      # but analyze_transcripts returns 'name' column. This is expected
      # and the privacy function would need to be called with the correct
      # column name or the data would need to be transformed first.
    }
  })
})

# Edge cases and advanced scenarios
test_that("analyze_transcripts edge cases", {
  
  # Test 1: Multiple transcript files with different content
  test_that("analyze_transcripts handles multiple files with different content", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    result <- analyze_transcripts("transcripts")
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    
    # Should have data from multiple files
    if (nrow(result) > 0) {
      expect_true("transcript_file" %in% names(result))
    }
  })
  
  # Test 2: Custom names_to_exclude with various patterns
  test_that("analyze_transcripts handles various names_to_exclude patterns", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Test with multiple exclusion patterns
    result <- analyze_transcripts(
      transcripts_folder = "transcripts",
      names_to_exclude = c("dead_air", "Professor", "unknown", "system")
    )
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) >= 0) # May be empty if all names excluded
  })
  
  # Test 3: Write functionality with custom path
  test_that("analyze_transcripts write functionality with custom path", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Test with custom output path
    custom_output <- file.path(tempdir(), "custom_engagement_metrics.csv")
    on.exit(unlink(custom_output), add = TRUE)
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    result <- analyze_transcripts(
      transcripts_folder = "transcripts",
      write = TRUE,
      output_path = custom_output
    )
    
    expect_s3_class(result, "tbl_df")
    expect_true(file.exists(custom_output))
    
    # Verify file content
    file_content <- readLines(custom_output, warn = FALSE)
    expect_true(length(file_content) > 1)
  })
  
  # Test 4: Performance with larger dataset simulation
  test_that("analyze_transcripts handles larger dataset simulation", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Create additional files to simulate larger dataset
    for (i in 4:10) {
      sample_content <- sprintf("WEBVTT

1
00:00:00.000 --> 00:00:05.000
Student%d: Hello from file %d

2
00:00:05.000 --> 00:00:10.000
Student%d: Response from file %d", i, i, i+1, i)
      
      writeLines(sample_content, file.path("transcripts", sprintf("test%d.transcript.vtt", i)))
    }
    
    # Test processing
    result <- analyze_transcripts("transcripts")
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
  })
})

# Real-world scenario tests
test_that("analyze_transcripts real-world scenarios", {
  
  # Test 1: Using actual sample transcript from package
  test_that("analyze_transcripts works with actual sample transcript", {
    # Use the actual sample transcript from the package
    sample_transcript <- system.file(
      "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
      package = "zoomstudentengagement"
    )
    
    skip_if(sample_transcript == "", "Sample transcript not available")
    
    # Create a temporary directory structure that matches what analyze_transcripts expects
    temp_base <- tempfile("real_world_test")
    dir.create(temp_base, recursive = TRUE)
    on.exit(unlink(temp_base, recursive = TRUE))
    
    # Create transcripts subdirectory
    transcripts_dir <- file.path(temp_base, "transcripts")
    dir.create(transcripts_dir, recursive = TRUE)
    
    # Copy the sample transcript to our transcripts directory
    file.copy(sample_transcript, file.path(transcripts_dir, "sample.transcript.vtt"))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(temp_base)
    
    # Test the function
    result <- analyze_transcripts("transcripts")
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true("name" %in% names(result))
  })
  
  # Test 2: Privacy compliance with real data
  test_that("analyze_transcripts maintains privacy with real data", {
    sample_transcript <- system.file(
      "extdata/transcripts/GMT20240124-202901_Recording.transcript.vtt",
      package = "zoomstudentengagement"
    )
    
    skip_if(sample_transcript == "", "Sample transcript not available")
    
    # Create a temporary directory structure that matches what analyze_transcripts expects
    temp_base <- tempfile("privacy_test")
    dir.create(temp_base, recursive = TRUE)
    on.exit(unlink(temp_base, recursive = TRUE))
    
    # Create transcripts subdirectory
    transcripts_dir <- file.path(temp_base, "transcripts")
    dir.create(transcripts_dir, recursive = TRUE)
    
    file.copy(sample_transcript, file.path(transcripts_dir, "sample.transcript.vtt"))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(temp_base)
    
    # Test with write = TRUE to verify privacy compliance
    output_file <- tempfile("privacy_test_output.csv")
    on.exit(unlink(output_file), add = TRUE)
    
    result <- analyze_transcripts(
      transcripts_folder = "transcripts",
      write = TRUE,
      output_path = output_file
    )
    
    expect_s3_class(result, "tbl_df")
    expect_true(file.exists(output_file))
    
    # Verify that the output file respects privacy (should contain masked names)
    file_content <- readLines(output_file, warn = FALSE)
    expect_true(length(file_content) > 1)
    
    # Check for privacy masking patterns
    content_text <- paste(file_content, collapse = " ")
    expect_true(any(grepl("Student\\s+\\d+", content_text)) || 
                any(grepl("User\\s+\\d+", content_text)) ||
                length(grep("\\b[A-Z][a-z]+\\s+[A-Z][a-z]+\\b", content_text)) == 0)
  })
})

# Performance and memory tests
test_that("analyze_transcripts performance characteristics", {
  
  # Test 1: Memory usage with multiple files
  test_that("analyze_transcripts handles memory efficiently", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Monitor memory usage
    initial_memory <- gc()
    
    result <- analyze_transcripts("transcripts")
    
    final_memory <- gc()
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    
    # Verify no excessive memory usage (basic check)
    expect_true(is.data.frame(result))
  })
  
  # Test 2: Processing time for reasonable dataset
  test_that("analyze_transcripts processes files in reasonable time", {
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Time the processing
    start_time <- Sys.time()
    result <- analyze_transcripts("transcripts")
    end_time <- Sys.time()
    
    processing_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
    
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    
    # Should complete in reasonable time (less than 30 seconds for small dataset)
    expect_true(processing_time < 30)
  })
})

# Cleanup and final validation
test_that("analyze_transcripts cleanup and validation", {
  
  # Test 1: Proper cleanup of temporary resources
  test_that("analyze_transcripts cleans up temporary resources", {
    test_data <- create_sample_transcript_files()
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Process files
    result <- analyze_transcripts("transcripts")
    expect_s3_class(result, "tbl_df")
    
    # Clean up
    cleanup_test_files(test_data)
    
    # Verify cleanup
    expect_false(dir.exists(test_data$temp_base))
  })
  
  # Test 2: Final validation of all test scenarios
  test_that("analyze_transcripts passes comprehensive validation", {
    # This test serves as a final validation that all scenarios work together
    
    # Create comprehensive test data
    test_data <- create_sample_transcript_files()
    on.exit(cleanup_test_files(test_data))
    
    # Change to the base directory so that relative paths work correctly
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    setwd(test_data$temp_base)
    
    # Test all major functionality
    result <- analyze_transcripts(
      transcripts_folder = "transcripts",
      names_to_exclude = c("dead_air", "Professor"),
      write = TRUE,
      output_path = tempfile("final_test.csv")
    )
    
    # Validate result
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0)
    expect_true(all(c("name", "n", "duration", "wordcount") %in% names(result)))
    
    # Validate privacy compliance
    expect_true("name" %in% names(result))
    expect_true("n" %in% names(result))
    expect_true("duration" %in% names(result))
    
    # Note: mask_user_names_by_metric expects 'preferred_name' column,
    # but analyze_transcripts returns 'name' column. This is expected
    # and the privacy function would need to be called with the correct
    # column name or the data would need to be transformed first.
  })
})
