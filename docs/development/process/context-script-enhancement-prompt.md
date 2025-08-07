# Context Script Enhancement Prompt
*Enhance save-context script to update PROJECT.md metrics and status*

**Issue**: #141 - Enhance save-context script to update PROJECT.md metrics and status  
**Branch**: `feature/enhance-context-update-script`  
**Priority**: HIGH - PROJECT.md is severely out of date and misleading

---

## 🚨 **Problem Statement**

PROJECT.md is the primary project status document but is severely out of date and misleading:

### **Critical Discrepancies**
- **Test Coverage**: Claims 78.15% but actual is **93.82%** ✅
- **Test Suite**: Claims 450 tests but actual is **1065 tests** ✅  
- **R CMD Check**: Claims 3 notes but actual is **2 notes** ✅
- **Issue Count**: Claims 31 issues but actual is **37 issues**
- **Status**: Claims 'CRITICAL BLOCKERS' but tests are **PASSING**
- **Last Updated**: 2025-08-04 (outdated metrics from July)

### **Script Limitations**
The current `save-context.sh --update-sections` only updates:
- `### What Needs Work` section
- `### 🔄 **Remaining Issues` section

**It does NOT update:**
- Test coverage metrics
- Test suite counts  
- R CMD check notes
- Overall status assessment
- Issue count claims
- Last updated date

---

## 🎯 **Solution Requirements**

### **Phase 1: Manual PROJECT.md Update**
1. **Update Current Status Section** (lines 15-40)
   - Change status from "CRITICAL BLOCKERS" to "EXCELLENT - Very Close to CRAN Ready"
   - Update test coverage from 78.15% to 93.82%
   - Update test suite from 450 to 1065 tests
   - Update R CMD check from 3 to 2 notes
   - Update last modified date to 2025-08-07

2. **Update Issue Sections** (lines 41-140)
   - Remove closed issues (#113, #77)
   - Update issue count from 31 to 37
   - Update priorities to match GitHub reality
   - Add missing issues

3. **Update Status Assessment**
   - Change timeline from "3+ weeks" to "1-2 weeks"
   - Change confidence from "LOW" to "HIGH"
   - Update CRAN readiness assessment

### **Phase 2: Script Enhancement**
Enhance `scripts/save-context.sh --update-sections` to:

1. **Pull Current Metrics from R Context**
   ```bash
   # Extract metrics from R context output
   COVERAGE=$(grep "Coverage:" .cursor/r-context.md | awk '{print $2}')
   TESTS=$(grep "tests passing" .cursor/full-context.md | awk '{print $1}')
   RCMD_NOTES=$(grep "R CMD Check:" .cursor/full-context.md | grep -o "[0-9] notes")
   ```

2. **Update All Metric Sections**
   - Test coverage line (line 39)
   - Test suite line (line 37)
   - R CMD check line (line 38)
   - Overall status line (line 15)
   - Last updated date (line 13)

3. **Integrate with GitHub CLI**
   - Get accurate issue counts
   - Get current issue priorities
   - Update issue sections automatically

4. **Add New Update Function**
   ```bash
   update_project_metrics() {
       # Extract metrics from context files
       # Update PROJECT.md with current values
       # Update last modified date
   }
   ```

---

## 📋 **Implementation Plan**

### **Step 1: Manual PROJECT.md Update**
- [ ] Update current status and metrics
- [ ] Update issue sections
- [ ] Update timeline and confidence
- [ ] Test that PROJECT.md is accurate

### **Step 2: Script Enhancement**
- [ ] Add `update_project_metrics()` function
- [ ] Integrate with R context extraction
- [ ] Add GitHub CLI integration
- [ ] Update section detection patterns
- [ ] Add error handling and validation

### **Step 3: Testing and Validation**
- [ ] Test enhanced script with `--update-sections`
- [ ] Verify all sections are updated correctly
- [ ] Validate metrics are accurate
- [ ] Test error handling

### **Step 4: Documentation**
- [ ] Update script documentation
- [ ] Add usage examples
- [ ] Document new functionality

---

## 🔧 **Technical Details**

### **Current Script Structure**
```bash
# scripts/save-context.sh
update_project_sections() {
    # Only updates issue sections
    # Uses GitHub CLI for issue data
    # Limited to 2 sections
}
```

### **Enhanced Script Structure**
```bash
# scripts/save-context.sh
update_project_sections() {
    # Updates issue sections (existing)
    update_project_metrics() {
        # NEW: Update metrics sections
        # Extract from R context
        # Update PROJECT.md
    }
    update_project_status() {
        # NEW: Update status assessment
        # Update confidence and timeline
    }
}
```

### **Section Detection Patterns**
```bash
# Current patterns
/^### What Needs Work/
/^### 🔄 \*\*Remaining Issues/

# New patterns needed
/^## Current Status/
/^### What's Working/
/^.*Test Coverage.*%/
/^.*Test Suite.*tests/
/^.*R CMD Check.*notes/
```

---

## 📊 **Expected Results**

### **Before Enhancement**
- PROJECT.md claims 78.15% coverage (wrong)
- PROJECT.md claims 450 tests (wrong)
- PROJECT.md claims "CRITICAL BLOCKERS" (wrong)
- Manual updates required

### **After Enhancement**
- PROJECT.md shows 93.82% coverage (correct)
- PROJECT.md shows 1065 tests (correct)
- PROJECT.md shows "EXCELLENT - Very Close to CRAN Ready" (correct)
- Automated updates via script

---

## 🎯 **Success Criteria**

- [ ] PROJECT.md reflects current metrics accurately
- [ ] Enhanced script updates all relevant sections
- [ ] Script pulls metrics from R context automatically
- [ ] Script updates GitHub issue counts accurately
- [ ] Script updates last modified date
- [ ] No manual intervention required for metric updates
- [ ] Documentation updated for new functionality

---

## 📚 **Context Files**

### **Essential Files to Review**
- `PROJECT.md` - Current outdated status document
- `scripts/save-context.sh` - Script to enhance
- `scripts/context-for-new-chat.R` - Source of current metrics
- `.cursor/full-context.md` - Current accurate metrics
- `scripts/get-context.sh` - Context generation script

### **Current Metrics (from full-context.md)**
- Test Coverage: 93.82%
- Test Suite: 1065 tests passing, 0 failures
- R CMD Check: 0 errors, 0 warnings, 2 notes
- Exported Functions: 40
- Open Issues: 37

---

## 🚀 **Next Steps**

1. **Start with manual PROJECT.md update** to get accurate baseline
2. **Enhance save-context script** to automate future updates
3. **Test and validate** the enhanced functionality
4. **Document changes** for future maintenance

**Goal**: Make PROJECT.md the single, accurate source of truth for project status that updates automatically with context generation.

---

## 💡 **Key Insights**

- The package is actually in much better shape than PROJECT.md suggests
- Current test status is EXCELLENT (1065 passing, 93.82% coverage)
- Main blockers are privacy/ethical implementation, not technical issues
- Automated updates will prevent future discrepancies
- This work is critical for accurate CRAN submission planning 