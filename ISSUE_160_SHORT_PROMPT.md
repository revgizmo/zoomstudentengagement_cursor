# Issue #160 Implementation - Short Prompt

## Context
You are implementing **Issue #160: Name Matching with Privacy-First Design** for the `zoomstudentengagement` R package. This is a **CRITICAL CRAN submission blocker**.

**Key Context Files:**
- `@ISSUE_160_NAME_MATCHING_PLAN.md` - Comprehensive implementation plan
- `@PROJECT.md` - Current project status and priorities  
- `@full-context.md` - Complete project context
- `@ISSUE_160_IMPLEMENTATION_PROMPT.md` - Detailed implementation guide

## Critical Requirements
- **Privacy-First**: Names must NEVER be unmasked outside of memory, even with complete mappings
- **Default**: "stop" on unmatched names (maximum privacy protection)
- **All outputs**: Privacy-masked (no real names in final results)
- **Memory cleanup**: Use `rm()` for sensitive data
- **FERPA compliance**: Real names only in memory during processing

## Implementation Approach
**Two-Stage Processing with Consistent Hashing:**
1. **Stage 1**: Unmasked processing for matching (real names in memory only)
2. **Stage 2**: Privacy masking for outputs (no real names in final results)

## Functions to Implement (Priority Order)
1. `validate_privacy_compliance()` - Output privacy validation
2. `prompt_name_matching()` - User guidance for name matching  
3. `detect_unmatched_names()` - Identify names needing matching
4. `safe_name_matching_workflow()` - Main workflow function
5. `match_names_with_privacy()` - Comprehensive name matching
6. Enhanced `set_privacy_defaults()` - Add `unmatched_names_action` parameter
7. Enhanced `make_clean_names_df()` - Use new privacy-aware matching

## User Experience
```r
# Default (maximum privacy)
result <- safe_name_matching_workflow(transcript_file, roster_data)
# → Stops if unmatched names found

# Opt-in for convenience  
result <- safe_name_matching_workflow(
  transcript_file, roster_data,
  unmatched_names_action = "warn"
)
# → Warns and guides user through matching
```

## Success Criteria
- [ ] Names matched across sessions with variations
- [ ] Privacy masking works in all outputs
- [ ] No real names in final results
- [ ] All tests pass
- [ ] R CMD check passes (0 errors, 0 warnings)
- [ ] Performance impact <10% overhead

## Key Files to Reference
- `R/ensure_privacy.R` - Current privacy framework
- `R/set_privacy_defaults.R` - Global privacy configuration  
- `R/make_clean_names_df.R` - Name matching logic
- `tests/testthat/` - Test framework

**Remember**: Privacy is the top priority. When in doubt, choose the more privacy-protective option.
