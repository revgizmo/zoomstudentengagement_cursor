# Load required packages for testing
library(zoomstudentengagement)
library(testthat)
library(tibble)
library(lubridate)
library(ggplot2)

# Set random seed for reproducibility
set.seed(42)

# Create a temporary directory for test files
test_dir <- tempfile("zoomstudentengagement_test_")
dir.create(test_dir)

# Clean up after tests using modern testthat fixtures
withr::defer(unlink(test_dir, recursive = TRUE), teardown_env())
