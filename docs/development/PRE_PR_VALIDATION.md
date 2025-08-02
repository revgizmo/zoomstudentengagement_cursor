# Pre-PR Validation Checklist
## zoomstudentengagement R Package

**Purpose**: Comprehensive validation checklist to run before creating pull requests.

**Audience**: Developers preparing to submit pull requests.

**Last Updated**: August 2025

---

## 📋 Pre-PR Validation Checklist

Before creating a pull request, run these checks:

```r
# Phase 1: Code Quality (5-10 minutes)
styler::style_pkg()                  # Ensure consistent formatting
lintr::lint_package()               # Check code quality

# Phase 2: Documentation (2-5 minutes)
devtools::document()                 # Update roxygen2 documentation
devtools::build_readme()             # Rebuild README.md
devtools::spell_check()              # Check for typos

# Phase 3: Testing (3-5 minutes)
devtools::test()                     # Run all tests
covr::package_coverage()             # Check test coverage

# Phase 4: Final Validation (5-10 minutes)
devtools::check()                    # Full package check
devtools::build()                    # Create distributable package
```

---

## ✅ Validation Requirements

### Code Quality

#### **Style and Formatting**
- [ ] Code follows tidyverse style guide
- [ ] `styler::style_pkg()` runs without issues
- [ ] No lintr warnings or errors
- [ ] Consistent naming conventions
- [ ] Proper indentation and spacing

#### **Code Standards**
- [ ] Proper error handling implemented
- [ ] Input validation for all parameters
- [ ] No hardcoded secrets or sensitive data
- [ ] Memory efficient for large operations
- [ ] Performance considerations addressed

### Documentation

#### **Function Documentation**
- [ ] All exported functions have complete roxygen2 documentation
- [ ] All examples are runnable and tested
- [ ] `@param`, `@return`, `@examples` sections included
- [ ] No missing documentation warnings
- [ ] Documentation is clear and accurate

#### **Package Documentation**
- [ ] README.md is current and comprehensive
- [ ] No spelling errors (`devtools::spell_check()`)
- [ ] Vignettes are up to date
- [ ] All links work correctly
- [ ] Installation instructions are clear

### Testing

#### **Test Coverage**
- [ ] All tests pass (`devtools::test()`)
- [ ] Coverage >90% for new code (`covr::package_coverage()`)
- [ ] Edge cases covered
- [ ] Error conditions tested
- [ ] Performance considerations addressed

#### **Test Quality**
- [ ] Tests are meaningful and comprehensive
- [ ] Test data is appropriate and minimal
- [ ] Tests follow project conventions
- [ ] No test warnings or errors
- [ ] Tests are fast and reliable

### CRAN Compliance

#### **R CMD Check**
- [ ] R CMD check passes with 0 errors, 0 warnings (`devtools::check()`)
- [ ] All examples run without errors (`devtools::check_examples()`)
- [ ] No global variable warnings
- [ ] Package builds successfully (`devtools::build()`)
- [ ] No deprecated function usage

#### **Package Structure**
- [ ] `DESCRIPTION` has correct metadata
- [ ] `NAMESPACE` is properly generated
- [ ] All dependencies are specified with version constraints
- [ ] License file is present and correct
- [ ] Package structure follows R conventions

---

## 🚀 Automated Validation Script

### Using the Pre-PR Validation Script

```bash
# Run the automated validation script
Rscript scripts/pre-pr-validation.R

# Or run individual phases
Rscript scripts/pre-pr-validation.R --phase=1  # Code Quality
Rscript scripts/pre-pr-validation.R --phase=2  # Documentation
Rscript scripts/pre-pr-validation.R --phase=3  # Testing
Rscript scripts/pre-pr-validation.R --phase=4  # Final Validation
```

### Manual Validation Steps

If you prefer to run validation manually:

#### **Phase 1: Code Quality (5-10 minutes)**
```r
# Format code
styler::style_pkg()

# Check code quality
lintr::lint_package()

# Review any warnings or errors
```

#### **Phase 2: Documentation (2-5 minutes)**
```r
# Update documentation
devtools::document()

# Rebuild README
devtools::build_readme()

# Check spelling
devtools::spell_check()

# Check examples
devtools::check_examples()
```

#### **Phase 3: Testing (3-5 minutes)**
```r
# Run tests
devtools::test()

# Check coverage
covr::package_coverage()

# Review test results
```

#### **Phase 4: Final Validation (5-10 minutes)**
```r
# Full package check
devtools::check()

# Build package
devtools::build()

# Review any issues
```

---

## 🔍 Common Issues and Solutions

### Code Quality Issues

#### **Style Issues**
```r
# Fix formatting
styler::style_pkg()

# Check specific files
styler::style_file("R/your-function.R")
```

#### **Lintr Warnings**
```r
# View all lintr issues
lintr::lint_package()

# Fix common issues:
# - Use <- for assignment instead of =
# - Use snake_case for function names
# - Add spaces around operators
# - Remove trailing whitespace
```

### Documentation Issues

#### **Missing Documentation**
```r
# Check for undocumented functions
devtools::check_man()

# Add documentation to functions
# Use roxygen2 comments above each function
```

#### **Spelling Errors**
```r
# Check spelling
devtools::spell_check()

# Add words to inst/WORDLIST if they're correct
```

### Testing Issues

#### **Test Failures**
```r
# Run specific test file
devtools::test_file("tests/testthat/test-your-function.R")

# Run tests with verbose output
devtools::test(reporter = "verbose")
```

#### **Low Coverage**
```r
# Check coverage for specific function
covr::function_coverage(your_function)

# Add tests for uncovered code paths
```

### CRAN Compliance Issues

#### **R CMD Check Errors**
```r
# Run full check
devtools::check()

# Check specific aspects
devtools::check_man()      # Documentation
devtools::check_examples() # Examples
devtools::spell_check()    # Spelling
```

#### **Build Issues**
```r
# Build package
devtools::build()

# Check package structure
devtools::check_built()
```

---

## 📊 Validation Metrics

### Target Metrics
- **Test Coverage**: >90%
- **R CMD Check**: 0 errors, 0 warnings
- **Documentation**: 100% of exported functions documented
- **Examples**: All examples runnable
- **Spelling**: 0 errors

### Current Status
- **Test Coverage**: 83.41% (target: 90%)
- **R CMD Check**: 0 errors, 0 warnings, 3 notes
- **Test Warnings**: 29 warnings to address

---

## 🔗 Related Documentation

- **[AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md)** - AI development guidelines
- **[CRAN_SUBMISSION.md](CRAN_SUBMISSION.md)** - CRAN submission requirements
- **[CONTEXT_PROVISION.md](CONTEXT_PROVISION.md)** - Context provision guidelines
- **[CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md)** - Cursor integration guidelines

---

## 📋 Quick Reference

### Essential Commands
```r
# Quick validation
devtools::test()
devtools::check()

# Full validation
Rscript scripts/pre-pr-validation.R

# Check specific aspects
devtools::spell_check()
devtools::check_examples()
covr::package_coverage()
```

### Common Fixes
```r
# Fix formatting
styler::style_pkg()

# Update documentation
devtools::document()

# Check for issues
lintr::lint_package()
```

---

**See Also**: [CONTRIBUTING.md](../../CONTRIBUTING.md) for general development guidelines 