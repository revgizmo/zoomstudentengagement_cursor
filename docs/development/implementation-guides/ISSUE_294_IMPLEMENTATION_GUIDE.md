# Issue #294: Equity Metrics Tests - Implementation Guide

## Mission
Implement comprehensive equity metrics testing with boundary cases, failure modes, and equity-specific validation to strengthen the package's educational equity focus.

## Prerequisites
- Current test coverage: 90.22% (target achieved)
- Existing equity functions: `plot_users()`, `plot_users_by_metric()`, `plot_users_masked_section_by_metric()`, `mask_user_names_by_metric()`
- Test infrastructure: testthat framework with 1650 passing tests

## Implementation Steps

### Step 1: Create Test Data Utilities

**File**: `tests/testthat/helper-equity-test-data.R`

```r
# Create realistic equity test scenarios
create_equity_test_data <- function() {
  # Single participant class
  single_student <- tibble::tibble(
    preferred_name = "Alice",
    section = "101.A",
    duration = 100,
    wordcount = 500,
    n = 5
  )
  
  # All equal participation
  equal_participation <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Charlie", "Diana"),
    section = rep("101.A", 4),
    duration = rep(100, 4),
    wordcount = rep(500, 4),
    n = rep(5, 4)
  )
  
  # Extreme differences
  extreme_differences <- tibble::tibble(
    preferred_name = c("HighParticipant", "Alice", "Bob", "Charlie"),
    section = rep("101.A", 4),
    duration = c(1000, 100, 90, 80),
    wordcount = c(5000, 500, 450, 400),
    n = c(50, 5, 4, 3)
  )
  
  # International names
  international_names <- tibble::tibble(
    preferred_name = c("José García", "Ming Li", "Fatima Al-Zahra", "Oleksandr Kovalenko"),
    section = rep("101.A", 4),
    duration = c(120, 110, 105, 95),
    wordcount = c(600, 550, 525, 475),
    n = c(6, 5, 5, 4)
  )
  
  # Large class
  large_class <- tibble::tibble(
    preferred_name = paste0("Student", 1:60),
    section = rep("101.A", 60),
    duration = sample(50:200, 60, replace = TRUE),
    wordcount = sample(250:1000, 60, replace = TRUE),
    n = sample(1:10, 60, replace = TRUE)
  )
  
  # Problematic data
  problematic_data <- tibble::tibble(
    preferred_name = c("Alice", "Bob", "Charlie", "Diana", "Eve"),
    section = rep("101.A", 5),
    duration = c(100, NA, 0, -10, 50),
    wordcount = c(500, 400, 0, 200, NA),
    n = c(5, 4, 0, 2, 1)
  )
  
  # Duplicate names
  duplicate_names <- tibble::tibble(
    preferred_name = c("Alice Smith", "Alice Smith", "Bob Jones", "Bob Jones"),
    section = rep("101.A", 4),
    duration = c(100, 95, 90, 85),
    wordcount = c(500, 475, 450, 425),
    n = c(5, 4, 3, 2)
  )
  
  list(
    single_student = single_student,
    equal_participation = equal_participation,
    extreme_differences = extreme_differences,
    international_names = international_names,
    large_class = large_class,
    problematic_data = problematic_data,
    duplicate_names = duplicate_names
  )
}
```

### Step 2: Phase 1 - Boundary and Edge Cases Tests

**File**: `tests/testthat/test-equity-boundary-cases.R`

```r
test_that("equity functions handle single participant classes", {
  test_data <- create_equity_test_data()
  
  # Test plot_users with single student
  p <- plot_users(test_data$single_student, metric = "duration")
  expect_s3_class(p, "ggplot")
  expect_true(length(p$layers) > 0)
  
  # Test rank masking with single student
  p_rank <- plot_users(test_data$single_student, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")
})

test_that("equity functions handle equal participation scenarios", {
  test_data <- create_equity_test_data()
  
  # Test with identical participation
  p <- plot_users(test_data$equal_participation, metric = "duration")
  expect_s3_class(p, "ggplot")
  
  # Test rank masking with ties
  p_rank <- plot_users(test_data$equal_participation, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")
})

test_that("equity functions handle extreme participation differences", {
  test_data <- create_equity_test_data()
  
  # Test with extreme differences
  p <- plot_users(test_data$extreme_differences, metric = "duration")
  expect_s3_class(p, "ggplot")
  
  # Verify outlier is visible
  plot_data <- ggplot2::layer_data(p)
  expect_true(max(plot_data$y, na.rm = TRUE) >= 1000)
})

test_that("equity functions handle international names correctly", {
  test_data <- create_equity_test_data()
  
  # Test with international names
  p <- plot_users(test_data$international_names, metric = "duration")
  expect_s3_class(p, "ggplot")
  
  # Test name masking preserves privacy
  p_masked <- plot_users(test_data$international_names, metric = "duration", mask_by = "name")
  expect_s3_class(p_masked, "ggplot")
})

test_that("equity functions handle large classes efficiently", {
  test_data <- create_equity_test_data()
  
  # Test performance with large class
  start_time <- Sys.time()
  p <- plot_users(test_data$large_class, metric = "duration")
  end_time <- Sys.time()
  
  expect_s3_class(p, "ggplot")
  expect_true(as.numeric(difftime(end_time, start_time, units = "secs")) < 5)
})
```

### Step 3: Phase 2 - Failure Mode Tests

**File**: `tests/testthat/test-equity-failure-modes.R`

```r
test_that("equity functions handle missing participation data gracefully", {
  test_data <- create_equity_test_data()
  
  # Test with NA values
  expect_warning({
    p <- plot_users(test_data$problematic_data, metric = "duration")
  }, "NA")
  
  expect_s3_class(p, "ggplot")
})

test_that("equity functions handle zero participation students", {
  test_data <- create_equity_test_data()
  
  # Test with zero values
  p <- plot_users(test_data$problematic_data, metric = "duration")
  expect_s3_class(p, "ggplot")
  
  # Verify zero values appear in plot
  plot_data <- ggplot2::layer_data(p)
  expect_true(min(plot_data$y, na.rm = TRUE) <= 0)
})

test_that("equity functions handle negative values with appropriate errors", {
  test_data <- create_equity_test_data()
  
  # Test with negative values
  expect_error({
    plot_users(test_data$problematic_data, metric = "duration")
  }, "negative")
})

test_that("equity functions handle duplicate student names", {
  test_data <- create_equity_test_data()
  
  # Test with duplicate names
  p <- plot_users(test_data$duplicate_names, metric = "duration")
  expect_s3_class(p, "ggplot")
  
  # Test rank masking distinguishes duplicates
  p_rank <- plot_users(test_data$duplicate_names, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")
})
```

### Step 4: Phase 3 - Equity-Specific Validation Tests

**File**: `tests/testthat/test-equity-validation.R`

```r
test_that("equity functions support participation distribution analysis", {
  test_data <- create_equity_test_data()
  
  # Test that plots show participation gaps
  p <- plot_users(test_data$extreme_differences, metric = "duration")
  expect_s3_class(p, "ggplot")
  
  # Verify rank masking preserves relative positions
  p_rank <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "rank")
  expect_s3_class(p_rank, "ggplot")
})

test_that("equity functions support section comparison analysis", {
  # Create multi-section data
  multi_section <- rbind(
    create_equity_test_data()$extreme_differences %>% mutate(section = "101.A"),
    create_equity_test_data()$equal_participation %>% mutate(section = "101.B")
  )
  
  # Test faceting by section
  p <- plot_users(multi_section, metric = "duration", facet_by = "section")
  expect_s3_class(p, "ggplot")
  expect_true("FacetWrap" %in% class(p$facet))
})

test_that("equity functions maintain analytical value with privacy masking", {
  test_data <- create_equity_test_data()
  
  # Test that masked plots preserve analytical information
  p_unmasked <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "name")
  p_ranked <- plot_users(test_data$extreme_differences, metric = "duration", mask_by = "rank")
  
  expect_s3_class(p_unmasked, "ggplot")
  expect_s3_class(p_ranked, "ggplot")
  
  # Verify both plots show the same relative patterns
  unmasked_data <- ggplot2::layer_data(p_unmasked)
  ranked_data <- ggplot2::layer_data(p_ranked)
  
  expect_equal(length(unmasked_data$y), length(ranked_data$y))
})
```

### Step 5: Integration and Validation

**Commands to run**:

```bash
# 1. Create feature branch
git checkout -b feature/issue-294-equity-tests

# 2. Add test files
git add tests/testthat/helper-equity-test-data.R
git add tests/testthat/test-equity-boundary-cases.R
git add tests/testthat/test-equity-failure-modes.R
git add tests/testthat/test-equity-validation.R

# 3. Run tests to ensure they pass
Rscript -e "devtools::test()"

# 4. Check coverage
Rscript -e "covr::package_coverage()"

# 5. Run full validation
Rscript -e "source('scripts/pre-pr-validation.R')"

# 6. Commit and push
git commit -m "test(equity): add comprehensive equity metrics tests with boundary cases and failure modes (Fixes #294)"
git push -u origin feature/issue-294-equity-tests

# 7. Create PR
gh pr create --title "test(equity): comprehensive equity metrics tests (Fixes #294)" --body "Adds comprehensive equity-focused tests:

- Boundary cases: single participants, equal participation, extreme differences
- Failure modes: missing data, zero values, negative values, duplicate names
- Equity validation: participation distribution, section comparison, privacy balance
- International names and large class performance testing

Maintains 90.22% coverage while strengthening educational equity focus." --base main --head feature/issue-294-equity-tests --fill

# 8. Merge PR
gh pr merge --merge --delete-branch --admin
```

## Success Criteria

### **Coverage Requirements**
- ✅ Maintain ≥90% test coverage
- ✅ Add tests for all identified edge cases
- ✅ Ensure all equity functions have comprehensive test coverage

### **Functionality Requirements**
- ✅ All tests pass without warnings
- ✅ Edge cases handled gracefully
- ✅ Performance acceptable with large datasets
- ✅ Privacy masking works correctly

### **Quality Requirements**
- ✅ Tests are well-documented
- ✅ Test data is realistic and diverse
- ✅ Error messages are user-friendly
- ✅ Tests support educational equity goals

## Validation Commands

```r
# Run all tests
devtools::test()

# Check coverage
covr::package_coverage()

# Run specific equity tests
devtools::test_file("tests/testthat/test-equity-boundary-cases.R")
devtools::test_file("tests/testthat/test-equity-failure-modes.R")
devtools::test_file("tests/testthat/test-equity-validation.R")

# Full package check
devtools::check()
```

## Expected Outcomes

1. **Enhanced Test Coverage**: Comprehensive testing of equity-related functions
2. **Improved Robustness**: Better handling of edge cases and failure modes
3. **Educational Focus**: Tests that validate equity analysis capabilities
4. **Privacy Validation**: Ensured privacy masking works correctly
5. **Performance Verification**: Confirmed acceptable performance with large datasets

## Follow-up Actions

1. **Documentation Update**: Add equity-focused examples to function documentation
2. **Vignette Creation**: Create vignette demonstrating equity analysis workflows
3. **Real-world Testing**: Test with actual classroom data when available
4. **Performance Monitoring**: Monitor performance with very large classes
