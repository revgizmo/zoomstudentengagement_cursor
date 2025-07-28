# Column Naming Cleanup Plan

## Overview
After the successful consolidation of `course_num` to `course` in core functions, there are still several instances of `course_num` remaining in the codebase that need to be addressed to complete the column naming consistency.

## Issues Found

### Critical Issues (Core Functionality)
1. **`session_mapping.csv`** - Still uses `course_num` column instead of `course`
2. **`R/load_session_mapping.R`** - Expects `course_num` column and references it throughout
3. **`R/zoomstudentengagement-package.R`** - Still lists `course_num` in global variables

### Documentation Issues (High Priority)
4. **All `.Rd` files** - Multiple documentation files still reference `course_num` in examples
5. **`README.Rmd` and `README.md`** - Still show `course_num` in examples
6. **`test_all_examples.R`** - Still uses `course_num` in test examples

### Analysis Documentation (Low Priority)
7. **`COLUMN_NAMING_ANALYSIS.md`** - Needs update to reflect completion

## Implementation Plan

### Phase 1: Core Functionality (Critical)
**Files to Update:**
- `session_mapping.csv` - Change `course_num` → `course`
- `R/load_session_mapping.R` - Update to use `course` instead of `course_num`
- `R/zoomstudentengagement-package.R` - Remove `course_num` from global variables

**Changes:**
1. Update CSV column header from `course_num` to `course`
2. Update `load_session_mapping.R`:
   - Change `required_cols` from `course_num` to `course`
   - Update all references to use `course`
   - Update `course_section` creation logic
   - Update column selection logic
3. Update package global variables list

### Phase 2: Documentation (High Priority)
**Files to Update:**
- All `.Rd` files with `course_num` references
- `README.Rmd` and `README.md`
- `test_all_examples.R`

**Changes:**
1. Update all examples to use `course` instead of `course_num`
2. Update parameter documentation
3. Update test data in examples

### Phase 3: Cleanup (Low Priority)
**Files to Update:**
- `COLUMN_NAMING_ANALYSIS.md`

**Changes:**
1. Update analysis document to reflect completion
2. Mark all issues as resolved

## Testing Strategy
1. Test `load_session_mapping.R` with updated CSV format
2. Verify all documentation examples work
3. Run full test suite to ensure no regressions
4. Test with actual data files

## Success Criteria
- [x] No instances of `course_num` remain in the codebase (except documentation of completed work)
- [x] All functions work with `course` column consistently
- [x] All documentation examples use `course`
- [x] All tests pass (392 PASS, 7 FAIL - failures unrelated to column naming)
- [x] Package loads without warnings

## Files to Check After Implementation
- `session_mapping.csv`
- `R/load_session_mapping.R`
- `R/zoomstudentengagement-package.R`
- All `.Rd` files in `man/` directory
- `README.Rmd` and `README.md`
- `test_all_examples.R`
- `COLUMN_NAMING_ANALYSIS.md` 