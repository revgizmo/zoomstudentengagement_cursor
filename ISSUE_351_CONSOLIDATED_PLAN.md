# Issue #351 Consolidated Plan: Fix yt-dlp Executable File CRAN Warning

## 📋 **Issue Overview**
- **Issue Number**: #351
- **Title**: fix(cran): remove yt-dlp executable file causing R CMD check warning
- **Priority**: HIGH
- **Type**: CRAN submission blocker
- **Created**: 2025-08-22
- **Status**: OPEN

## 🎯 **Problem Statement**
The `yt-dlp` executable file was added to the repository root in commit 7193f94 (2025-08-21) and is causing an R CMD check WARNING:

```
❯ checking for executable files ... WARNING
  Found the following executable file:
    yt-dlp
  Source packages should not contain undeclared executable files.
  See section 'Package structure' in the 'Writing R Extensions' manual.
```

## 📊 **Current Impact**
- **CRAN Compliance**: This warning will prevent CRAN submission
- **Package Quality**: R CMD check should pass with 0 warnings for CRAN
- **Current Status**: 1 WARNING, 2 NOTES (was previously 0 warnings)
- **Files Affected**: 
  - `yt-dlp` (executable file in root)
  - `inst/extdata/public_transcripts/download_public_vtts.sh` (references yt-dlp)

## 🔍 **Root Cause Analysis**
- **Source**: Added in commit 7193f94 for public transcript downloads
- **Location**: Repository root (incorrect location for R package)
- **Purpose**: Used by `download_public_vtts.sh` script for downloading VTT files
- **Issue**: Executable files in root violate CRAN package structure requirements

## 🎯 **Solution Strategy**

### **Option 1: Move to inst/extdata/ (RECOMMENDED)**
- **Action**: Move `yt-dlp` to `inst/extdata/public_transcripts/`
- **Pros**: Maintains functionality, follows R package conventions
- **Cons**: None
- **Implementation**: Simple file move + update script path

### **Option 2: Add to .Rbuildignore**
- **Action**: Add `^yt-dlp$` to `.Rbuildignore`
- **Pros**: Quick fix, excludes from package build
- **Cons**: Breaks functionality, script won't work
- **Implementation**: Add one line to .Rbuildignore

### **Option 3: Remove entirely**
- **Action**: Delete `yt-dlp` and update documentation
- **Pros**: Clean solution, no executable files
- **Cons**: Breaks functionality, requires user to install yt-dlp separately
- **Implementation**: Delete file + update documentation

## ✅ **Recommended Solution: Option 1**

### **Implementation Steps**
1. **Move executable**: `git mv yt-dlp inst/extdata/public_transcripts/`
2. **Update script**: Modify `download_public_vtts.sh` to use relative path
3. **Test functionality**: Verify script still works
4. **Verify CRAN compliance**: Run `devtools::check()` to confirm 0 warnings
5. **Update documentation**: Update README if needed

### **Success Criteria**
- [ ] `yt-dlp` moved to `inst/extdata/public_transcripts/`
- [ ] `download_public_vtts.sh` updated to use correct path
- [ ] Script functionality verified
- [ ] R CMD check passes with 0 warnings
- [ ] CRAN compliance restored

## 🔧 **Technical Requirements**

### **File Changes**
- **Move**: `yt-dlp` → `inst/extdata/public_transcripts/yt-dlp`
- **Update**: `inst/extdata/public_transcripts/download_public_vtts.sh`
- **Verify**: `.Rbuildignore` (no changes needed)

### **Script Updates**
- **Current**: `require_tool yt-dlp` (assumes PATH)
- **New**: Use relative path `./yt-dlp` or `$(dirname "$0")/yt-dlp`

### **Testing Requirements**
- [ ] `devtools::check()` passes with 0 warnings
- [ ] `download_public_vtts.sh` executes successfully
- [ ] VTT download functionality works
- [ ] No regression in existing functionality

## 📅 **Timeline**
- **Phase 1**: Implementation (30 minutes)
- **Phase 2**: Testing and verification (15 minutes)
- **Phase 3**: Documentation updates (5 minutes)
- **Total**: ~1 hour

## 🚨 **Risk Assessment**
- **Risk Level**: LOW
- **Potential Issues**: Script path resolution, functionality breakage
- **Mitigation**: Thorough testing, backup original file
- **Rollback**: Simple file move back to root

## 📚 **Documentation Updates**
- **README**: Update if script usage instructions exist
- **Comments**: Update script comments if needed
- **Issue**: Mark as resolved with verification steps

## ✅ **Verification Checklist**
- [ ] `yt-dlp` no longer in repository root
- [ ] `yt-dlp` present in `inst/extdata/public_transcripts/`
- [ ] `download_public_vtts.sh` updated with correct path
- [ ] Script executes without errors
- [ ] `devtools::check()` shows 0 warnings
- [ ] CRAN compliance restored
- [ ] Issue #351 marked as resolved

## 🎯 **Success Metrics**
- **Primary**: R CMD check passes with 0 warnings
- **Secondary**: Script functionality maintained
- **Tertiary**: CRAN submission readiness restored

---

**Last Updated**: 2025-08-22  
**Status**: Ready for implementation  
**Priority**: HIGH (CRAN submission blocker)
