# Issue #160 Implementation Prompt
*Comprehensive Implementation Guide for Name Matching with Privacy-First Design*

## 🎯 **Context and Objective**

You are implementing **Issue #160: Name Matching with Privacy-First Design** for the `zoomstudentengagement` R package. This is a **CRITICAL CRAN submission blocker** that must be resolved before the package can be submitted to CRAN.

**Key Context Files:**
- `@ISSUE_160_NAME_MATCHING_PLAN.md` - Comprehensive implementation plan
- `@PROJECT.md` - Current project status and priorities
- `@full-context.md` - Complete project context

## 🚨 **Critical Requirements**

### **Privacy-First Design (NON-NEGOTIABLE)**
- **Names must NEVER be unmasked outside of memory**, even with complete name mappings
- **Default behavior**: "stop" on unmatched names (maximum privacy protection)
- **All outputs must be privacy-masked** (no real names in final results)
- **Explicit memory cleanup** using `rm()` for sensitive data
- **Privacy validation** at final boundaries only

### **FERPA Compliance**
- Real names only in memory during processing
- No real names in logs, outputs, or exported files
- Consistent hashing for cross-session matching
- Privacy levels control final output format

## 🏗️ **Implementation Approach**

### **Two-Stage Processing with Consistent Hashing**
1. **Stage 1**: Unmasked processing for matching (real names in memory only)
2. **Stage 2**: Privacy masking for outputs (no real names in final results)

### **Configuration Options**
```r
set_privacy_defaults(
  privacy_level = "mask",
  unmatched_names_action = "stop"  # Options: "stop", "warn"
)
```

## 📋 **Functions to Implement**

### **Phase 1: Core Functions (Priority 1)**
1. **`validate_privacy_compliance()`** - Output privacy validation
2. **`prompt_name_matching()`** - User guidance for name matching
3. **`detect_unmatched_names()`** - Identify names needing matching
4. **`safe_name_matching_workflow()`** - Main workflow function

### **Phase 2: Integration Functions (Priority 2)**
1. **`match_names_with_privacy()`** - Comprehensive name matching
2. **`process_transcript_with_privacy()`** - Two-stage processing

### **Phase 3: Enhanced Functions (Priority 3)**
1. **Enhanced `set_privacy_defaults()`** - Add `unmatched_names_action` parameter
2. **Enhanced `ensure_privacy()`** - Support consistent hashing
3. **Enhanced `make_clean_names_df()`** - Use new privacy-aware matching
4. **Enhanced `write_section_names_lookup()`** - Save with instructions

## 🔧 **Technical Specifications**

### **User Experience Flow**
```r
# Default behavior (maximum privacy)
result <- safe_name_matching_workflow(transcript_file, roster_data)
# → Stops with error if unmatched names found

# Opt-in for convenience
result <- safe_name_matching_workflow(
  transcript_file, 
  roster_data,
  unmatched_names_action = "warn"
)
# → Warns and guides user through matching process
```

### **Privacy Validation**
- **Exact matches only** for real name detection
- **Stop processing with error** if privacy validation fails (unless privacy = "none")
- **No fallback to unmasked outputs** - privacy violations indicate bugs

### **Memory Management**
- **Use `rm()` for explicit cleanup** (R best practice)
- Remove real name variables from function scope after processing
- Clear sensitive data from memory immediately after use

## 📊 **Testing Requirements**

### **Unit Tests**
- Test privacy compliance at all boundaries
- Test memory cleanup functionality
- Test configuration options
- Test error handling for privacy violations

### **Integration Tests**
- Test end-to-end workflow
- Test with real transcript data
- Test performance impact (<10% overhead)

### **Privacy Tests**
- Verify no real names in outputs
- Test privacy validation function
- Test memory cleanup

## 🎯 **Success Criteria**

### **Functional Requirements**
- [ ] Names can be matched across sessions with variations
- [ ] Privacy masking works correctly in all outputs
- [ ] Instructor identification works via `participant_type`
- [ ] Guest labeling works per session
- [ ] Name evolution tracking within sessions

### **Privacy Requirements (CRITICAL)**
- [ ] Real names NEVER appear in outputs, even with complete mappings
- [ ] All outputs validated for privacy compliance
- [ ] Memory-only processing of real names
- [ ] Automatic cleanup of real names from memory

### **Technical Requirements**
- [ ] All tests pass (including new privacy tests)
- [ ] Performance impact is acceptable (<10% overhead)
- [ ] Backward compatibility maintained where possible
- [ ] R CMD check passes with 0 errors, 0 warnings

## 🚀 **Implementation Guidelines**

### **Code Standards**
- Follow [tidyverse style guide](https://style.tidyverse.org/)
- Use `<-` for assignment over `=`
- Use snake_case for function and variable names
- Maximum line length: 80 characters
- Use `#'` for roxygen2 documentation

### **Documentation Requirements**
- Complete roxygen2 documentation for all new functions
- Include `@param`, `@return`, `@examples` sections
- Provide working examples for all exported functions
- Use `@export` tag for public functions

### **Error Handling**
- Use `stop()` for fatal errors with informative messages
- Use `warning()` for recoverable issues
- Use `message()` for informational output
- Validate input parameters early in functions

### **Testing Strategy**
- One test file per R file in `tests/testthat/`
- Use descriptive test file names: `test-function-name.R`
- Group related tests with `describe()` blocks
- Use `test_that()` for individual test cases
- Use `expect_*()` functions for assertions

## ⚠️ **Critical Implementation Notes**

### **Privacy Boundaries**
- **Real names only exist in function scope**
- **No real names stored in global variables**
- **Explicit cleanup** of real names from memory after processing
- **Privacy validation at final boundaries only**

### **User-Driven Process**
- Keep the manual name mapping process (user creates `section_names_lookup.csv`)
- Add `participant_type` column to identify instructors, students, guests
- Prompt user to clean up mismatches
- Handle session-specific guest labeling

### **Configuration-Driven Behavior**
- **Default**: "stop" for unmatched names (maximum privacy)
- **Opt-in**: "warn" for guided matching (user convenience)
- **User control**: `suppressWarnings()` for advanced users

## 📝 **Implementation Checklist**

### **Before Starting**
- [ ] Review `@ISSUE_160_NAME_MATCHING_PLAN.md` thoroughly
- [ ] Understand privacy-first requirements
- [ ] Review existing privacy implementation (`ensure_privacy()`, `set_privacy_defaults()`)
- [ ] Check current test coverage and structure

### **During Implementation**
- [ ] Implement functions in priority order
- [ ] Test each function thoroughly
- [ ] Ensure privacy compliance at every step
- [ ] Document all functions with roxygen2
- [ ] Create comprehensive test suite

### **Before Completion**
- [ ] Run full test suite (`devtools::test()`)
- [ ] Run R CMD check (`devtools::check()`)
- [ ] Verify privacy compliance in all outputs
- [ ] Update vignettes and documentation
- [ ] Validate performance impact

## 🔗 **Key Files to Reference**

### **Existing Privacy Implementation**
- `R/ensure_privacy.R` - Current privacy framework
- `R/set_privacy_defaults.R` - Global privacy configuration
- `R/mask_user_names_by_metric.R` - Name masking utility

### **Core Functions to Modify**
- `R/make_clean_names_df.R` - Name matching logic
- `R/load_section_names_lookup.R` - Name mappings
- `R/write_section_names_lookup.R` - Save mappings

### **Test Infrastructure**
- `tests/testthat/` - Test framework
- `tests/testthat/helper-zoomstudentengagement.R` - Test helpers

## 🎯 **Expected Outcome**

A **privacy-first name matching system** that:
- ✅ Maintains maximum privacy protection by default
- ✅ Allows name matching across sessions with variations
- ✅ Provides clear user guidance for manual matching
- ✅ Ensures FERPA compliance at all boundaries
- ✅ Follows R best practices and coding standards
- ✅ Passes all tests and R CMD check
- ✅ Is ready for CRAN submission

---

**Status**: Ready for Implementation  
**Priority**: CRITICAL - CRAN Submission Blocker  
**Timeline**: 6-10 days  
**Branch**: `feature/issue-160-name-matching-privacy`

**Remember**: Privacy is the top priority. When in doubt, choose the more privacy-protective option.



