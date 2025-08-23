# Issue #351 Implementation Guide: Fix yt-dlp Executable File CRAN Warning

## 🎯 **Mission**
Fix the R CMD check WARNING caused by `yt-dlp` executable file in repository root by moving it to the appropriate location and updating the script that uses it.

## 📋 **Prerequisites**
- Git repository access
- R development environment
- Basic shell scripting knowledge

## 🔧 **Step-by-Step Implementation**

### **Step 1: Create Feature Branch**
```bash
# Create new branch for this work
git checkout -b feature/issue-351-fix-yt-dlp-executable
git push -u origin feature/issue-351-fix-yt-dlp-executable
```

### **Step 2: Verify Current State**
```bash
# Check current R CMD check status
Rscript -e "devtools::check()" 2>&1 | grep -E "(WARNING|NOTE|ERROR)"

# Verify yt-dlp location and permissions
ls -la yt-dlp
ls -la inst/extdata/public_transcripts/
```

**Expected Output**: Should show 1 WARNING for yt-dlp executable file

### **Step 3: Move yt-dlp to Correct Location**
```bash
# Move yt-dlp to inst/extdata/public_transcripts/
git mv yt-dlp inst/extdata/public_transcripts/

# Verify move was successful
ls -la inst/extdata/public_transcripts/yt-dlp
ls -la yt-dlp  # Should show "No such file or directory"
```

### **Step 4: Update Script Path**
```bash
# Edit the download script to use relative path
# File: inst/extdata/public_transcripts/download_public_vtts.sh

# Find the current require_tool line:
# require_tool yt-dlp

# Replace with:
# require_tool "$(dirname "$0")/yt-dlp"
```

**Script Update Details**:
- **Current**: `require_tool yt-dlp` (assumes yt-dlp in PATH)
- **New**: `require_tool "$(dirname "$0")/yt-dlp"` (uses relative path)

### **Step 5: Test Script Functionality**
```bash
# Navigate to the script directory
cd inst/extdata/public_transcripts/

# Test script execution (dry run)
./download_public_vtts.sh

# Check if yt-dlp is found correctly
./yt-dlp --version
```

**Success Criteria**: Script should find yt-dlp and execute without errors

### **Step 6: Verify CRAN Compliance**
```bash
# Return to repository root
cd ../../../

# Run R CMD check
Rscript -e "devtools::check()" 2>&1 | grep -E "(WARNING|NOTE|ERROR)"
```

**Expected Output**: Should show 0 WARNINGS (only NOTES remain)

### **Step 7: Test Package Installation**
```bash
# Test package installation
Rscript -e "devtools::install()"

# Verify package loads correctly
Rscript -e "library(zoomstudentengagement); cat('Package loaded successfully\n')"
```

### **Step 8: Commit Changes**
```bash
# Add all changes
git add .

# Commit with descriptive message
git commit -m "fix(cran): move yt-dlp executable to inst/extdata/public_transcripts/

- Move yt-dlp from repository root to inst/extdata/public_transcripts/
- Update download_public_vtts.sh to use relative path
- Fixes R CMD check WARNING for undeclared executable files
- Maintains functionality while following R package conventions
- Resolves Issue #351 - CRAN submission blocker

Verification:
- R CMD check passes with 0 warnings
- Script functionality preserved
- Package installation and loading verified"

# Push changes
git push origin feature/issue-351-fix-yt-dlp-executable
```

### **Step 9: Create Pull Request**
```bash
# Create pull request
gh pr create \
  --title "fix(cran): move yt-dlp executable to fix R CMD check warning" \
  --body "## Problem
Fixes Issue #351: yt-dlp executable file in repository root causing R CMD check WARNING.

## Solution
- Move yt-dlp from repository root to inst/extdata/public_transcripts/
- Update download_public_vtts.sh to use relative path
- Maintains functionality while following R package conventions

## Changes
- Moved: yt-dlp → inst/extdata/public_transcripts/yt-dlp
- Updated: inst/extdata/public_transcripts/download_public_vtts.sh
- Fixed: R CMD check WARNING for undeclared executable files

## Verification
- [x] R CMD check passes with 0 warnings
- [x] Script functionality preserved
- [x] Package installation and loading verified
- [x] CRAN compliance restored

## Impact
- **CRAN Compliance**: ✅ Restored (0 warnings)
- **Functionality**: ✅ Preserved
- **Package Quality**: ✅ Improved

Closes #351" \
  --label "priority:high" \
  --label "area:core" \
  --label "CRAN:submission"
```

### **Step 10: Final Verification**
```bash
# Run comprehensive checks
Rscript -e "devtools::check()"
Rscript -e "devtools::test()"
Rscript -e "covr::package_coverage()"

# Verify script still works
cd inst/extdata/public_transcripts/
./download_public_vtts.sh --help || echo "Script test completed"
cd ../../../
```

## ✅ **Success Criteria Checklist**

### **Technical Requirements**
- [ ] `yt-dlp` moved from root to `inst/extdata/public_transcripts/`
- [ ] `download_public_vtts.sh` updated to use relative path
- [ ] Script executes without errors
- [ ] R CMD check passes with 0 warnings
- [ ] Package installs and loads correctly

### **CRAN Compliance**
- [ ] No executable files in repository root
- [ ] R CMD check shows 0 warnings
- [ ] Package structure follows R conventions
- [ ] All functionality preserved

### **Documentation**
- [ ] Commit message explains changes clearly
- [ ] Pull request description comprehensive
- [ ] Issue #351 can be marked as resolved

## 🚨 **Troubleshooting**

### **Script Path Issues**
If script can't find yt-dlp:
```bash
# Check if yt-dlp is executable
ls -la inst/extdata/public_transcripts/yt-dlp

# Make executable if needed
chmod +x inst/extdata/public_transcripts/yt-dlp

# Test path resolution
cd inst/extdata/public_transcripts/
./yt-dlp --version
```

### **R CMD Check Still Shows Warning**
If warning persists:
```bash
# Check if yt-dlp still exists in root
ls -la yt-dlp

# Verify git mv was successful
git status

# Check .Rbuildignore for any yt-dlp entries
grep -i yt-dlp .Rbuildignore
```

### **Script Functionality Broken**
If script doesn't work:
```bash
# Test yt-dlp directly
cd inst/extdata/public_transcripts/
./yt-dlp --version

# Check script syntax
bash -n download_public_vtts.sh

# Debug script execution
bash -x download_public_vtts.sh
```

## 📚 **Additional Notes**

### **Why This Solution Works**
- **R Package Conventions**: Executable files belong in `inst/` directory
- **Functionality Preserved**: Script still works with relative path
- **CRAN Compliance**: No executable files in root directory
- **Maintainability**: Clear organization following R package standards

### **Alternative Solutions Considered**
1. **Add to .Rbuildignore**: Would break functionality
2. **Remove entirely**: Would require users to install yt-dlp separately
3. **Move to scripts/**: Not appropriate for package data

### **Future Considerations**
- Consider documenting yt-dlp requirement in package documentation
- May want to add yt-dlp installation instructions for users
- Consider if yt-dlp is essential for package functionality

---

**Implementation Time**: ~1 hour  
**Risk Level**: LOW  
**Success Probability**: HIGH
