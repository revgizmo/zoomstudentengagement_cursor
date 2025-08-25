# Issue #351 Investigation and Planning: yt-dlp and Public Transcripts Work

## 🔍 **Investigation Summary**

### **What Happened**
The `yt-dlp` executable and public transcript infrastructure was added to the repository in commit `7193f94` (2025-08-21) with the message "Add public course transcripts and download script". This work was intended to provide test data from public course transcripts (Harvard CS50, MIT OCW, Stanford) for the package.

### **Original Intent**
Based on the commit and documentation:
- **Goal**: Provide real VTT transcripts from public multi-session courses for internal testing
- **Sources**: Harvard CS50, MIT OCW, Stanford Online (YouTube-based courses)
- **Rationale**: Use public course caption files as internal test examples while respecting licenses
- **Approach**: Download VTT captions using yt-dlp for representative lectures

### **What Was Added**
1. **yt-dlp executable** (3MB binary) - placed in repository root
2. **download_public_vtts.sh** - script to fetch VTT captions from YouTube
3. **verify_public_transcripts.R** - R script to parse/verify transcripts
4. **sources.csv** - metadata about course sources and licenses
5. **README.md** - documentation for the public transcript system

### **Current State**
- **yt-dlp**: Currently moved to `inst/extdata/public_transcripts/` (partially implemented fix)
- **No actual VTT files**: The directories are empty, no transcripts were ever downloaded
- **CRAN Warning**: Still present due to yt-dlp executable in package
- **Functionality**: Never actually used or tested

## 🚨 **Key Problems Identified**

### **1. Scope Mismatch**
- **Package Purpose**: Zoom transcript analysis for student engagement
- **Added Content**: General VTT files from YouTube courses (not Zoom)
- **Fundamental Issue**: These are not Zoom transcripts, they're YouTube captions

### **2. CRAN Compliance Issues**
- **Executable in Package**: yt-dlp binary violates CRAN policies
- **Size Impact**: 3MB binary adds unnecessary bloat
- **Dependency**: Creates external dependency on YouTube infrastructure

### **3. Privacy and Ethical Concerns**
- **Data Source**: YouTube captions may not represent real educational scenarios
- **Consent**: No clear consent mechanism for using course content
- **FERPA Compliance**: Not relevant to actual Zoom educational data

### **4. Technical Debt**
- **Unused Infrastructure**: Complex system that was never utilized
- **Maintenance Burden**: Requires ongoing maintenance of yt-dlp and scripts
- **Testing Complexity**: Adds external dependencies to testing

## 📋 **What Needs to Be Removed**

### **Files to Delete**
1. `inst/extdata/public_transcripts/yt-dlp` (executable)
2. `inst/extdata/public_transcripts/download_public_vtts.sh` (download script)
3. `inst/extdata/public_transcripts/verify_public_transcripts.R` (verification script)
4. `inst/extdata/public_transcripts/sources.csv` (source metadata)
5. `inst/extdata/public_transcripts/README.md` (documentation)
6. `inst/extdata/public_transcripts/` (entire directory)

### **Directories to Remove**
- `inst/extdata/public_transcripts/harvard_cs50/` (empty)
- `inst/extdata/public_transcripts/mit_ocw/` (empty)
- `inst/extdata/public_transcripts/stanford/` (empty)

## 🎯 **Updated Plan for Issue #351**

### **New Approach: Complete Removal**
Instead of moving yt-dlp to fix the CRAN warning, we should remove the entire public transcript infrastructure because:

1. **Wrong Scope**: Not Zoom transcripts, not relevant to package purpose
2. **CRAN Compliance**: Eliminates executable file issue entirely
3. **Simplification**: Removes unused complexity
4. **Focus**: Keeps package focused on actual Zoom transcript analysis

### **Implementation Steps**
1. **Remove all public transcript files and directories**
2. **Update Issue #351** to reflect the new approach
3. **Document learnings** about scope creep and CRAN compliance
4. **Verify R CMD check** passes with 0 warnings
5. **Update documentation** to clarify package scope

## 📚 **Learnings to Document**

### **Scope Management**
- **Lesson**: Stay focused on core package purpose (Zoom transcripts)
- **Action**: Establish clear scope boundaries for future development
- **Prevention**: Review all additions against package mission

### **CRAN Compliance**
- **Lesson**: Executable files in R packages require special handling
- **Action**: Always check R CMD check before committing
- **Prevention**: Add CRAN compliance checks to development workflow

### **External Dependencies**
- **Lesson**: External tools (yt-dlp) create maintenance burden
- **Action**: Prefer R-native solutions when possible
- **Prevention**: Evaluate necessity of external dependencies

### **Testing Strategy**
- **Lesson**: Use appropriate test data (Zoom transcripts, not YouTube captions)
- **Action**: Develop Zoom-specific test data strategy
- **Prevention**: Align test data with actual use cases

## 🔄 **Updated Issue #351 Plan**

### **New Title**
`fix(cran): remove yt-dlp and public transcript infrastructure (scope cleanup)`

### **New Problem Statement**
The yt-dlp executable and public transcript infrastructure was added in error - it provides YouTube captions, not Zoom transcripts, and is outside the package scope. This creates CRAN compliance issues and unnecessary complexity.

### **New Solution**
Complete removal of the public transcript infrastructure to:
- Fix CRAN compliance (remove executable)
- Restore package focus (Zoom transcripts only)
- Reduce complexity and maintenance burden
- Document learnings about scope management

### **Success Criteria**
- [ ] All public transcript files removed
- [ ] R CMD check passes with 0 warnings
- [ ] Package scope clearly documented
- [ ] Learnings documented for future reference

## 🚀 **Next Steps**

1. **Update Issue #351** with new approach
2. **Remove all public transcript files**
3. **Test R CMD check compliance**
4. **Document learnings**
5. **Create pull request with comprehensive explanation**

---

**Investigation Date**: 2025-08-22  
**Investigation By**: AI Assistant  
**Status**: Ready for implementation
