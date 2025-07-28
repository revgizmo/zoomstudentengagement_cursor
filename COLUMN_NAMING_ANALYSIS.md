# Column Naming and Type Consistency Analysis

## Current State Analysis

### Inconsistencies Found

The package currently has inconsistent handling of course identifiers and related fields:

1. **`make_roster_small.R`** expects `course_num` (integer)
2. **`make_sections_df.R`** expects `course` (character)
3. **`make_student_roster_sessions.R`** uses `course_num` (integer) and converts for comparisons
4. **`create_course_info.R`** uses `course_num` (integer)
5. **`make_clean_names_df.R`** converts `course_num` to character for joins
6. **`create_session_mapping.R`** uses `course_num` (integer)

### Data Source Analysis

The actual roster data (`inst/extdata/roster.csv`) contains:
- `course_num`: integer (e.g., 23)
- `section`: integer (e.g., 24)
- `student_id`: character (e.g., "9990000019")

## Recommendations for Future Versions

### 1. Consolidate to `course` as character

**Rationale:**
- Course numbers can include letters (e.g., "101A", "250B", "CS61A")
- Character type is more flexible for course identifiers
- Avoids type conversion issues in joins
- More consistent with how departments and sections are handled
- Follows tidyverse best practices for ID columns

### 2. Use character type for all identifiers

**Recommended column types:**
- `student_id`: character (already correct in data)
- `course`: character (instead of `course_num` integer)
- `section`: character (instead of integer)
- `dept`: character (already correct)

**Rationale:**
- These are true identifiers, not categorical variables for analysis
- Character type is more flexible for data manipulation
- Avoids type conversion issues in joins
- Consistent with tidyverse best practices

### 3. Don't use factors for identifiers

**Rationale:**
- Factors add complexity without benefit for join operations
- Character type is more flexible for data manipulation
- Consistent with tidyverse best practices for ID columns

## Implementation Plan for Future Version

### Phase 1: Create Migration Functions
1. Create `migrate_roster_columns()` function to convert existing data
2. Add deprecation warnings for `course_num` usage
3. Maintain backward compatibility for one major version

### Phase 2: Update Core Functions
1. Update `make_roster_small()` to use `course` instead of `course_num`
2. Update `make_sections_df()` to expect `course` (already correct)
3. Update `make_student_roster_sessions()` to handle both formats during transition
4. Update all related functions consistently

### Phase 3: Update Documentation and Examples
1. Update all roxygen2 documentation
2. Update README and vignettes
3. Update test files
4. Update example data files

### Phase 4: Remove Backward Compatibility
1. Remove deprecated `course_num` support
2. Clean up migration functions
3. Update package version to 2.0.0

## Files Requiring Updates

### Core Functions (15 files):
- `R/make_roster_small.R`
- `R/make_sections_df.R`
- `R/make_student_roster_sessions.R`
- `R/create_course_info.R`
- `R/create_session_mapping.R`
- `R/make_clean_names_df.R`
- `R/load_session_mapping.R`
- `R/plot_users_by_metric.R`
- `R/write_section_names_lookup.R`
- `R/write_transcripts_session_summary.R`
- `R/make_students_only_transcripts_summary_df.R`
- `R/write_transcripts_summary.R`
- `R/plot_users_masked_section_by_metric.R`
- `R/zoomstudentengagement-package.R`

### Test Files (8 files):
- `tests/testthat/test-make_roster_small.R`
- `tests/testthat/test-make_sections_df.R`
- `tests/testthat/test-create_session_mapping.R`
- `tests/testthat/test-make_student_roster_sessions.R`
- `tests/testthat/test-name-matching.R`
- `tests/testthat/helper-zoomstudentengagement.R`

### Documentation and Examples:
- `test_all_examples.R`
- `README.md`
- `README.Rmd`
- All man/*.Rd files

## Migration Strategy

### For Current Release (1.x.x):
- Keep current inconsistent behavior
- Document the inconsistency in package documentation
- Add notes about future standardization

### For Next Major Release (2.0.0):
- Implement the consolidation to `course` as character
- Provide migration functions
- Update all documentation and examples
- Maintain backward compatibility for one version

### For Release 3.0.0:
- Remove backward compatibility
- Clean up deprecated functions

## Benefits of Consolidation

1. **Consistency**: All functions use the same column names and types
2. **Flexibility**: Character types handle course numbers with letters
3. **Maintainability**: Easier to understand and maintain code
4. **Performance**: Fewer type conversions in joins
5. **User Experience**: More predictable behavior across functions

## Risks and Considerations

1. **Breaking Changes**: Will require major version bump
2. **Migration Effort**: Significant testing and documentation updates needed
3. **User Impact**: Existing workflows may need updates
4. **Data Compatibility**: May need to handle existing data formats

## Conclusion

The consolidation to `course` as character is recommended for future versions, but should be implemented as a major version change with proper migration support. For the current release, maintaining the existing behavior is the safest approach given the package's preparation for CRAN submission. 