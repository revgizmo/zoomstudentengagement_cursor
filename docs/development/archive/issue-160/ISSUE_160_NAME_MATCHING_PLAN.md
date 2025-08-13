# Issue #160: Name Matching with Privacy-First Design
*Comprehensive Name Matching Framework with FERPA Compliance*

**Date**: August 2025  
**Status**: PLANNING - Ready for Implementation  
**Priority**: CRITICAL - CRAN Submission Blocker  
**Branch**: `feature/issue-160-name-matching-privacy`

---

## 🎯 **Executive Summary**

### **Problem Statement**
The current name matching process breaks when privacy masking is applied early in the pipeline. Real names are needed for matching against student rosters, but privacy requirements demand that names be masked in all outputs. This creates a fundamental conflict between functionality and privacy compliance.

### **Solution Overview**
Implement a **Two-Stage Processing with Consistent Hashing** framework that:
1. **Maintains privacy-first defaults** (stop on unmatched names)
2. **Uses consistent hashing** for privacy-safe matching
3. **Provides user-driven matching** with clear guidance
4. **Ensures FERPA compliance** at all boundaries
5. **Supports explicit user control** when needed

### **Key Features**
- ✅ **Privacy-First Defaults**: "stop" behavior for unmatched names (maximum protection)
- ✅ **Consistent Hashing**: SHA256-based name matching without exposing real names
- ✅ **Two-Pass Processing**: Privacy-safe processing with user intervention when needed
- ✅ **User-Driven Matching**: Clear guidance for updating `section_names_lookup.csv`
- ✅ **Memory Safety**: Explicit cleanup of sensitive data
- ✅ **Output Validation**: Privacy compliance checking at final boundaries
- ✅ **R Best Practices**: Global options, warning suppression, explicit parameter setting

### **Configuration Options**
```r
set_privacy_defaults(
  privacy_level = "mask",
  unmatched_names_action = "stop"  # Options: "stop", "warn"
)
```

### **User Experience**
- **Default**: Stops processing if unmatched names found (maximum privacy)
- **Opt-in**: Users can set `unmatched_names_action = "warn"` for guided matching
- **Suppression**: Advanced users can use `suppressWarnings()` if needed

### **Implementation Timeline**
- **Phase 1**: Core hashing and privacy functions (2-3 days)
- **Phase 2**: Two-pass processing workflow (2-3 days)  
- **Phase 3**: User prompting and guidance (1-2 days)
- **Phase 4**: Testing and documentation (1-2 days)
- **Total**: 6-10 days

---

## 📋 **Detailed Implementation Plan**

## 🚨 **Problem Statement**

The current privacy-first framework masks names immediately upon loading transcripts, which breaks the name matching functionality. This creates a fundamental conflict:

1. **Privacy Requirement**: Names must be masked as early as possible
2. **Matching Requirement**: Names must be available for matching against roster
3. **Current Result**: 0 matches because "Student_123" ≠ "Student_456" even if they represent the same person

## 🎯 **Solution Overview**

Implement a **two-stage processing approach** with **consistent hashing** that allows matching while maintaining privacy:

- **Stage 1**: Unmasked processing for matching (real names in memory only)
- **Stage 2**: Privacy masking for outputs (no real names in final results)

## 🔒 **CRITICAL PRIVACY REQUIREMENT**

**Names must NEVER be unmasked outside of memory, even with complete name mappings.**

### **Privacy Guarantees:**
- ✅ Real names only exist in memory during processing
- ✅ All outputs are privacy-masked (no real names)
- ✅ No real names in logs, files, or exported data
- ✅ Validation ensures privacy compliance
- ✅ Complete name mappings don't bypass privacy controls

## 📋 **User Requirements Analysis**

Based on codebase analysis and user feedback, the matching process should handle:

### **1. Name Entity Types**
- **Instructors**: "Dr. Melissa Ko" vs "Melissa Ko" in roster
- **Enrolled Students**: Students on roster with various name formats
- **Guests**: Non-enrolled participants (labeled as "Guest_01", "Guest_02" per session)
- **Unknown**: Unidentifiable participants

### **2. Name Variation Scenarios**
- **Formal vs Preferred**: "Tom Smith" vs "Thomas Smith"
- **Nicknames**: "Tom" → "Tommy" → "Thomas"
- **Titles**: "Dr. Smith" vs "Smith"
- **Format Variations**: "Smith, John" vs "John Smith"

### **3. User-Driven Process**
- Keep the manual name mapping process (user creates `section_names_lookup.csv`)
- Add `participant_type` column to identify instructors, students, guests
- Prompt user to clean up mismatches
- Handle session-specific guest labeling

## 🏗️ **Technical Implementation Plan**

### **Phase 1: Core Infrastructure (2-3 days)**

#### **1.1 Consistent Hashing Function** ✅ **COMPLETED**
- **File**: `R/hash_name_consistently.R`
- **Purpose**: Generate consistent hashes for name variations
- **Features**: 
  - Normalize names (remove titles, punctuation, case-insensitive)
  - Generate deterministic hashes
  - Handle edge cases (empty names, special characters)

#### **1.2 Enhanced Name Mapping Structure**
- **File**: `R/load_section_names_lookup.R` (modify)
- **Purpose**: Support `participant_type` column
- **Structure**:
  ```csv
  transcript_name,preferred_name,formal_name,participant_type,student_id
  "Dr. Melissa Ko","Melissa Ko","Melissa Ko","instructor",""
  "Tom","Thomas Smith","Thomas Smith","enrolled_student","12345"
  "Guest1","Guest_01","Guest_01","guest",""
  ```

#### **1.3 Privacy-Aware Processing Function**
- **File**: `R/process_transcript_with_privacy.R` (new)
- **Purpose**: Two-stage processing with privacy controls
- **Stages**:
  - Stage 1: Load transcript, match names, create mappings
  - Stage 2: Apply privacy masking to all outputs

### **Phase 2: Enhanced Matching Logic (2-3 days)**

#### **2.1 Enhanced Name Matching Function**
- **File**: `R/match_names_with_privacy.R` (new)
- **Purpose**: Comprehensive name matching with privacy awareness
- **Features**:
  - Use consistent hashing for cross-session matching
  - Handle name variations and nicknames
  - Support instructor identification
  - Guest labeling per session
  - Name evolution tracking within sessions

#### **2.2 Modified Core Functions**
- **File**: `R/make_clean_names_df.R` (modify)
- **Purpose**: Use new privacy-aware matching
- **Changes**:
  - Support `participant_type` column
  - Use consistent hashing for matching
  - Maintain backward compatibility

#### **2.3 Enhanced Privacy Framework**
- **File**: `R/ensure_privacy.R` (modify)
- **Purpose**: Work with consistent hashing
- **Changes**:
  - Support hashed name matching
  - Validate no real names in outputs
  - Enhanced FERPA compliance

### **Phase 3: User Experience & Documentation (1-2 days)**

#### **3.1 Updated Vignettes**
- **File**: `vignettes/whole-game.Rmd` (modify)
- **Purpose**: Demonstrate new privacy-aware workflow
- **Changes**:
  - Show two-stage processing
  - Explain `participant_type` usage
  - Demonstrate guest handling

#### **3.2 Enhanced Template**
- **File**: `inst/new_analysis_template.Rmd` (modify)
- **Purpose**: Updated workflow with privacy awareness
- **Changes**:
  - Clear instructions for name mapping
  - Participant type identification
  - Privacy validation steps

#### **3.3 User Documentation**
- **File**: `README.md` (modify)
- **Purpose**: Explain new privacy-aware matching
- **Changes**:
  - Privacy-first workflow explanation
  - Name matching best practices
  - FERPA compliance notes

## 🔧 **Detailed Function Specifications**

### **`hash_name_consistently()`** ✅ **COMPLETED**
```r
hash_name_consistently(names, salt = "zoomstudentengagement", normalize_names = TRUE)
```
- **Input**: Character vector of names
- **Output**: Character vector of consistent hashes
- **Features**: Normalization, secure hashing, edge case handling

### **`match_names_with_privacy()`** (to implement)
```r
match_names_with_privacy(transcript_data, roster_data, name_mappings, privacy_level = "mask")
```
- **Input**: Transcript data, roster data, name mappings
- **Output**: Matched data with privacy controls
- **Features**: Two-stage processing, consistent hashing, participant type support

### **`process_transcript_with_privacy()`** (to implement)
```r
process_transcript_with_privacy(transcript_file_path, roster_data, name_mappings, privacy_level = "mask")
```
- **Input**: Transcript file, roster, mappings
- **Output**: Processed data with privacy applied
- **Features**: Complete two-stage workflow

### **`validate_privacy_compliance()`** (to implement)
```r
validate_privacy_compliance(data, privacy_level = "mask")
```
- **Input**: Data to validate, privacy level
- **Output**: TRUE if compliant, error if not
- **Features**: **Exact matches only** for real name detection, scans outputs for privacy violations

### **`prompt_name_matching()`** (to implement)
```r
prompt_name_matching(unmatched_names, privacy_level = "mask")
```
- **Input**: Unmatched names, privacy level
- **Output**: User guidance for name matching
- **Features**: Safe prompting, privacy warnings, **uses existing `make_blank_section_names_lookup_csv()` function**

### **Enhanced `write_section_names_lookup()`** (modify existing)
```r
write_section_names_lookup(clean_names_df, data_folder = "data", section_names_lookup_file = "section_names_lookup.csv", include_instructions = TRUE)
```
- **Input**: Clean names data, folder, filename, include instructions flag
- **Output**: Enhanced CSV with matches, mismatches, and user instructions
- **Features**: **Save matches and mismatches with instructions for user cleanup**

### **Enhanced `set_privacy_defaults()`** (modify existing)
```r
set_privacy_defaults(privacy_level = "mask", unmatched_names_action = "warn")
```
- **Input**: Privacy level, unmatched names action
- **Output**: Updated global options
- **Features**: 
  - Sets `zoomstudentengagement.privacy_level` option
  - Sets `zoomstudentengagement.unmatched_names_action` option
  - Validates configuration values
  - Provides clear documentation of options

### **`safe_name_matching_workflow()`** (to implement)
```r
safe_name_matching_workflow(transcript_file_path, roster_data, privacy_level = "mask", unmatched_names_action = NULL)
```
- **Input**: Transcript file, roster, privacy level, unmatched names action
- **Output**: Processed data with privacy applied
- **Features**: 
  - Automatic two-pass processing
  - Configuration-driven behavior for unmatched names
  - **Privacy-first defaults**: "stop" for unmatched names (maximum protection)
  - Safe user prompting when needed
  - Privacy validation at each step
  - Clear guidance for manual updates

### **`detect_unmatched_names()`** (to implement)
```r
detect_unmatched_names(transcript_data, roster_data, name_mappings)
```
- **Input**: Transcript data, roster data, name mappings
- **Output**: List of unmatched names (real names, only if privacy = "none")
- **Features**: Identifies names needing manual mapping

## 📊 **Data Flow**

### **Current (Broken) Flow:**
```
Load Transcript → Names Masked → Try to Match → Always Fails
```

### **New (Fixed) Flow:**
```
Load Transcript → Match Names → Apply Privacy Masking → Output
```

### **Detailed New Flow:**
```
1. Load transcript (real names in memory only)
2. Load roster (real names in memory only)
3. Load name mappings (real names in memory only)
4. Generate consistent hashes for matching
5. Match names using hashes
6. Apply privacy masking to outputs
7. Validate no real names in final results
8. Explicitly clear real names from memory
9. If matching exceptions occur → prompt user safely
10. Enhanced write_section_names_lookup() saves results with instructions
```

## 🔄 **Two-Pass Approach for Unmatched Names**

### **The Challenge:**
After hashing names for privacy, we need to show users the **real names** that need matching in `section_names_lookup.csv`. This requires a two-pass approach.

### **Configuration Option for Unmatched Names**
Add a new global option to control behavior when unmatched names are found:

```r
# Set behavior for unmatched names
set_privacy_defaults(
  privacy_level = "mask",
  unmatched_names_action = "stop"  # Options: "stop", "warn"
)
```

**Options:**
- **`"stop"`** (default): Stop processing with error if unmatched names found
- **`"warn"`**: Show warning and temporarily disable privacy for matching

**User Control:**
```r
# User can suppress warnings if needed
suppressWarnings({
  result <- safe_name_matching_workflow(transcript_file, roster_data)
})
```

### **Pass 1: Privacy-Safe Processing**
```
1. Load transcript with real names (in memory only)
2. Generate consistent hashes for all names
3. Attempt matching using hashes
4. Identify unmatched hashes
5. Apply privacy masking to all outputs
6. Clear real names from memory
7. If unmatched hashes exist → check configuration and act accordingly
```

### **Pass 2: User Matching (if needed)**
```
1. Check unmatched_names_action configuration
2. If "warn": Temporarily set privacy_level = "none" (with warning)
3. If "stop": Stop with error
4. If "ignore": Continue without user intervention
5. Show user real names that need matching (if action = "warn")
6. User updates section_names_lookup.csv
7. Re-run Pass 1 with updated mappings
8. Re-enable privacy for final outputs
9. Validate privacy compliance
```

### **Implementation Details:**

#### **`detect_unmatched_names()`** (to implement)
```r
detect_unmatched_names(transcript_data, roster_data, name_mappings)
```
- **Input**: Transcript data, roster data, name mappings
- **Output**: List of unmatched names (real names, only if privacy = "none")
- **Features**: Identifies names needing manual mapping

#### **`safe_name_matching_workflow()`** (to implement)
```r
safe_name_matching_workflow(transcript_file_path, roster_data, privacy_level = "mask")
```
- **Input**: Transcript file, roster, privacy level
- **Output**: Processed data with privacy applied
- **Features**: 
  - Automatic two-pass processing
  - Safe user prompting when needed
  - Privacy validation at each step
  - Clear guidance for manual updates

### **User Experience:**
```
1. User configures behavior (optional):
   set_privacy_defaults(unmatched_names_action = "warn")  # override default

2. User runs normal workflow:
   result <- safe_name_matching_workflow(transcript_file, roster_data)

3. If all names match → complete (privacy maintained)

4. If unmatched names found (behavior depends on configuration):
   
   Action = "stop" (default):
   - Error: "Unmatched names found. Stopping for user intervention."
   - User must manually resolve before continuing
   - Maximum privacy protection
   
   Action = "warn":
   - Warning: "Some names need matching. Privacy temporarily disabled."
   - Show: "Unmatched names: Dr. Smith, Tom, Guest1"
   - Guidance: "Update section_names_lookup.csv with these mappings"
   - User updates file
   - Re-run automatically with privacy re-enabled

5. Final output: Privacy-masked results

6. User can suppress warnings if needed:
   suppressWarnings({
     result <- safe_name_matching_workflow(transcript_file, roster_data)
   })
```

### **Privacy Guarantees:**
- ✅ Real names only shown when explicitly needed for matching
- ✅ Privacy warnings when temporarily disabled
- ✅ Automatic re-enabling of privacy after matching
- ✅ Final outputs always privacy-compliant
- ✅ Clear audit trail of privacy state changes

## 🛡️ **Enhanced Privacy Controls**

### **Memory-Only Processing**
- Real names only exist in function scope
- No real names stored in global variables
- **Explicit cleanup** of real names from memory after processing

### **Output Validation**
- **Privacy validation function** that scans all outputs to ensure no real names appear
- All outputs validated for privacy compliance
- Privacy level enforcement at **final boundaries only** (confirmed from documentation)

### **Error Handling**
- If privacy validation fails (real names detected) and privacy is not set to "none", **stop processing with error**
- Clear error messages explaining privacy violation
- **No fallback to unmasked outputs** - privacy validation failures indicate bugs in our code, not user errors
- Privacy validation failures should be treated as critical bugs requiring immediate fix

### **User Prompting for Name Matching**
- **Prompt user for name matching** if first matching run generates exceptions
- **Warning if privacy is not set to "none"** to prevent inadvertent information leakage
- **Use existing `make_blank_section_names_lookup_csv()` function** to create template
- **Enhance `write_section_names_lookup()` function** to save matches and mismatches with instructions
- Clear guidance on updating `section_names_lookup.csv`
- Safe workflow that maintains privacy during manual matching process

### **Memory Management**
- **Use `rm()` for explicit cleanup** (confirmed as R best practice)
- Remove real name variables from function scope after processing
- Clear sensitive data from memory immediately after use

### **FERPA Compliance**
- Real names only in memory during processing
- No real names in logs, outputs, or exported files
- Consistent hashing for cross-session matching
- Privacy levels control final output format

## 🧪 **Testing Strategy**

### **Unit Tests**
- **File**: `tests/testthat/test-hash_name_consistently.R`
- **Coverage**: Name normalization, hashing consistency, edge cases

### **Integration Tests**
- **File**: `tests/testthat/test-match_names_with_privacy.R`
- **Coverage**: End-to-end matching workflow, privacy validation

### **Privacy Tests**
- **File**: `tests/testthat/test-privacy-compliance.R`
- **Coverage**: FERPA compliance, no real names in outputs

### **Real-World Tests**
- **File**: `scripts/real_world_testing/test_name_matching.R`
- **Coverage**: Actual transcript data, performance validation

## 🔒 **Privacy & Security Considerations**

### **FERPA Compliance**
- Real names only in memory during processing
- No real names in logs, outputs, or exported files
- Consistent hashing for cross-session matching
- Privacy levels control final output format

### **Security Measures**
- Salted hashing for name consistency
- No plaintext name storage in outputs
- Validation to ensure privacy compliance
- Clear privacy boundaries in code

## 📈 **Success Criteria**

### **Functional Requirements**
- [ ] Names can be matched across sessions with variations
- [ ] Privacy masking works correctly in all outputs
- [ ] Instructor identification works via `participant_type`
- [ ] Guest labeling works per session
- [ ] Name evolution tracking within sessions

### **Technical Requirements**
- [ ] All tests pass (including new privacy tests)
- [ ] No real names appear in final outputs
- [ ] Performance impact is acceptable (<10% overhead)
- [ ] Backward compatibility maintained where possible

### **User Experience Requirements**
- [ ] Clear workflow documentation
- [ ] Simple name mapping process
- [ ] Helpful error messages for mismatches
- [ ] Privacy validation feedback

### **Privacy Requirements** ⚠️ **CRITICAL**
- [ ] Real names NEVER appear in outputs, even with complete mappings
- [ ] All outputs validated for privacy compliance
- [ ] Memory-only processing of real names
- [ ] Automatic cleanup of real names from memory

## 🚀 **Implementation Timeline**

### **Week 1: Core Infrastructure**
- [x] Day 1: Complete `hash_name_consistently()` function
- [ ] Day 2: Implement `validate_privacy_compliance()` function
- [ ] Day 3: Implement `prompt_name_matching()` function
- [ ] Day 4: Create `process_transcript_with_privacy()` function

### **Week 2: Integration & Testing**
- [ ] Day 5: Implement `match_names_with_privacy()` function
- [ ] Day 6: Modify `make_clean_names_df()` to use new matching
- [ ] Day 7: **Enhance `write_section_names_lookup()`** with instructions
- [ ] Day 8: Update `ensure_privacy()` for consistent hashing
- [ ] Day 9: Create comprehensive test suite

### **Week 3: Documentation & Validation**
- [ ] Day 10: Update vignettes and templates
- [ ] Day 11: Update README and documentation
- [ ] Day 12: Final testing and validation

## ⚠️ **Risks & Mitigation**

### **Technical Risks**
- **Risk**: Performance impact of hashing
- **Mitigation**: Profile and optimize, use efficient algorithms

- **Risk**: Breaking existing functionality
- **Mitigation**: Comprehensive testing, backward compatibility

### **Privacy Risks**
- **Risk**: Real names accidentally exposed
- **Mitigation**: Multiple validation layers, clear privacy boundaries

- **Risk**: Hash collisions
- **Mitigation**: Use secure hashing, validate uniqueness

### **User Experience Risks**
- **Risk**: Complex workflow for users
- **Mitigation**: Clear documentation, simple examples

## 📝 **Next Steps**

1. **Review this plan** with stakeholders
2. **Approve implementation approach**
3. **Begin Phase 1 implementation**
4. **Regular progress updates**
5. **Final validation and testing**

## 🔗 **Related Issues**

- **Issue #129**: Real-world testing (dependency)
- **Issue #126**: FERPA compliance (foundation)
- **Issue #130**: Function documentation (will update)

---

**Status**: Plan ready for review  
**Created**: 2025-08-12  
**Author**: AI Assistant  
**Review Required**: User approval before implementation
