# Segmentation Fault Analysis for zoomstudentengagement

## Overview
This document tracks functions that use `dplyr`, `rlang`, `vctrs`, or `tidyselect` which could be causing segmentation faults.

## Root Cause Analysis

### Primary Issue Identified
The segmentation faults are caused by **dplyr::lag with order_by parameter** when used with **lubridate period objects** in specific contexts.

### Specific Problematic Pattern
```r
# This pattern causes segmentation faults:
df %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start, default = lubridate::period(0))
  )
```

### Environment Details
- **R version**: 4.1.1 (2021-08-10)
- **Platform**: aarch64-apple-darwin20 (64-bit)
- **dplyr version**: 1.1.4
- **rlang version**: 1.1.6
- **vctrs version**: 0.6.5
- **tibble version**: 3.3.0
- **lubridate version**: 1.9.4
- **hms version**: 1.1.3

### Debugging Results
1. **Isolated Issue**: The segmentation fault occurs specifically in `dplyr::lag` with `order_by` parameter
2. **Context Dependent**: The issue appears only in certain contexts (not when tested in isolation)
3. **Memory Access**: The fault occurs in dplyr's C++ backend: `dplyr_lazy_vec_chop_impl`
4. **Address**: `0x662068637573206f` with cause 'invalid permissions'

## Functions with Heavy dplyr Usage (High Risk)

### 1. `load_zoom_recorded_sessions_list` - ✅ FIXED
- **Status**: Fixed with base R replacements
- **Previous Issues**: Segmentation fault in dplyr::mutate operations
- **Location**: `R/load_zoom_recorded_sessions_list.R`

### 2. `load_zoom_transcript` - ✅ FIXED  
- **Status**: Fixed with base R replacements
- **Previous Issues**: Segmentation fault in dplyr::mutate operations
- **Location**: `R/load_zoom_transcript.R`

### 3. `load_roster` - ✅ FIXED
- **Status**: Fixed with base R replacements  
- **Previous Issues**: Segmentation fault in dplyr::filter
- **Location**: `R/load_roster.R`

## Functions with Moderate dplyr Usage (Medium Risk)

### 4. `consolidate_transcript` - 🔴 CRITICAL ISSUE
- **Location**: `R/consolidate_transcript.R`
- **dplyr Usage**: 
  - `dplyr::mutate()` (lines 41, 53, 58, 71)
  - `dplyr::lag()` (lines 54, 56) - **SEGFAULT SOURCE**
  - `dplyr::group_by()` with `rlang::syms()` (line 63)
  - `dplyr::summarize()` (lines 64-70)
- **Risk Level**: CRITICAL - Contains the problematic dplyr::lag pattern
- **Specific Issue**: 
  ```r
  prev_end = dplyr::lag(end, order_by = start, default = lubridate::period(0))
  prior_speaker = dplyr::lag(name, order_by = start, default = dplyr::first(name))
  ```

### 5. `summarize_transcript_metrics` - ✅ WORKING
- **Location**: `R/summarize_transcript_metrics.R`
- **dplyr Usage**:
  - `dplyr::filter()` (line 95)
  - `dplyr::group_by()` with `rlang::syms()` (line 96)
  - `dplyr::summarise()` (lines 97-102)
  - `dplyr::mutate()` (line 104)
  - `dplyr::arrange()` (line 110)
- **Risk Level**: LOW - No dplyr::lag operations
- **Status**: ✅ Working without issues

### 6. `make_transcripts_session_summary_df` - ✅ WORKING
- **Location**: `R/make_transcripts_session_summary_df.R`
- **dplyr Usage**:
  - `dplyr::group_by()` with `rlang::syms()` (line 48)
  - `dplyr::summarise()` (lines 49-53)
  - `dplyr::ungroup()` (line 55)
  - `dplyr::mutate()` (line 56)
- **Risk Level**: LOW - No dplyr::lag operations
- **Status**: ✅ Working without issues

### 7. `make_clean_names_df` - ⚠️ NEEDS TESTING
- **Location**: `R/make_clean_names_df.R`
- **dplyr Usage**:
  - `dplyr::mutate()` (lines 118, 138, 167, 188, 193, 235, 236)
  - `dplyr::rename()` (line 135)
  - `dplyr::left_join()` with `dplyr::join_by()` (lines 153, 155)
  - `dplyr::full_join()` with `dplyr::join_by()` (lines 172, 174)
  - `dplyr::coalesce()` (lines 168, 194, 199)
  - `dplyr::case_when()` (line 195)
  - `dplyr::select()` (line 201)
  - `dplyr::arrange()` (line 231)
  - `dplyr::if_else()` (line 236)
  - `dplyr::distinct()` (line 241)
- **Risk Level**: MEDIUM - Complex dplyr operations but no dplyr::lag

### 8. `process_zoom_transcript` - 🔴 CRITICAL ISSUE
- **Location**: `R/process_zoom_transcript.R`
- **dplyr Usage**:
  - `dplyr::mutate()` (lines 68, 76, 106)
  - `dplyr::lag()` (lines 77, 79) - **POTENTIAL SEGFAULT SOURCE**
  - `dplyr::select()` (line 81)
  - `dplyr::arrange()` (line 105)
  - `dplyr::row_number()` (line 107)
  - `dplyr::case_when()` (line 109)
- **Risk Level**: CRITICAL - Contains dplyr::lag operations
- **Specific Issue**: 
  ```r
  begin = dplyr::lag(end, order_by = start, default = lubridate::period(0))
  prior_speaker = dplyr::lag(name, order_by = start, default = NA)
  ```

## Functions with Light dplyr Usage (Low Risk)

### 9. `add_dead_air_rows` - ⚠️ NEEDS TESTING
- **Location**: `R/add_dead_air_rows.R`
- **dplyr Usage**:
  - `dplyr::mutate()` (lines 24, 34)
  - `dplyr::lag()` (line 35) - **POTENTIAL SEGFAULT SOURCE**
  - `dplyr::bind_rows()` (line 53)
- **Risk Level**: MEDIUM - Contains dplyr::lag operation

### 10. `make_transcripts_summary_df` - ✅ WORKING
- **Location**: `R/make_transcripts_summary_df.R`
- **dplyr Usage**:
  - `dplyr::group_by()` (lines 37, 45)
  - `dplyr::summarise()` (lines 38-42)
  - `dplyr::ungroup()` (lines 44, 52)
  - `dplyr::mutate()` (line 46)
  - `dplyr::arrange()` (line 53)
- **Risk Level**: LOW - No dplyr::lag operations

### 11. `summarize_transcript_files` - ✅ WORKING
- **Location**: `R/summarize_transcript_files.R`
- **dplyr Usage**:
  - `dplyr::select()` (lines 85, 130, 132)
  - `dplyr::mutate()` (lines 86, 91, 104, 108, 137)
  - `dplyr::rename()` (line 90)
  - `dplyr::if_else()` (line 92)
  - `dplyr::filter()` (line 114)
  - `dplyr::left_join()` (line 138)
  - `dplyr::row_number()` (lines 86, 137)
- **Risk Level**: LOW - No dplyr::lag operations

### 12. `plot_users_by_metric` - ✅ WORKING
- **Location**: `R/plot_users_by_metric.R`
- **dplyr Usage**:
  - `dplyr::filter()` (line 98)
  - `dplyr::pull()` (line 99)
- **Risk Level**: LOW - No dplyr::lag operations

### 13. `create_session_mapping` - ✅ WORKING
- **Location**: `R/create_session_mapping.R`
- **dplyr Usage**:
  - `dplyr::select()` (line 76)
  - `dplyr::filter()` (line 120)
- **Risk Level**: LOW - No dplyr::lag operations

### 14. `write_section_names_lookup` - ✅ WORKING
- **Location**: `R/write_section_names_lookup.R`
- **dplyr Usage**:
  - `dplyr::group_by()` (line 91)
  - `dplyr::summarise()` (line 102)
  - `dplyr::arrange()` (line 103)
  - `dplyr::select()` (line 104)
  - `dplyr::n()` (line 102)
- **Risk Level**: LOW - No dplyr::lag operations

### 15. `load_session_mapping` - ✅ WORKING
- **Location**: `R/load_session_mapping.R`
- **dplyr Usage**:
  - `dplyr::filter()` (line 57)
  - `dplyr::select()` (lines 62, 92-94)
  - `dplyr::left_join()` (line 79)
  - `dplyr::mutate()` (line 83)
  - `dplyr::any_of()` (lines 93-94)
- **Risk Level**: LOW - No dplyr::lag operations

### 16. `make_names_to_clean_df` - ✅ WORKING
- **Location**: `R/make_names_to_clean_df.R`
- **dplyr Usage**:
  - `dplyr::group_by()` (line 56)
  - `dplyr::summarise()` (line 57)
  - `dplyr::filter()` (lines 58-59)
  - `dplyr::n()` (line 57)
- **Risk Level**: LOW - No dplyr::lag operations

## Testing Strategy

### Phase 1: Critical Functions (Immediate Priority)
1. `consolidate_transcript` - **CRITICAL** - Contains the problematic dplyr::lag pattern
2. `process_zoom_transcript` - **CRITICAL** - Contains dplyr::lag operations
3. `add_dead_air_rows` - **MEDIUM** - Contains dplyr::lag operation

### Phase 2: Medium-Risk Functions
1. `make_clean_names_df` - Test with minimal data

### Phase 3: Low-Risk Functions
1. All remaining functions with light dplyr usage

## Recommended Solutions

### 1. Immediate Fix (Recommended)
Replace problematic `dplyr::lag` operations with base R equivalents:

```r
# Instead of:
prev_end = dplyr::lag(end, order_by = start, default = lubridate::period(0))

# Use:
prev_end <- c(lubridate::period(0), end[-length(end)])
```

### 2. Alternative Fix
Use `dplyr::lag` without the problematic default:

```r
# Instead of:
prev_end = dplyr::lag(end, order_by = start, default = lubridate::period(0))

# Use:
prev_end = dplyr::lag(end, order_by = start)
# Then handle NA values separately
```

### 3. Package Version Investigation
- Check if this is a known issue with dplyr 1.1.4 + lubridate 1.9.4
- Consider testing with different package versions
- Report to dplyr/lubridate maintainers if reproducible

## Working dplyr Alternatives (Tested)

### Alternative 1: dplyr::lag without default + coalesce ✅
```r
df %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start)
  ) %>%
  dplyr::mutate(
    prev_end = dplyr::coalesce(prev_end, lubridate::period(0))
  )
```

### Alternative 2: dplyr::lag without default + if_else ✅
```r
df %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start)
  ) %>%
  dplyr::mutate(
    prev_end = dplyr::if_else(is.na(prev_end), lubridate::period(0), prev_end)
  )
```

### Alternative 3: dplyr::lag without order_by ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, default = lubridate::period(0))
  )
```

### Alternative 4: dplyr::lead instead of lag ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    next_start = dplyr::lead(start, default = lubridate::period(0))
  )
```

### Alternative 5: row_number + case_when ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    row_num = dplyr::row_number(),
    prev_end = dplyr::case_when(
      row_num == 1 ~ lubridate::period(0),
      TRUE ~ dplyr::lag(end)
    )
  )
```

### Alternative 6: group_by + lag ✅
```r
df %>%
  dplyr::group_by(transcript_file) %>%
  dplyr::arrange(start, .by_group = TRUE) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, default = lubridate::period(0))
  ) %>%
  dplyr::ungroup()
```

### Alternative 7: tidyr::nest + purrr::map (Requires tidyr)
```r
df %>%
  dplyr::group_by(transcript_file) %>%
  tidyr::nest() %>%
  dplyr::mutate(
    data = purrr::map(data, function(df) {
      df %>%
        dplyr::arrange(start) %>%
        dplyr::mutate(
          prev_end = dplyr::lag(end, default = lubridate::period(0))
        )
    })
  ) %>%
  tidyr::unnest(data)
```

## Recommended Implementation Strategy

### For `consolidate_transcript` function:
**Option A (Simplest)**: Use Alternative 3 - remove order_by and use arrange
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, default = lubridate::period(0)),
    prior_dead_air = as.numeric(start - prev_end, "seconds"),
    prior_speaker = dplyr::lag(name, default = dplyr::first(name))
  )
```

**Option B (Maintains order_by logic)**: Use Alternative 1 - separate steps
```r
df %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start)
  ) %>%
  dplyr::mutate(
    prev_end = dplyr::coalesce(prev_end, lubridate::period(0)),
    prior_dead_air = as.numeric(start - prev_end, "seconds"),
    prior_speaker = dplyr::lag(name, order_by = start, default = dplyr::first(name))
  )
```

### For `process_zoom_transcript` function:
**Option A (Simplest)**: Use Alternative 3
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    begin = dplyr::lag(end, default = lubridate::period(0)),
    prior_speaker = dplyr::lag(name, default = NA)
  )
```

**Option B (Maintains order_by logic)**: Use Alternative 1
```r
df %>%
  dplyr::mutate(
    begin = dplyr::lag(end, order_by = start)
  ) %>%
  dplyr::mutate(
    begin = dplyr::coalesce(begin, lubridate::period(0)),
    prior_speaker = dplyr::lag(name, order_by = start, default = NA)
  )
```

## Performance Considerations

- **Alternative 3** (arrange + lag) is likely fastest as it avoids the problematic order_by
- **Alternative 1** (separate steps) maintains the original logic but requires two mutate steps
- **Alternative 6** (group_by) is good for grouped operations but may be slower for large datasets

## Future Optimization Opportunity: Vectorized Operations

### Alternative 12: Vectorized Operations (Most Efficient)
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = c(lubridate::period(0), end[-length(end)])
  )
```

**Performance Benefits:**
- **Fastest approach**: Direct vector manipulation bypasses dplyr's overhead
- **Memory efficient**: No intermediate data structures
- **Scalable**: Performance doesn't degrade with larger datasets

**Implementation Notes:**
- Requires understanding of R's vector operations
- Less "dplyr-like" but more performant
- Could be implemented as a helper function for consistency

**Future Enhancement:**
Consider creating a package-wide optimization where functions that need lag operations on period objects use vectorized approaches for better performance, especially for large transcript datasets.

**Tracking:**
- **Documentation**: See `docs/development/PERFORMANCE_OPTIMIZATION.md` for detailed implementation plan
- **GitHub Issue**: Consider creating issue "Performance: Vectorized operations for lag functions"
- **Priority**: Medium - implement after segmentation fault fixes are complete

## Compatibility Notes

- All alternatives work with dplyr 1.1.4 and lubridate 1.9.4
- Alternative 7 requires tidyr and purrr packages
- Alternatives 1-6 use only dplyr functions 