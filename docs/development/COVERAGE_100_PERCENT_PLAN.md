# 100% Test Coverage Implementation Plan

## Overview
Current coverage: 84.92% → Target: 100%
Goal: Systematic improvement of test coverage with each test passing on first attempt.

## Priority Ranking (by Impact and Effort)

### Phase 1: High Impact, High Complexity
1. **detect_duplicate_transcripts.R** (29.51% → 100%)
2. **create_session_mapping.R** (66.25% → 100%)

### Phase 2: Medium Impact
3. **make_transcripts_summary_df.R** (69.23% → 100%)
4. **summarize_transcript_files.R** (70.93% → 100%)

### Phase 3: Low Impact
5. **load_section_names_lookup.R** (76.19% → 100%)
6. **add_dead_air_rows.R** (81.08% → 100%)
7. **join_transcripts_list.R** (82.11% → 100%)
8. **load_cancelled_classes.R** (84.62% → 100%)
9. **load_roster.R** (87.50% → 100%)
10. **make_clean_names_df.R** (88.37% → 100%)
11. **make_student_roster_sessions.R** (88.89% → 100%)

## Detailed Function Analysis

### 1. detect_duplicate_transcripts.R (29.51% → 100%)

#### Current Coverage Gaps:
- **Lines 108-130**: Metadata comparison logic (file size, timestamps)
- **Lines 132-170**: Content-based comparison with actual VTT files
- **Lines 172-185**: Duplicate group detection algorithm
- **Lines 187-195**: Recommendation generation
- **Lines 197-210**: Summary statistics calculation

#### Specific Test Requirements:

##### A. Metadata Comparison Tests
```r
# Test file metadata comparison
- Create files with identical sizes but different timestamps
- Create files with different sizes but identical timestamps
- Test size similarity calculation: size_sim <- 1 - abs(file_sizes[i] - file_sizes[j]) / max(file_sizes[i], file_sizes[j])
- Test time similarity calculation: time_sim <- ifelse(time_diff < 3600, 1.0, max(0, 1 - time_diff / 86400))
- Test combined metadata similarity: metadata_sim <- (size_sim + time_sim) / 2
```

##### B. Content Comparison Tests
```r
# Test content-based similarity
- Create VTT files with identical content (should have similarity = 1.0)
- Create VTT files with similar content (should have similarity > 0.8)
- Create VTT files with different content (should have similarity < 0.5)
- Test names_to_exclude parameter functionality
- Test error handling when files can't be loaded
```

##### C. Duplicate Group Detection Tests
```r
# Test the core algorithm
- Test with 2 identical files (should create 1 group of 2)
- Test with 3 identical files (should create 1 group of 3)
- Test with 2 groups of identical files (should create 2 groups)
- Test with no duplicates (should create 0 groups)
- Test with similarity threshold variations
```

##### D. Recommendation Generation Tests
```r
# Test recommendation logic
- Test with 2-file groups: "Keep file1 and remove file2"
- Test with 3+ file groups: "Keep file1 and remove file2, file3"
- Test with multiple groups
- Test with no groups (empty recommendations)
```

##### E. Method-Specific Tests
```r
# Test each detection method
- metadata: Only uses file metadata
- content: Only uses content comparison
- hybrid: Combines both metadata and content
```

#### Test Data Requirements:
```r
# VTT file templates needed:
1. Basic VTT file with 1 speaker, 1 comment
2. VTT file with multiple speakers
3. VTT file with dead_air entries
4. Identical copies of each template
5. Modified versions with slight differences
```

### 2. create_session_mapping.R (66.25% → 100%)

#### Current Coverage Gaps:
- **Lines 100+**: Automatic pattern matching logic
- **Lines 150+**: Interactive assignment mode
- **Lines 180+**: File output functionality
- Error handling for invalid patterns
- Edge cases with no matches

#### Specific Test Requirements:

##### A. Pattern Matching Tests
```r
# Test automatic pattern assignment
- Test with exact pattern matches
- Test with regex pattern matches
- Test with multiple matching patterns
- Test with no matching patterns
- Test pattern priority (first match wins)
```

##### B. Interactive Mode Tests
```r
# Test interactive assignment
- Mock user input for course selection
- Test with valid course selections
- Test with invalid selections (should retry)
- Test with cancel/exit options
```

##### C. File Output Tests
```r
# Test CSV file generation
- Test with valid output path
- Test with invalid output path (should error gracefully)
- Test file content validation
- Test file permissions
```

##### D. Edge Case Tests
```r
# Test edge cases
- Empty zoom_recordings_df
- Empty course_info_df
- Missing required columns
- Invalid date formats
- Duplicate course assignments
```

### 3. make_transcripts_summary_df.R (69.23% → 100%)

#### Current Coverage Gaps:
- Complex data aggregation logic
- Edge cases with missing data
- Error handling scenarios
- Performance optimization paths

#### Specific Test Requirements:

##### A. Data Aggregation Tests
```r
# Test aggregation logic
- Test with complete data
- Test with missing speaker names
- Test with missing timestamps
- Test with empty transcripts
- Test with single-speaker transcripts
- Test with multi-speaker transcripts
```

##### B. Edge Case Tests
```r
# Test edge cases
- Empty input data
- Data with all NA values
- Data with mixed data types
- Very large datasets
- Data with special characters in names
```

### 4. summarize_transcript_files.R (70.93% → 100%)

#### Current Coverage Gaps:
- Batch processing logic
- Error handling for file loading failures
- Progress reporting functionality
- Memory optimization paths

#### Specific Test Requirements:

##### A. Batch Processing Tests
```r
# Test batch processing
- Test with single file
- Test with multiple files
- Test with files that don't exist
- Test with mixed valid/invalid files
- Test progress reporting
```

##### B. Error Handling Tests
```r
# Test error scenarios
- Files that can't be read
- Corrupted VTT files
- Permission denied errors
- Memory limit scenarios
```

### 5. load_section_names_lookup.R (76.19% → 100%)

#### Current Coverage Gaps:
- File validation logic
- Data transformation edge cases
- Error handling for malformed files

#### Specific Test Requirements:

##### A. File Validation Tests
```r
# Test file validation
- Valid CSV files
- Invalid CSV formats
- Missing required columns
- Empty files
- Files with wrong data types
```

##### B. Data Transformation Tests
```r
# Test data processing
- Standard section name formats
- Special characters in names
- Duplicate entries
- Case sensitivity handling
```

## Implementation Strategy

### Phase 1: detect_duplicate_transcripts.R
**Estimated Time: 4-6 hours**

#### Step 1: Create Test Data
1. Create VTT file templates
2. Create identical copies
3. Create modified versions
4. Set up file metadata variations

#### Step 2: Implement Metadata Tests
1. Test file size comparison
2. Test timestamp comparison
3. Test combined metadata similarity
4. Test edge cases (zero sizes, identical timestamps)

#### Step 3: Implement Content Tests
1. Test identical content detection
2. Test similar content detection
3. Test different content detection
4. Test names_to_exclude functionality

#### Step 4: Implement Algorithm Tests
1. Test duplicate group detection
2. Test recommendation generation
3. Test summary statistics
4. Test all three methods (metadata, content, hybrid)

### Phase 2: create_session_mapping.R
**Estimated Time: 2-3 hours**

#### Step 1: Pattern Matching Tests
1. Test exact pattern matches
2. Test regex pattern matches
3. Test no matches scenario
4. Test multiple matches

#### Step 2: Interactive Mode Tests
1. Mock user input
2. Test valid selections
3. Test invalid selections
4. Test exit scenarios

#### Step 3: File Output Tests
1. Test CSV generation
2. Test error handling
3. Test file validation

### Phase 3: Remaining Functions
**Estimated Time: 3-4 hours**

#### Step 1: make_transcripts_summary_df.R
1. Test data aggregation
2. Test edge cases
3. Test error handling

#### Step 2: summarize_transcript_files.R
1. Test batch processing
2. Test error handling
3. Test progress reporting

#### Step 3: Other Functions
1. Test remaining edge cases
2. Test error scenarios
3. Test performance paths

## Success Criteria

### For Each Function:
- [ ] All code paths tested
- [ ] Edge cases covered
- [ ] Error scenarios handled
- [ ] Tests pass on first run
- [ ] Coverage reaches target percentage

### Overall Success:
- [ ] Package coverage reaches 100%
- [ ] All tests pass
- [ ] No regression in existing functionality
- [ ] Documentation updated

## Risk Mitigation

### Technical Risks:
1. **Complex file operations**: Use temporary files and proper cleanup
2. **Interactive testing**: Mock user input instead of real interaction
3. **Performance issues**: Use small test datasets
4. **Platform differences**: Test on multiple platforms

### Quality Assurance:
1. **Test isolation**: Each test should be independent
2. **Cleanup**: Always clean up temporary files
3. **Validation**: Verify test results manually
4. **Documentation**: Document complex test scenarios

## Timeline

### Week 1:
- Day 1-2: detect_duplicate_transcripts.R (Phase 1)
- Day 3-4: create_session_mapping.R (Phase 2)

### Week 2:
- Day 1-2: make_transcripts_summary_df.R and summarize_transcript_files.R
- Day 3-4: Remaining functions and final validation

### Week 3:
- Day 1-2: Final testing and documentation
- Day 3-4: Code review and cleanup

## Notes

- Each test should be designed to pass on first attempt
- Use temporary files and directories for file-based tests
- Mock external dependencies where possible
- Document any assumptions about test environment
- Maintain backward compatibility with existing tests 