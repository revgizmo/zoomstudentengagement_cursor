# Issue #294: Equity Metrics Tests - Consolidated Plan

## Overview
**Issue**: test(metrics): equity metrics positive/negative cases  
**Priority**: HIGH  
**Area**: Testing  
**Milestone**: Testing & Coverage (>90%)  
**Status**: OPEN

## Current Status and Accomplishments

### ✅ **Existing Test Coverage**
- **Current Coverage**: 90.22% (target achieved)
- **Test Suite**: 1650 tests passing, 0 failures
- **Equity-Related Functions**: Already have basic tests in `test-plotting_functions.R`

### ✅ **Existing Equity Functions**
1. **`plot_users()`** - Unified plotting function with privacy-aware options
2. **`plot_users_by_metric()`** - Deprecated but delegates to `plot_users()`
3. **`plot_users_masked_section_by_metric()`** - Section-based masking
4. **`mask_user_names_by_metric()`** - Rank-based name masking

### ✅ **Current Test Coverage**
- Basic functionality tests for plotting functions
- Empty data handling
- Invalid metrics handling
- Privacy masking validation

## Remaining Work: Equity-Focused Test Cases

### **Phase 1: Boundary and Edge Cases (Priority: HIGH)**
**Objective**: Test equity metrics functions with boundary conditions and edge cases

**Test Scenarios**:
1. **Single Participant Classes**
   - Test with only one student in a section
   - Verify plots render correctly without errors
   - Check rank masking behavior

2. **All Equal Participation**
   - Test with identical participation metrics across all students
   - Verify rank assignment handles ties correctly
   - Check visualization clarity

3. **Extreme Participation Differences**
   - Test with one student having 10x more participation than others
   - Verify plots scale appropriately
   - Check for visual outliers

4. **International Names and Special Characters**
   - Test with names containing accents, non-Latin characters
   - Verify masking preserves privacy while maintaining readability
   - Check encoding issues

5. **Very Large Classes (50+ students)**
   - Test performance with large datasets
   - Verify plot readability with many participants
   - Check memory usage

### **Phase 2: Failure Mode Testing (Priority: HIGH)**
**Objective**: Ensure graceful handling of problematic data scenarios

**Test Scenarios**:
1. **Missing Participation Data**
   - Test with NA values in metric columns
   - Verify appropriate warnings/errors
   - Check data filtering behavior

2. **Zero Participation Students**
   - Test with students having 0 duration, 0 wordcount
   - Verify they appear in plots appropriately
   - Check rank assignment for zero values

3. **Negative Values (Data Errors)**
   - Test with negative durations or wordcounts
   - Verify error handling and validation
   - Check user-friendly error messages

4. **Duplicate Student Names**
   - Test with multiple students having same name
   - Verify masking distinguishes between them
   - Check for data integrity issues

### **Phase 3: Equity-Specific Validation (Priority: MEDIUM)**
**Objective**: Validate that functions support educational equity goals

**Test Scenarios**:
1. **Participation Distribution Analysis**
   - Test that plots clearly show participation gaps
   - Verify rank masking doesn't obscure equity issues
   - Check that visualizations support intervention planning

2. **Section Comparison Equity**
   - Test cross-section participation comparisons
   - Verify faceting supports equity analysis
   - Check that masked plots maintain analytical value

3. **Privacy vs. Equity Balance**
   - Test that privacy masking doesn't hide important equity patterns
   - Verify rank-based masking preserves relative positions
   - Check that unmasked versions are available when needed

## Technical Requirements

### **Test Data Requirements**
- **Realistic Scenarios**: Use data that mirrors real classroom situations
- **International Names**: Include names with accents, non-Latin characters
- **Edge Cases**: Include single students, large classes, tied rankings
- **Problematic Data**: Include NA values, zeros, negative values

### **Test Function Requirements**
- **Comprehensive Coverage**: Test all equity-related functions
- **Boundary Testing**: Include edge cases and failure modes
- **Performance Testing**: Test with large datasets
- **Privacy Validation**: Ensure masking works correctly

### **Documentation Requirements**
- **Test Descriptions**: Clear documentation of what each test validates
- **Equity Context**: Explain how tests support educational equity goals
- **Usage Examples**: Provide examples of how to use functions for equity analysis

## Success Criteria

### **Coverage Requirements**
- ✅ Maintain ≥90% test coverage
- ✅ Add tests for all identified edge cases
- ✅ Ensure all equity functions have comprehensive test coverage

### **Functionality Requirements**
- ✅ All tests pass without warnings
- ✅ Edge cases handled gracefully
- ✅ Performance acceptable with large datasets
- ✅ Privacy masking works correctly

### **Quality Requirements**
- ✅ Tests are well-documented
- ✅ Test data is realistic and diverse
- ✅ Error messages are user-friendly
- ✅ Tests support educational equity goals

## Implementation Timeline

### **Week 1: Phase 1 - Boundary and Edge Cases**
- Day 1-2: Single participant and equal participation tests
- Day 3-4: Extreme differences and international names tests
- Day 5: Large class performance tests

### **Week 2: Phase 2 - Failure Mode Testing**
- Day 1-2: Missing data and zero participation tests
- Day 3-4: Negative values and duplicate names tests
- Day 5: Integration and validation

### **Week 3: Phase 3 - Equity-Specific Validation**
- Day 1-2: Participation distribution analysis tests
- Day 3-4: Section comparison and privacy balance tests
- Day 5: Documentation and final validation

## Risk Assessment

### **Low Risk**
- Basic functionality already tested
- Good existing test infrastructure
- Clear requirements and success criteria

### **Medium Risk**
- Performance with large datasets
- International character encoding
- Privacy masking edge cases

### **Mitigation Strategies**
- Use realistic test data sizes
- Test with various character encodings
- Comprehensive privacy validation

## Dependencies

### **Internal Dependencies**
- Existing test infrastructure
- Current equity functions
- Test data generation utilities

### **External Dependencies**
- ggplot2 for visualization testing
- tibble for data structure validation
- testthat for test framework

## Follow-up Actions

### **Post-Implementation**
- Update documentation with equity-focused examples
- Create vignette demonstrating equity analysis workflows
- Consider additional equity-specific functions based on test findings

### **Long-term Considerations**
- Monitor real-world usage for additional edge cases
- Consider performance optimization for very large classes
- Evaluate need for additional equity analysis tools
