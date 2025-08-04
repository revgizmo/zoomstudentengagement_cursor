# R Package Review Guidelines

## R Package Development Focus Areas

### Function and Variable Names
- Use snake_case for function names
- Use camelCase for data frame column names when appropriate
- Check for consistent naming conventions

### Function Signature Validation
- **CRITICAL**: Verify function calls match actual function signatures
- Check for argument mismatches (e.g., `load_roster(file_path)` vs `load_roster(data_folder, roster_file)`)
- Validate function parameters exist before calling
- Check for deprecated function signatures

### Logic Validation
- **CRITICAL**: Verify code refactoring maintains same operations and outputs
- Check that all calculated columns are still being computed (duration, wordcount, etc.)
- Validate aggregation functions return correct counts, not just first rows
- Ensure mathematical operations (like duration calculations) work correctly
- Verify that group operations maintain proper counts and relationships
- Confirm that function outputs match expected data structure and content

### Data Structure Validation
- Verify column names exist before accessing (e.g., `roster$name` vs `roster$preferred_name`)
- Check data types match expected inputs
- Validate function arguments match signatures
- **CRITICAL**: Check for missing columns that vignettes expect (e.g., 'name' column in roster)

### Test Environment Cleanliness
- **CRITICAL**: Ensure all diagnostic output is conditional on test environment
- Check that `print()`, `cat()`, and `message()` statements are wrapped in `if (Sys.getenv("TESTTHAT") != "true")`
- Verify warnings and diagnostic output are consistently suppressed in test environment
- **Pattern**: Warning suppressed but diagnostic output still shows
- **Example**: `warning("Found duplicates")` conditional but `print(duplicates)` not conditional
- **Detection**: Look for `print()`, `cat()`, `message()` outside of conditional blocks

### Diagnostic Output Management
- **CRITICAL**: All user-facing output should be conditional on test environment
- Check for inconsistent output behavior between warnings and diagnostic messages
- Verify that debug information doesn't pollute test output
- **Pattern**: Mixed conditional/non-conditional output in same function
- **Example**: Warning conditional but `cat()` or `print()` not conditional
- **Detection**: Scan for output functions not wrapped in `TESTTHAT` checks

### CRAN Compliance Focus
- **CRITICAL**: Clean test output is required for CRAN submission
- Check that test runs produce minimal, clean output
- Verify no diagnostic messages appear in test results
- **Pattern**: Test output polluted with debug information
- **Example**: Test shows "Found 3 duplicate groups" instead of clean pass/fail
- **Detection**: Run tests and check for unexpected output

### R Package Best Practices
- All exported functions must have complete roxygen2 documentation
- Include `@param`, `@return`, `@examples` sections
- Use `@export` tag for public functions
- Examples must be runnable

### Common R Issues
- Missing library() calls for external packages
- Incorrect function signatures
- Data type mismatches in data frames
- Missing error handling for file operations

### Vignette-Specific Checks
- All code chunks must be runnable
- Check for proper use of system.file() for package data
- Verify function calls match actual package exports
- Ensure data examples use correct column names
- **CRITICAL**: Validate function calls use correct argument structure

### Mathematical Formula Validation
- **CRITICAL**: Check Gini coefficient formulas for correctness
- Avoid formulas starting with "1 -" that should not
- Verify final terms in statistical calculations
- Check for incorrect mathematical operators and parentheses

### Script and Validation Issues
- **CRITICAL**: Avoid hardcoded status messages that don't reflect actual results
- Use dynamic status reporting based on actual validation outcomes
- Ensure validation scripts show real-time results, not placeholder text
- Check for debugging code left in production scripts

### Security and Privacy
- No hardcoded API keys or sensitive data
- Proper data anonymization in examples
- Ethical use considerations for student data

## Architecture Patterns
- Use data.table for large data operations
- Prefer tibble over data.frame for consistency
- Use dplyr verbs for data manipulation
- Handle missing values explicitly

## Error Prevention
- Validate input parameters early in functions
- Provide helpful error messages
- Use stop() for fatal errors with informative messages
- Check file existence before reading

## Bugbot-Specific Patterns

### Function Signature Mismatches
- **Pattern**: Function called with wrong number or type of arguments
- **Example**: `load_roster(file_path)` instead of `load_roster(data_folder, roster_file)`
- **Detection**: Compare function calls with actual function signatures

### Logic Validation Failures
- **Pattern**: Code refactoring missing critical calculations or operations
- **Example**: `consolidate_transcript` missing duration/wordcount calculations
- **Example**: `make_names_to_clean_df` always setting `n = 1` instead of group counts
- **Example**: Aggregation functions returning wrong counts after refactoring
- **Detection**: Verify all expected columns are computed and have reasonable values

### Column Name Issues
- **Pattern**: Accessing non-existent columns in data frames
- **Example**: `roster$name` when roster has `first_last`, `preferred_name` columns
- **Detection**: Validate column existence before access

### Mathematical Formula Errors
- **Pattern**: Incorrect statistical calculations, especially Gini coefficient
- **Example**: `1 - (2 * sum(rank(x) * x) / (n() * sum(x))) - 1/n()`
- **Detection**: Pattern matching for common formula errors

### Hardcoded Status Messages
- **Pattern**: Scripts showing incorrect status regardless of actual results
- **Example**: Always showing "❌ Testing: Segmentation fault detected"
- **Detection**: Check for static status messages vs dynamic reporting

### Data Structure Validation
- **Pattern**: Missing validation of data structure and content
- **Example**: Not checking if roster has expected columns
- **Detection**: Validate data structure matches expectations

### Test Environment Output Inconsistencies
- **Pattern**: Warning suppressed but diagnostic output still shows
- **Example**: `warning("Found duplicates")` conditional but `print(duplicates)` not conditional
- **Example**: `warning("Unmapped recordings")` conditional but `cat("Unmapped recordings:\n")` not conditional
- **Detection**: Look for `print()`, `cat()`, `message()` outside of `if (Sys.getenv("TESTTHAT") != "true")` blocks

### Diagnostic Output Pollution
- **Pattern**: Debug messages appearing in test output
- **Example**: Test shows "Duplicate detection results:" instead of clean pass/fail
- **Example**: Test shows "Found 3 duplicate groups" in output
- **Detection**: Run tests and check for unexpected diagnostic messages

### Inconsistent Output Behavior
- **Pattern**: Mixed conditional/non-conditional output in same function
- **Example**: Warning conditional but related `cat()` or `print()` not conditional
- **Detection**: Scan for output functions not consistently wrapped in `TESTTHAT` checks

## Pre-PR Validation Checklist
- [ ] Function signatures match actual implementations
- [ ] Column names exist before access
- [ ] Mathematical formulas are correct
- [ ] Status messages reflect actual results
- [ ] Data structures are validated
- [ ] All examples are runnable
- [ ] Vignettes use correct function calls
- [ ] No hardcoded debugging information
- [ ] **CRITICAL**: Code refactoring maintains same operations and outputs
- [ ] **CRITICAL**: All calculated columns (duration, wordcount, etc.) are computed
- [ ] **CRITICAL**: Aggregation functions return correct counts, not just first rows
- [ ] **CRITICAL**: All diagnostic output is conditional on test environment
- [ ] **CRITICAL**: No `print()`, `cat()`, or `message()` outside of `TESTTHAT` checks
- [ ] **CRITICAL**: Test output is clean and minimal (no debug messages)
- [ ] **CRITICAL**: Warnings and diagnostic output are consistently suppressed in tests

## Lessons Learned and Prevention

### Why We Missed These Issues (Cursor Bot PR #117)
- **Focus Gap**: Our validation focused on logic, data structures, and formulas, but not test output quality
- **CRAN Blind Spot**: We didn't prioritize clean test output as critical for CRAN submission
- **Incomplete Patterns**: Missing patterns for diagnostic output management
- **Validation Gap**: Pre-PR validation didn't specifically check for test output pollution

### Prevention Strategies
- **Add Test Output Validation**: Include test output cleanliness in pre-PR checks
- **Pattern Recognition**: Look for mixed conditional/non-conditional output
- **CRAN Focus**: Prioritize clean test output as critical for submission
- **Consistent Checks**: Ensure all output functions are consistently conditional

### Key Patterns to Watch For
- Warning conditional but `print()`/`cat()` not conditional
- Debug messages appearing in test output
- Inconsistent output behavior in same function
- Test output polluted with diagnostic information 