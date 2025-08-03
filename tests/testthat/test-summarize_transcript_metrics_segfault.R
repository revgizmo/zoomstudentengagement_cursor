# Test file for summarize_transcript_metrics segmentation fault analysis
# This test uses minimal reproducible input and extensive logging

test_that("summarize_transcript_metrics minimal test with logging", {
  # Skip on CRAN to avoid issues
  skip_on_cran()

  # Create minimal test data
  minimal_data <- tibble::tibble(
    transcript_file = "test.vtt",
    comment_num = c("1", "2", "3", "4"),
    name = c("Student1", "Student1", "Student2", "Student2"),
    comment = c("Hello", "How are you?", "I'm good", "Thanks"),
    start = hms::as_hms(c("00:00:00", "00:00:05", "00:00:10", "00:00:15")),
    end = hms::as_hms(c("00:00:03", "00:00:08", "00:00:13", "00:00:18")),
    duration = hms::as_hms(c("00:00:03", "00:00:03", "00:00:03", "00:00:03")),
    wordcount = c(1, 3, 2, 1)
  )

  message("=== Testing summarize_transcript_metrics with minimal data ===")
  message("Input data dimensions: ", nrow(minimal_data), " x ", ncol(minimal_data))
  message("Input data columns: ", paste(names(minimal_data), collapse = ", "))

  # Test with tryCatch and extensive logging
  result <- tryCatch(
    {
      message("Step 1: About to call summarize_transcript_metrics...")

      # Load the function
      devtools::load_all()

      message("Step 2: Function loaded, calling summarize_transcript_metrics...")

      # Call the function with correct parameters
      result <- summarize_transcript_metrics(
        transcript_df = minimal_data,
        names_exclude = list() # No exclusions
      )

      message("Step 3: summarize_transcript_metrics completed successfully")
      message("Result dimensions: ", nrow(result), " x ", ncol(result))

      return(result)
    },
    error = function(e) {
      message("ERROR in summarize_transcript_metrics: ", e$message)
      message("Error call: ", deparse(e$call))
      print(traceback())
      return(NULL)
    },
    warning = function(w) {
      message("WARNING in summarize_transcript_metrics: ", w$message)
      return(NULL)
    }
  )

  # Check if we got a result
  expect_false(is.null(result), "summarize_transcript_metrics should not return NULL")

  if (!is.null(result)) {
    expect_s3_class(result, "tbl_df")
    expect_true(nrow(result) > 0, "Result should have at least one row")
    expect_true("name" %in% names(result), "Result should have 'name' column")
  }
})

test_that("summarize_transcript_metrics with rlang::syms debugging", {
  # Skip on CRAN to avoid issues
  skip_on_cran()

  # Create minimal test data
  minimal_data <- tibble::tibble(
    transcript_file = "test.vtt",
    comment_num = c("1", "2"),
    name = c("Student1", "Student1"),
    comment = c("Hello", "How are you?"),
    start = hms::as_hms(c("00:00:00", "00:00:05")),
    end = hms::as_hms(c("00:00:03", "00:00:08")),
    duration = hms::as_hms(c("00:00:03", "00:00:03")),
    wordcount = c(1, 3)
  )

  message("=== Testing summarize_transcript_metrics with rlang::syms debugging ===")

  # Test the rlang::syms part specifically
  result <- tryCatch(
    {
      message("Step 1: Testing rlang::syms with dplyr::group_by...")

      # Test rlang::syms directly
      group_vars <- c("transcript_file", "name")
      message("Group vars: ", paste(group_vars, collapse = ", "))

      # Test rlang::syms creation
      syms_result <- tryCatch(
        {
          message("Creating rlang::syms...")
          rlang::syms(group_vars)
        },
        error = function(e) {
          message("ERROR creating rlang::syms: ", e$message)
          return(NULL)
        }
      )

      if (!is.null(syms_result)) {
        message("rlang::syms created successfully: ", class(syms_result))
      }

      # Test dplyr::filter first
      filtered_result <- tryCatch(
        {
          message("Testing dplyr::filter...")
          minimal_data %>% dplyr::filter(!name %in% unlist(list()))
        },
        error = function(e) {
          message("ERROR in dplyr::filter: ", e$message)
          return(NULL)
        }
      )

      if (!is.null(filtered_result)) {
        message("dplyr::filter completed successfully")
      }

      # Test dplyr::group_by with rlang::syms
      grouped_result <- tryCatch(
        {
          message("Testing dplyr::group_by with rlang::syms...")
          minimal_data %>%
            dplyr::filter(!name %in% unlist(list())) %>%
            dplyr::group_by(!!!rlang::syms(group_vars))
        },
        error = function(e) {
          message("ERROR in dplyr::group_by with rlang::syms: ", e$message)
          return(NULL)
        }
      )

      if (!is.null(grouped_result)) {
        message("dplyr::group_by with rlang::syms completed successfully")
      }

      # Now test the full function
      message("Step 2: Testing full summarize_transcript_metrics function...")
      result <- summarize_transcript_metrics(
        transcript_df = minimal_data,
        names_exclude = list()
      )

      message("Step 3: Full function completed successfully")
      return(result)
    },
    error = function(e) {
      message("ERROR in full test: ", e$message)
      message("Error call: ", deparse(e$call))
      print(traceback())
      return(NULL)
    }
  )

  # Check if we got a result
  expect_false(is.null(result), "summarize_transcript_metrics should not return NULL")
})
