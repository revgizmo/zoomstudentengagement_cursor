# Issue #20: 100% Test Coverage - Current Todo List

## Current Status
- **Overall Coverage**: 90.76% (up from 84.92%)
- **Branch**: `feature/issue-20-test-coverage`
- **Last Updated**: $(date)

## Functions with 100% Coverage ✅
- `add_dead_air_rows.R` (100.00%) - **COMPLETED**
- `consolidate_transcript.R` (100.00%)
- `create_analysis_config.R` (100.00%)
- `load_and_process_zoom_transcript.R` (100.00%)
- `make_blank_cancelled_classes_df.R` (100.00%)
- `make_blank_section_names_lookup_csv.R` (100.00%)
- `make_metrics_lookup_df.R` (100.00%)
- `make_names_to_clean_df.R` (100.00%)
- `make_new_analysis_template.R` (100.00%)
- `make_roster_small.R` (100.00%)
- `make_semester_df.R` (100.00%)
- `make_students_only_transcripts_summary_df.R` (100.00%)
- `mask_user_names_by_metric.R` (100.00%)
- `plot_users_by_metric.R` (100.00%)
- `plot_users_masked_section_by_metric.R` (100.00%)
- `process_zoom_transcript.R` (100.00%)
- `summarize_transcript_metrics.R` (100.00%)
- `write_section_names_lookup.R` (100.00%)
- `write_transcripts_session_summary.R` (100.00%)
- `write_transcripts_summary.R` (100.00%)

## Functions Needing 100% Coverage (Priority Order)

### High Priority (Low Coverage)
1. **`make_transcripts_summary_df.R`** (69.23% → 100%)
   - **Gap**: 30.77%
   - **Complexity**: High
   - **Impact**: High (core functionality)
   - **Status**: 🔴 Needs work

2. **`summarize_transcript_files.R`** (72.09% → 100%)
   - **Gap**: 27.91%
   - **Complexity**: Medium
   - **Impact**: High (batch processing)
   - **Status**: 🔴 Needs work

3. **`create_session_mapping.R`** (72.50% → 100%)
   - **Gap**: 27.50%
   - **Complexity**: High
   - **Impact**: Medium
   - **Status**: 🔴 Needs work

### Medium Priority (Medium Coverage)
4. **`join_transcripts_list.R`** (82.11% → 100%)
   - **Gap**: 17.89%
   - **Complexity**: Low
   - **Impact**: Medium
   - **Status**: 🟡 Low effort

5. **`load_cancelled_classes.R`** (84.62% → 100%)
   - **Gap**: 15.38%
   - **Complexity**: Low
   - **Impact**: Low
   - **Status**: 🟡 Low effort

6. **`load_roster.R`** (87.50% → 100%)
   - **Gap**: 12.50%
   - **Complexity**: Low
   - **Impact**: Medium
   - **Status**: 🟡 Low effort

7. **`make_clean_names_df.R`** (88.37% → 100%)
   - **Gap**: 11.63%
   - **Complexity**: Low
   - **Impact**: Low
   - **Status**: 🟡 Low effort

8. **`make_student_roster_sessions.R`** (88.89% → 100%)
   - **Gap**: 11.11%
   - **Complexity**: Low
   - **Impact**: Low
   - **Status**: 🟡 Low effort

### Low Priority (High Coverage)
9. **`detect_duplicate_transcripts.R`** (89.34% → 100%)
   - **Gap**: 10.66%
   - **Complexity**: High
   - **Impact**: Medium
   - **Status**: 🟢 Nearly complete

10. **`load_section_names_lookup.R`** (90.48% → 100%)
    - **Gap**: 9.52%
    - **Complexity**: Low
    - **Impact**: Low
    - **Status**: 🟢 Nearly complete

## Recommended Work Order

### Phase 1: High Impact, Low Effort (Quick Wins)
1. `load_section_names_lookup.R` (90.48% → 100%) - 9.52% gap
2. `detect_duplicate_transcripts.R` (89.34% → 100%) - 10.66% gap
3. `make_student_roster_sessions.R` (88.89% → 100%) - 11.11% gap
4. `make_clean_names_df.R` (88.37% → 100%) - 11.63% gap

### Phase 2: Medium Impact, Low Effort
5. `load_roster.R` (87.50% → 100%) - 12.50% gap
6. `load_cancelled_classes.R` (84.62% → 100%) - 15.38% gap
7. `join_transcripts_list.R` (82.11% → 100%) - 17.89% gap

### Phase 3: High Impact, High Effort (Complex Functions)
8. `create_session_mapping.R` (72.50% → 100%) - 27.50% gap
9. `summarize_transcript_files.R` (72.09% → 100%) - 27.91% gap
10. `make_transcripts_summary_df.R` (69.23% → 100%) - 30.77% gap

## Progress Tracking

### Completed Today
- ✅ `add_dead_air_rows.R` - Fixed test expectations to match actual function behavior
  - Changed from expecting `Period` objects to `hms` objects
  - Fixed dead air row expectations (only for actual gaps)
  - Fixed optional column expectations (only when they exist in original)

### Next Up
- 🔄 `load_section_names_lookup.R` (90.48% → 100%)
  - Small gap, likely edge cases or error handling
  - Good candidate for quick win

## Notes
- Focus on functions with smaller gaps first for quick progress
- Complex functions like `make_transcripts_summary_df.R` should be tackled last
- Each function should be completed before moving to the next
- Update this todo list as functions are completed
- Run full test suite after each function to ensure no regressions

## Success Criteria
- [ ] All functions reach 100% coverage
- [ ] Overall package coverage reaches 100%
- [ ] All tests pass
- [ ] No regression in existing functionality
- [ ] Ready for CRAN submission 