# Clean up make_clean_names_df test warnings

## Description
The tests for `make_clean_names_df` currently produce warnings about conditions with length > 1. These warnings occur in multiple test files:
- test-make_clean_names_df.R
- test-name-matching.R
- test-plotting_functions.R

## Current Behavior
When running tests, we see warnings like:
```
Warning: the condition has length > 1 and only the first element will be used
```

This occurs because `dplyr::coalesce` in `make_clean_names_df` can return vectors of length > 1, and the test assertions are not explicitly handling this case.

## Expected Behavior
Tests should run without warnings, properly handling vector lengths in all assertions.

## Proposed Solution
1. Review all test assertions in affected files
2. Update assertions to explicitly handle vector lengths where needed
3. Consider using `purrr::map` or similar to handle vectorized operations
4. Add explicit length checks in assertions
5. Update test documentation to clarify expected behavior

## Files to Modify
- tests/testthat/test-make_clean_names_df.R
- tests/testthat/test-name-matching.R
- tests/testthat/test-plotting_functions.R
- R/make_clean_names_df.R (if needed for implementation changes)

## Priority
Medium - The warnings don't affect functionality but should be cleaned up for better test hygiene and maintainability.

## Related Issues
- Part of the larger test suite cleanup (#15)
- Related to function naming and API consistency (#16)

## Acceptance Criteria
- [ ] All tests pass without warnings
- [ ] Test assertions properly handle vector lengths
- [ ] Documentation is updated to reflect changes
- [ ] No regression in existing functionality 