# Issue #227 Implementation Guide: Add Missing Tests for analyze_transcripts.R

## 🎯 **Mission**

Add comprehensive test coverage for `analyze_transcripts.R` to achieve >80% coverage and meet CRAN submission requirements.

## 📋 **Current Problem**

- `R/analyze_transcripts.R` has **0% test coverage**
- Overall package coverage is 88.00% (target: 90%)
- This file is blocking the 90% coverage target for CRAN submission
- No test file exists: `tests/testthat/test-analyze_transcripts.R`

## 🔧 **Step-by-Step Implementation**

### **Step 1: Analyze Current Function**

#### **1.1 Examine Function Structure**
```r
# Load the package and examine the function
devtools::load_all()
lsf.str("package:zoomstudentengagement", pattern = "analyze_transcripts")
```

#### **1.2 Understand Function Parameters**
The `analyze_transcripts()` function has these parameters:
- `transcripts_folder`: Path to folder containing `.transcript.vtt` files
- `names_to_exclude`: Character vector of names to exclude (default: c("dead_air"))
- `write`: Boolean to write output (default: FALSE)
- `output_path`: Optional output CSV path (default: NULL)

#### **1.3 Identify Code Paths**
Key code paths to test:
1. Valid folder with transcript files
2. Invalid folder path
3. Empty folder
4. Folder with no `.transcript.vtt` files
5. Write functionality (TRUE/FALSE)
6. Custom output path
7. Integration with `summarize_transcript_files()`
8. Integration with `write_metrics()`

### **Step 2: Create Test File Structure**

#### **2.1 Create Test File**
```bash
# Create the test file
touch tests/testthat/test-analyze_transcripts.R
```

#### **2.2 Set Up Test Framework**
```r
# Basic test structure
library(testthat)
library(zoomstudentengagement)

# Test context
test_that("analyze_transcripts works correctly", {
  # Tests will go here
})
```

### **Step 3: Create Test Fixtures**

#### **3.1 Create Sample Transcript Data**
```r
# Create sample transcript files for testing
create_sample_transcript_files <- function() {
  temp_dir <- tempfile("test_transcripts")
  dir.create(temp_dir, recursive = TRUE)
  
  # Create sample .transcript.vtt files
  sample_content <- "WEBVTT\n\n00:00:00.000 --> 00:00:05.000\nStudent1: Hello\n\n00:00:05.000 --> 00:00:10.000\nStudent2: Hi there"
  
  # Create multiple test files
  file1 <- file.path(temp_dir, "test1.transcript.vtt")
  file2 <- file.path(temp_dir, "test2.transcript.vtt")
  
  writeLines(sample_content, file1)
  writeLines(sample_content, file2)
  
  list(
    temp_dir = temp_dir,
    files = c(file1, file2)
  )
}
```

#### **3.2 Create Test Helper Functions**
```r
# Helper function to clean up test files
cleanup_test_files <- function(test_data) {
  if (dir.exists(test_data$temp_dir)) {
    unlink(test_data$temp_dir, recursive = TRUE)
  }
}
```

### **Step 4: Implement Basic Functionality Tests**

#### **4.1 Test Valid Folder Processing**
```r
test_that("analyze_transcripts processes valid folder correctly", {
  test_data <- create_sample_transcript_files()
  on.exit(cleanup_test_files(test_data))
  
  # Test basic functionality
  result <- analyze_transcripts(test_data$temp_dir)
  
  # Verify return value
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
  expect_true("name" %in% names(result))
})
```

#### **4.2 Test Parameter Handling**
```r
test_that("analyze_transcripts handles parameters correctly", {
  test_data <- create_sample_transcript_files()
  on.exit(cleanup_test_files(test_data))
  
  # Test with custom names_to_exclude
  result <- analyze_transcripts(
    transcripts_folder = test_data$temp_dir,
    names_to_exclude = c("dead_air", "unknown")
  )
  
  expect_s3_class(result, "tbl_df")
})
```

### **Step 5: Implement Error Handling Tests**

#### **5.1 Test Invalid Folder Path**
```r
test_that("analyze_transcripts handles invalid folder path", {
  expect_error(
    analyze_transcripts("nonexistent_folder"),
    "Folder not found: nonexistent_folder"
  )
})
```

#### **5.2 Test Empty Folder**
```r
test_that("analyze_transcripts handles empty folder", {
  temp_dir <- tempfile("empty_transcripts")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  expect_error(
    analyze_transcripts(temp_dir),
    "No .transcript.vtt files found in the provided folder"
  )
})
```

#### **5.3 Test Folder with No Transcript Files**
```r
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
```

### **Step 6: Implement Edge Cases Tests**

#### **6.1 Test Single Transcript File**
```r
test_that("analyze_transcripts works with single transcript file", {
  temp_dir <- tempfile("single_transcript")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Create single transcript file
  sample_content <- "WEBVTT\n\n00:00:00.000 --> 00:00:05.000\nStudent1: Hello"
  writeLines(sample_content, file.path(temp_dir, "single.transcript.vtt"))
  
  result <- analyze_transcripts(temp_dir)
  expect_s3_class(result, "tbl_df")
  expect_true(nrow(result) > 0)
})
```

#### **6.2 Test Write Functionality**
```r
test_that("analyze_transcripts write functionality works", {
  test_data <- create_sample_transcript_files()
  on.exit(cleanup_test_files(test_data))
  
  output_file <- tempfile("test_output.csv")
  on.exit(unlink(output_file), add = TRUE)
  
  # Test with write = TRUE
  result <- analyze_transcripts(
    transcripts_folder = test_data$temp_dir,
    write = TRUE,
    output_path = output_file
  )
  
  expect_s3_class(result, "tbl_df")
  expect_true(file.exists(output_file))
})
```

### **Step 7: Implement Integration Tests**

#### **7.1 Test Integration with summarize_transcript_files**
```r
test_that("analyze_transcripts integrates with summarize_transcript_files", {
  test_data <- create_sample_transcript_files()
  on.exit(cleanup_test_files(test_data))
  
  # Mock summarize_transcript_files to verify it's called correctly
  with_mocked_bindings(
    summarize_transcript_files = function(...) {
      # Verify parameters are passed correctly
      args <- list(...)
      expect_true("transcript_file_names" %in% names(args))
      expect_true("names_to_exclude" %in% names(args))
      
      # Return mock result
      tibble::tibble(
        name = c("Student1", "Student2"),
        n = c(1, 1),
        duration = c(5, 5)
      )
    },
    {
      result <- analyze_transcripts(test_data$temp_dir)
      expect_s3_class(result, "tbl_df")
    }
  )
})
```

#### **7.2 Test Integration with write_metrics**
```r
test_that("analyze_transcripts integrates with write_metrics", {
  test_data <- create_sample_transcript_files()
  on.exit(cleanup_test_files(test_data))
  
  output_file <- tempfile("test_output.csv")
  on.exit(unlink(output_file), add = TRUE)
  
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
        transcripts_folder = test_data$temp_dir,
        write = TRUE,
        output_path = output_file
      )
      expect_s3_class(result, "tbl_df")
    }
  )
})
```

### **Step 8: Coverage Optimization**

#### **8.1 Check Current Coverage**
```r
# Check coverage for this specific file
coverage <- covr::package_coverage()
file_coverage <- covr::file_coverage(coverage, "R/analyze_transcripts.R")
print(file_coverage)
```

#### **8.2 Add Missing Coverage**
```r
# Add tests for any uncovered code paths
test_that("analyze_transcripts handles NULL output_path", {
  test_data <- create_sample_transcript_files()
  on.exit(cleanup_test_files(test_data))
  
  # Test with write = TRUE and NULL output_path
  result <- analyze_transcripts(
    transcripts_folder = test_data$temp_dir,
    write = TRUE,
    output_path = NULL
  )
  
  expect_s3_class(result, "tbl_df")
  expect_true(file.exists("engagement_metrics.csv"))
  unlink("engagement_metrics.csv") # Clean up
})
```

### **Step 9: Validation**

#### **9.1 Run Tests**
```r
# Run the specific test file
devtools::test_file("tests/testthat/test-analyze_transcripts.R")

# Run all tests to ensure no regressions
devtools::test()
```

#### **9.2 Check Coverage**
```r
# Check final coverage
coverage <- covr::package_coverage()
file_coverage <- covr::file_coverage(coverage, "R/analyze_transcripts.R")
print(file_coverage)

# Ensure coverage is >80%
expect_true(file_coverage$coverage > 80)
```

#### **9.3 Validate Package**
```r
# Run full package check
devtools::check()
```

## ✅ **Success Criteria**

### **Primary Goals**
- [ ] Test coverage for `analyze_transcripts.R` > 80%
- [ ] All tests pass (`devtools::test()`)
- [ ] Tests follow project standards (testthat framework)
- [ ] No test warnings or errors

### **Validation Checklist**
- [ ] `devtools::test_file("tests/testthat/test-analyze_transcripts.R")` passes
- [ ] `covr::package_coverage()` shows >80% for analyze_transcripts.R
- [ ] `devtools::test()` passes all tests
- [ ] `devtools::check()` passes with no new errors/warnings
- [ ] Integration with existing test infrastructure

## 🚨 **Error Handling**

### **Common Issues**

#### **Issue: Tests Fail Due to Missing Dependencies**
**Solution**: Ensure all required packages are available in test environment
```r
# Add to test file if needed
skip_if_not_installed("tibble")
skip_if_not_installed("readr")
```

#### **Issue: Coverage Not Improving**
**Solution**: Check if all code paths are being tested
```r
# Use covr::code_coverage() to see detailed coverage
covr::code_coverage("R/analyze_transcripts.R")
```

#### **Issue: Integration Tests Fail**
**Solution**: Ensure mocked functions match expected signatures
```r
# Check function signatures
args(summarize_transcript_files)
args(write_metrics)
```

## 📝 **Commands Summary**

### **Essential Commands**
```bash
# 1. Create test file
touch tests/testthat/test-analyze_transcripts.R

# 2. Run tests
Rscript -e "devtools::test_file('tests/testthat/test-analyze_transcripts.R')"

# 3. Check coverage
Rscript -e "covr::package_coverage() %>% covr::file_coverage('R/analyze_transcripts.R')"

# 4. Validate package
Rscript -e "devtools::test(); devtools::check()"
```

### **Validation Commands**
```r
# Full validation suite
devtools::test_file("tests/testthat/test-analyze_transcripts.R")
devtools::test()
covr::package_coverage()
devtools::check()
```

## 🎯 **Expected Outcome**

After implementation:
- Test coverage for `analyze_transcripts.R` should be >80%
- All tests should pass
- Package should maintain 88%+ overall coverage
- Ready for CRAN submission coverage requirements

---

**Next Step**: Begin with Step 1 - Analyze Current Function
