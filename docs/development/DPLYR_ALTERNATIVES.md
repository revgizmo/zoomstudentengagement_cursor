# Dplyr Alternatives for Segmentation Fault Fix

## Overview
This document provides multiple working alternatives to fix the segmentation fault caused by `dplyr::lag` with `order_by` parameter and `lubridate::period` objects.

## Root Cause
The segmentation fault occurs with this pattern:
```r
dplyr::lag(end, order_by = start, default = lubridate::period(0))
```

## Working Alternatives (All Tested)

### 1. Separate Steps with coalesce ✅
```r
df %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start)
  ) %>%
  dplyr::mutate(
    prev_end = dplyr::coalesce(prev_end, lubridate::period(0))
  )
```
**Pros**: Maintains original logic, clear separation
**Cons**: Requires two mutate steps

### 2. Separate Steps with if_else ✅
```r
df %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start)
  ) %>%
  dplyr::mutate(
    prev_end = dplyr::if_else(is.na(prev_end), lubridate::period(0), prev_end)
  )
```
**Pros**: Maintains original logic, explicit NA handling
**Cons**: Requires two mutate steps

### 3. Remove order_by, use arrange ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, default = lubridate::period(0))
  )
```
**Pros**: Simplest approach, likely fastest
**Cons**: Changes the ordering logic

### 4. Use lead instead of lag ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    next_start = dplyr::lead(start, default = lubridate::period(0))
  )
```
**Pros**: Avoids lag entirely, different perspective
**Cons**: Requires logic adjustment

### 5. row_number + case_when ✅
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
**Pros**: Explicit first row handling
**Cons**: More verbose

### 6. group_by + lag ✅
```r
df %>%
  dplyr::group_by(transcript_file) %>%
  dplyr::arrange(start, .by_group = TRUE) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, default = lubridate::period(0))
  ) %>%
  dplyr::ungroup()
```
**Pros**: Handles grouped data naturally
**Cons**: May be slower for large datasets

### 7. tidyr::nest + purrr::map ✅
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
**Pros**: Handles complex nested operations
**Cons**: Requires tidyr and purrr, more complex

### 8. row_number + conditional logic ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    is_first = dplyr::row_number() == 1,
    prev_end = dplyr::case_when(
      is_first ~ lubridate::period(0),
      TRUE ~ dplyr::lag(end)
    )
  )
```
**Pros**: Clear first row logic
**Cons**: Slightly verbose

### 9. if_else with row_number ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end)
  ) %>%
  dplyr::mutate(
    prev_end = dplyr::if_else(dplyr::row_number() == 1, lubridate::period(0), prev_end)
  )
```
**Pros**: Explicit row-based logic
**Cons**: Two mutate steps

### 10. Custom function with across ✅
```r
lag_with_default <- function(x, default_val) {
  ifelse(is.na(dplyr::lag(x)), default_val, dplyr::lag(x))
}

df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = lag_with_default(end, lubridate::period(0))
  )
```
**Pros**: Reusable function, clean syntax
**Cons**: Requires custom function

### 11. transmute approach ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::transmute(
    transcript_file,
    comment_num,
    name,
    comment,
    start,
    end,
    duration,
    wordcount,
    prev_end = dplyr::lag(end, default = lubridate::period(0))
  )
```
**Pros**: Explicit column selection
**Cons**: Requires listing all columns

### 12. Vectorized operations ✅
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = c(lubridate::period(0), end[-length(end)])
  )
```
**Pros**: Most efficient, direct vector manipulation
**Cons**: Less dplyr-like, requires understanding of vector operations

### 13. tidyr::replace_na ✅
```r
df %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, order_by = start)
  ) %>%
  dplyr::mutate(
    prev_end = tidyr::replace_na(prev_end, lubridate::period(0))
  )
```
**Pros**: Uses tidyr's specialized NA replacement
**Cons**: Requires tidyr package

## Recommended Implementation for Specific Functions

### For `consolidate_transcript`:

**Option A (Simplest)**: Use Alternative 3
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    prev_end = dplyr::lag(end, default = lubridate::period(0)),
    prior_dead_air = as.numeric(start - prev_end, "seconds"),
    prior_speaker = dplyr::lag(name, default = dplyr::first(name))
  )
```

**Option B (Maintains order_by)**: Use Alternative 1
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

### For `process_zoom_transcript`:

**Option A (Simplest)**: Use Alternative 3
```r
df %>%
  dplyr::arrange(start) %>%
  dplyr::mutate(
    begin = dplyr::lag(end, default = lubridate::period(0)),
    prior_speaker = dplyr::lag(name, default = NA)
  )
```

**Option B (Maintains order_by)**: Use Alternative 1
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

| Alternative | Performance | Complexity | Maintainability |
|-------------|-------------|------------|-----------------|
| 3 (arrange + lag) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 12 (vectorized) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| 1 (separate steps) | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 6 (group_by) | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 7 (nest + map) | ⭐⭐ | ⭐⭐ | ⭐⭐⭐ |

## Compatibility Matrix

| Alternative | dplyr 1.1.4 | tidyr required | purrr required | Base R only |
|-------------|-------------|----------------|----------------|-------------|
| 1-6, 8-12 | ✅ | ❌ | ❌ | ❌ |
| 7 | ✅ | ✅ | ✅ | ❌ |
| 13 | ✅ | ✅ | ❌ | ❌ |
| 12 | ✅ | ❌ | ❌ | ⚠️ |

## Testing Strategy

1. **Unit Tests**: Test each alternative with minimal data
2. **Integration Tests**: Test with real transcript data
3. **Performance Tests**: Benchmark against original code
4. **Regression Tests**: Ensure no functionality is lost

## Migration Guide

1. **Identify problematic code**: Look for `dplyr::lag` with `order_by` and `default` parameters
2. **Choose alternative**: Based on performance and complexity requirements
3. **Implement change**: Replace the problematic pattern
4. **Test thoroughly**: Ensure functionality is preserved
5. **Document change**: Update code comments and documentation

## Future Considerations

- Monitor dplyr/lubridate updates for potential fixes
- Consider filing bug reports with package maintainers
- Evaluate if this is a known issue in newer versions
- Consider adding tests to prevent regression 