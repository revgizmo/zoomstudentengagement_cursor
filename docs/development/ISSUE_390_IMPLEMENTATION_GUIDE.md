# Issue #390 Implementation Guide: Fix Segmentation Fault in detect_duplicate_transcripts

**Date**: August 25, 2025  
**Issue**: #390 - CRITICAL: Fix segmentation fault in detect_duplicate_transcripts function  
**Priority**: CRITICAL - CRAN Submission Blocker  

## 🎯 **Mission Overview**

Fix the critical segmentation fault occurring in the `detect_duplicate_transcripts` function that is preventing CRAN submission. The segfault occurs during test execution with invalid VTT file handling.

## 📋 **Step-by-Step Implementation Plan**

### **Step 1: Environment Setup and Investigation**

#### 1.1 Create Feature Branch
```bash
git checkout -b feature/issue-390-segfault-fix
git push -u origin feature/issue-390-segfault-fix
```

#### 1.2 Reproduce the Issue
```r
# Run the specific test that triggers the segfault
Rscript -e "devtools::test_file('tests/testthat/test-detect_duplicate_transcripts.R')"
```

#### 1.3 Analyze the Function
```r
# Examine the detect_duplicate_transcripts function
readLines("R/detect_duplicate_transcripts.R")
```

### **Step 2: Root Cause Analysis**

#### 2.1 Identify Problematic Operations
Look for these patterns in `detect_duplicate_transcripts.R`:
- `dplyr::lag()` operations (known segfault source)
- `dplyr::group_by()` with complex operations
- Memory-intensive operations on large datasets
- Error handling for invalid files

#### 2.2 Memory Analysis
```r
# Profile memory usage during function execution
library(pryr)
mem_used()
# Run function
result <- detect_duplicate_transcripts(...)
mem_used()
```

#### 2.3 Create Minimal Test Case
```r
# Create a minimal reproducible example
test_data <- create_minimal_test_data()
result <- detect_duplicate_transcripts(test_data)
```

### **Step 3: Implementation of Fixes**

#### 3.1 Replace Problematic dplyr Operations
**Pattern to Replace:**
```r
# BEFORE (problematic):
df %>%
  dplyr::group_by(transcript_file) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start, default = lubridate::period(0))
  )
```

**Replace with Base R:**
```r
# AFTER (safe):
df <- df[order(df$transcript_file, df$start), ]
df$prev_end <- c(hms::hms(0), df$end[-length(df$end)])
```

#### 3.2 Improve Error Handling
```r
# Add robust error handling for invalid files
detect_duplicate_transcripts <- function(transcript_files, ...) {
  # Validate input
  if (length(transcript_files) == 0) {
    return(data.frame())
  }
  
  # Safe file processing
  results <- lapply(transcript_files, function(file) {
    tryCatch({
      # Process file safely
      process_single_file(file)
    }, error = function(e) {
      warning("Could not process file: ", file, " - ", e$message)
      return(NULL)
    })
  })
  
  # Combine results safely
  results <- results[!sapply(results, is.null)]
  if (length(results) == 0) {
    return(data.frame())
  }
  
  do.call(rbind, results)
}
```

#### 3.3 Memory Management Improvements
```r
# Add explicit memory cleanup
detect_duplicate_transcripts <- function(transcript_files, ...) {
  # Pre-allocate memory where possible
  max_files <- length(transcript_files)
  results <- vector("list", max_files)
  
  # Process files with cleanup
  for (i in seq_along(transcript_files)) {
    results[[i]] <- process_single_file(transcript_files[i])
    
    # Explicit cleanup
    if (i %% 100 == 0) {
      gc()
    }
  }
  
  # Final cleanup
  gc()
  
  # Combine results
  do.call(rbind, results)
}
```

### **Step 4: Testing and Validation**

#### 4.1 Create Comprehensive Tests
```r
# tests/testthat/test-detect_duplicate_transcripts_fixed.R
test_that("detect_duplicate_transcripts handles invalid files gracefully", {
  # Test with invalid VTT file
  invalid_file <- "tests/testthat/test_data/invalid.vtt"
  result <- detect_duplicate_transcripts(invalid_file)
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
})

test_that("detect_duplicate_transcripts handles empty input", {
  result <- detect_duplicate_transcripts(character(0))
  expect_true(is.data.frame(result))
  expect_equal(nrow(result), 0)
})

test_that("detect_duplicate_transcripts processes valid files", {
  valid_files <- c("tests/testthat/test_data/valid1.vtt", 
                   "tests/testthat/test_data/valid2.vtt")
  result <- detect_duplicate_transcripts(valid_files)
  expect_true(is.data.frame(result))
  expect_gt(nrow(result), 0)
})
```

#### 4.2 Performance Testing
```r
# Test with large datasets
test_that("detect_duplicate_transcripts handles large datasets", {
  large_files <- create_large_test_files(1000)  # 1000 files
  start_time <- Sys.time()
  result <- detect_duplicate_transcripts(large_files)
  end_time <- Sys.time()
  
  # Should complete within reasonable time
  expect_lt(as.numeric(end_time - start_time), 60)  # Less than 60 seconds
  expect_true(is.data.frame(result))
})
```

#### 4.3 Memory Testing
```r
# Test memory usage
test_that("detect_duplicate_transcripts has reasonable memory usage", {
  initial_mem <- mem_used()
  result <- detect_duplicate_transcripts(test_files)
  final_mem <- mem_used()
  
  # Memory increase should be reasonable
  mem_increase <- final_mem - initial_mem
  expect_lt(mem_increase, 100 * 1024^2)  # Less than 100MB increase
})
```

### **Step 5: Integration and Validation**

#### 5.1 Run Full Test Suite
```bash
# Run all tests to ensure no regressions
Rscript -e "devtools::test()"
```

#### 5.2 CRAN Compliance Check
```bash
# Check CRAN compliance
Rscript -e "devtools::check()"
```

#### 5.3 Performance Benchmarking
```r
# Benchmark performance improvements
library(microbenchmark)
microbenchmark(
  old = detect_duplicate_transcripts_old(test_files),
  new = detect_duplicate_transcripts(test_files),
  times = 10
)
```

## 🎯 **Success Criteria**

### **Technical Requirements**
- [ ] No segmentation faults in any tests
- [ ] All tests pass consistently
- [ ] Function handles invalid data gracefully
- [ ] Memory usage optimized and stable
- [ ] Performance maintained or improved

### **Quality Requirements**
- [ ] Comprehensive error handling implemented
- [ ] Memory management optimized
- [ ] Documentation updated
- [ ] CRAN compliance maintained
- [ ] No regressions in functionality

### **Validation Steps**
1. **Run specific test**: `Rscript -e "devtools::test_file('tests/testthat/test-detect_duplicate_transcripts.R')"`
2. **Run full test suite**: `Rscript -e "devtools::test()"`
3. **Check CRAN compliance**: `Rscript -e "devtools::check()"`
4. **Performance test**: Run with large datasets
5. **Memory test**: Monitor memory usage

## 🔧 **Troubleshooting Guide**

### **Common Issues**

#### Issue: Segfault Still Occurs
**Solution**: 
- Check for remaining dplyr operations
- Add more explicit error handling
- Implement chunked processing for large files

#### Issue: Performance Degradation
**Solution**:
- Optimize base R operations
- Implement caching where appropriate
- Add progress indicators for long operations

#### Issue: Memory Leaks
**Solution**:
- Add explicit `gc()` calls
- Pre-allocate memory where possible
- Monitor memory usage during execution

### **Debugging Commands**
```r
# Enable detailed error reporting
options(error = recover)

# Profile memory usage
library(pryr)
mem_used()

# Debug specific function
debug(detect_duplicate_transcripts)
```

## 📝 **Documentation Updates**

### **Function Documentation**
Update the function documentation to reflect:
- Improved error handling
- Memory usage considerations
- Performance characteristics
- Troubleshooting information

### **Troubleshooting Guide**
Add troubleshooting section covering:
- Common error messages
- Performance optimization tips
- Memory usage guidelines
- Debugging procedures

## 🚀 **Deployment Checklist**

- [ ] All tests pass
- [ ] CRAN compliance verified
- [ ] Performance validated
- [ ] Memory usage optimized
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] Ready for merge

## 📞 **Support and Resources**

- **Issue Link**: https://github.com/revgizmo/zoomstudentengagement/issues/390
- **Related Issues**: Previous segfault fixes in Issues #113, #127
- **Documentation**: See `docs/development/SEGFAULT_ANALYSIS.md`
- **Performance Guide**: See `docs/development/PERFORMANCE_OPTIMIZATION.md`
