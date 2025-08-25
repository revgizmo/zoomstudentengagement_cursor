# Issue #360: Investigate and Fix 16 Failing Tests - Implementation Guide

**Issue**: [#360](https://github.com/revgizmo/zoomstudentengagement/issues/360)  
**Priority**: High  
**Type**: Bug  
**Area**: Testing  

## 🎯 **Implementation Overview**

This guide provides step-by-step instructions to investigate and resolve 16 failing tests that were discovered during analysis verification. The failures fall into three categories: missing functions, pkgload environment issues, and other test problems.

## 📋 **Pre-Implementation Checklist**

### **Environment Setup**
- [ ] Ensure R environment is available
- [ ] Verify all package dependencies are installed
- [ ] Check testthat framework (>= 3.0.0)
- [ ] Confirm pkgload package is available
- [ ] Validate package can be loaded and built

### **Current State Validation**
- [ ] Run current test suite to confirm 16 failures
- [ ] Document exact error messages and locations
- [ ] Check test coverage baseline (currently 90.69%)
- [ ] Verify package builds successfully

## 🔍 **Phase 1: Investigation and Analysis**

### **Step 1.1: Function Audit**

#### **1.1.1: Identify Missing Functions**
```r
# Check which functions are missing
missing_functions <- c(
  "generate_name_matching_guidance",
  "extract_transcript_names", 
  "extract_roster_names",
  "extract_mapped_names",
  "create_name_lookup",
  "find_roster_match",
  "apply_name_matching",
  "handle_unmatched_names"
)

# Check if functions exist in package
for (func in missing_functions) {
  exists_func <- exists(func, envir = asNamespace("zoomstudentengagement"))
  cat(sprintf("%s: %s\n", func, ifelse(exists_func, "EXISTS", "MISSING")))
}
```

#### **1.1.2: Check Function Exports**
```r
# Check NAMESPACE for function exports
namespace_content <- readLines("NAMESPACE")
exported_functions <- grep("^export\\(", namespace_content, value = TRUE)
exported_names <- gsub("^export\\(([^)]+)\\)", "\\1", exported_functions)

# Check if missing functions are exported
for (func in missing_functions) {
  is_exported <- func %in% exported_names
  cat(sprintf("%s: %s\n", func, ifelse(is_exported, "EXPORTED", "NOT EXPORTED")))
}
```

#### **1.1.3: Analyze Test Files**
```bash
# Review test files that reference missing functions
grep -n "generate_name_matching_guidance" tests/testthat/test-prompt_name_matching.R
grep -n "extract_transcript_names" tests/testthat/test-prompt_name_matching.R
grep -n "extract_roster_names" tests/testthat/test-prompt_name_matching.R
grep -n "extract_mapped_names" tests/testthat/test-prompt_name_matching.R
grep -n "create_name_lookup" tests/testthat/test-safe_name_matching_workflow_coverage.R
grep -n "find_roster_match" tests/testthat/test-safe_name_matching_workflow_coverage.R
grep -n "apply_name_matching" tests/testthat/test-safe_name_matching_workflow_coverage.R
grep -n "handle_unmatched_names" tests/testthat/test-safe_name_matching_workflow_coverage.R
```

### **Step 1.2: pkgload Environment Investigation**

#### **1.2.1: Check Test Environment Setup**
```r
# Check if package is loaded in test environment
library(testthat)
library(pkgload)

# Check package loading status
is_package_loaded <- "zoomstudentengagement" %in% loadedNamespaces()
cat(sprintf("Package loaded: %s\n", is_package_loaded))

# Check dev_package function availability
dev_package_available <- exists("dev_package", envir = asNamespace("testthat"))
cat(sprintf("dev_package available: %s\n", dev_package_available))
```

#### **1.2.2: Analyze pkgload Error Patterns**
```bash
# Check specific test files with pkgload issues
grep -n "with_mocked_bindings" tests/testthat/test-analyze_multi_session_attendance.R
grep -n "with_mocked_bindings" tests/testthat/test-analyze_transcripts.R
grep -n "with_mocked_bindings" tests/testthat/test-prompt_name_matching.R
```

#### **1.2.3: Test Environment Validation**
```r
# Create minimal test to reproduce pkgload issue
test_that("pkgload environment test", {
  # This should help identify the root cause
  expect_true(TRUE)
})
```

### **Step 1.3: Test Data Analysis**

#### **1.3.1: Review Test Fixtures**
```bash
# Check test data files
ls -la tests/testthat/test_data/
ls -la inst/extdata/

# Check for data inconsistencies
find tests/testthat -name "*.csv" -exec head -5 {} \;
find inst/extdata -name "*.csv" -exec head -5 {} \;
```

#### **1.3.2: Validate Test Assumptions**
```r
# Check if test data matches expected format
test_data_files <- list.files("tests/testthat/test_data", full.names = TRUE)
for (file in test_data_files) {
  cat(sprintf("Checking %s\n", file))
  data <- read.csv(file)
  print(str(data))
}
```

## 🛠️ **Phase 2: Resolution Implementation**

### **Step 2.1: Missing Functions Resolution**

#### **2.1.1: Decision Matrix for Missing Functions**

For each missing function, determine:

1. **Should it be implemented?**
   - Check if function is referenced in documentation
   - Verify if it's part of the public API
   - Assess implementation complexity

2. **Should tests be removed?**
   - If function was never implemented
   - If function was removed during refactoring
   - If tests were written for future functionality

#### **2.1.2: Function Implementation (if needed)**
```r
# Example implementation template
generate_name_matching_guidance <- function(names, privacy_level = "mask", verbose = TRUE) {
  # Implementation here
  # Follow project coding standards
  # Include proper error handling
  # Add roxygen2 documentation
}

# Add to NAMESPACE
# export(generate_name_matching_guidance)
```

#### **2.1.3: Test Removal (if appropriate)**
```bash
# Remove tests for non-existent functions
# Example: Remove specific test blocks
sed -i '/test_that.*generate_name_matching_guidance/,/^}/d' tests/testthat/test-prompt_name_matching.R
```

### **Step 2.2: pkgload Environment Fixes**

#### **2.2.1: Fix with_mocked_bindings Usage**
```r
# Replace problematic with_mocked_bindings calls
# Instead of:
# with_mocked_bindings(...)

# Use:
# with_mocked_bindings(..., .package = "zoomstudentengagement")
```

#### **2.2.2: Update Test Environment Setup**
```r
# Add proper package loading in test files
# At the top of test files:
library(zoomstudentengagement)
```

#### **2.2.3: Fix Package Context Issues**
```r
# Ensure package is loaded before mocking
# Example fix:
test_that("test with proper context", {
  # Load package explicitly
  library(zoomstudentengagement)
  
  # Use mocking with proper context
  with_mocked_bindings(
    some_function = function() "mocked",
    .package = "zoomstudentengagement"
  ) {
    result <- some_function()
    expect_equal(result, "mocked")
  }
})
```

### **Step 2.3: Test Cleanup**

#### **2.3.1: Fix Broken Test Expectations**
```r
# Update test expectations to match actual behavior
# Example: Fix column name expectations
test_that("test with correct expectations", {
  result <- some_function(test_data)
  expect_s3_class(result, "tbl_df")
  expect_true("expected_column" %in% names(result))
})
```

#### **2.3.2: Update Test Data and Fixtures**
```r
# Create proper test fixtures
# Example: Create minimal test data
test_data <- tibble::tibble(
  name = c("Alice", "Bob"),
  value = c(1, 2)
)
```

#### **2.3.3: Improve Error Handling**
```r
# Add proper error handling in tests
test_that("test with error handling", {
  expect_error(
    some_function(invalid_input),
    "Expected error message"
  )
})
```

## ✅ **Phase 3: Validation and Documentation**

### **Step 3.1: Comprehensive Testing**

#### **3.1.1: Run Full Test Suite**
```bash
# Run all tests
Rscript -e "devtools::test()"

# Check specific test files
Rscript -e "testthat::test_file('tests/testthat/test-prompt_name_matching.R')"
Rscript -e "testthat::test_file('tests/testthat/test-safe_name_matching_workflow_coverage.R')"
```

#### **3.1.2: Verify No New Failures**
```r
# Run tests and capture results
test_results <- devtools::test()
failed_tests <- test_results$failed
cat(sprintf("Failed tests: %d\n", length(failed_tests)))
```

#### **3.1.3: Check Test Coverage Impact**
```r
# Check test coverage
library(covr)
coverage <- package_coverage()
cat(sprintf("Test coverage: %.2f%%\n", attr(coverage, "coverage") * 100))
```

### **Step 3.2: Documentation**

#### **3.2.1: Document Test Patterns**
```r
# Create test documentation
# Add comments explaining test patterns
# Document best practices for this package
```

#### **3.2.2: Update Test Documentation**
```markdown
# Test Patterns and Best Practices

## Function Testing
- Always test exported functions
- Include edge cases and error conditions
- Use proper test data fixtures

## Environment Setup
- Load package explicitly in tests
- Use proper mocking context
- Handle package loading issues

## Error Handling
- Test expected errors
- Validate error messages
- Include proper error conditions
```

## 🎯 **Success Validation**

### **Primary Success Criteria**
- [ ] All 16 failing tests resolved
- [ ] Test suite passes completely (100% pass rate)
- [ ] No regression in existing functionality
- [ ] Test coverage maintained or improved

### **Validation Commands**
```bash
# Final validation
Rscript scripts/pre-pr-validation.R

# Check package build
Rscript -e "devtools::check()"

# Verify test coverage
Rscript -e "library(covr); cat('Coverage:', round(package_coverage() * 100, 2), '%\n')"
```

## 🚨 **Troubleshooting**

### **Common Issues and Solutions**

#### **Issue: pkgload still failing**
**Solution**: Ensure package is loaded before running tests
```r
library(zoomstudentengagement)
```

#### **Issue: Function not found after implementation**
**Solution**: Check NAMESPACE exports and rebuild
```bash
Rscript -e "devtools::document()"
Rscript -e "devtools::load_all()"
```

#### **Issue: Test coverage decreased**
**Solution**: Review removed tests and add coverage for critical paths
```r
# Add tests for uncovered functions
```

#### **Issue: New warnings introduced**
**Solution**: Review test output and fix warning conditions
```r
# Suppress expected warnings or fix underlying issues
```

## 📝 **Implementation Notes**

### **Environment Considerations**
- Some fixes may require interactive R environment
- Package loading issues may be environment-specific
- Test data may need to be regenerated

### **Quality Standards**
- Follow project coding standards
- Maintain privacy-first approach
- Ensure CRAN compliance
- Document all changes thoroughly

### **Risk Mitigation**
- Test changes incrementally
- Maintain backward compatibility
- Document all decisions and rationale
- Validate in clean environment

---

**Last Updated**: 2025-01-27  
**Status**: Ready for Implementation  
**Next Action**: Begin Phase 1 investigation
