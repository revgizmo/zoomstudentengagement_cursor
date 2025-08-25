# Development Scripts

This directory contains utility scripts for development and project management.

## 🎯 **Quick Start - Most Common Commands**

### For Getting Current Status (RECOMMENDED)
```bash
# Save context to files for linking in Cursor
./scripts/save-context.sh

# Then link in Cursor with: @full-context.md
```

### For New Cursor Chats
```bash
# Generate context for copying to new chat
./scripts/context-for-new-chat.sh
```

### Before Creating PRs
```bash
# Run comprehensive validation
Rscript scripts/pre-pr-validation.R
```

## Context Scripts for Cursor

### `save-context.sh` ⭐ **RECOMMENDED**
**Purpose**: Save context output to files for linking in Cursor chats

**Usage**:
```bash
# Save context to files
./scripts/save-context.sh

# Then link in Cursor:
# @context.md - Shell context
# @r-context.md - R-specific context  
# @full-context.md - Combined context (RECOMMENDED)
```

**Why This is Best**: 
- Saves context to files you can link with `@full-context.md`
- Includes backups and validation
- Perfect for ongoing development work
- No need to copy/paste - just link the file

**Creates**:
- `.cursor/context.md` - Shell context
- `.cursor/r-context.md` - R-specific context
- `.cursor/full-context.md` - Combined context (use this one!)
- `.cursor/context_YYYYMMDD_HHMMSS.md` - Timestamped version

### `context-for-new-chat.sh`
**Purpose**: Generate comprehensive project context for new Cursor chats

**Usage**:
```bash
# Generate context
./scripts/context-for-new-chat.sh

# Copy output to new Cursor chat
```

**When to Use**: 
- Starting a completely new Cursor chat
- Need to copy/paste context into chat
- Don't need persistent context files

**Provides**:
- Project status and metrics
- Current GitHub issues and priorities
- Development workflow and conventions
- CRAN readiness status
- Next steps and immediate priorities

### `context-for-new-chat.R`
**Purpose**: Generate R-specific context for new Cursor chats

**Usage**:
```bash
# Generate R-specific context
Rscript scripts/context-for-new-chat.R

# Copy output to new Cursor chat
```

**When to Use**:
- Need detailed R package information
- Debugging R-specific issues
- Want to see package structure and dependencies

**Provides**:
- Package loading status
- Test results and coverage
- Package structure and dependencies
- Exported functions
- Common issues and solutions
- Development tips

### Combined Usage
For complete context, run both scripts:
```bash
./scripts/context-for-new-chat.sh && Rscript scripts/context-for-new-chat.R
```

### `get-context.sh`
**Purpose**: Run both context scripts in sequence

**Usage**:
```bash
# Get complete context
./scripts/get-context.sh
```

## Pre-PR Validation

### `pre-pr-validation.R` ⭐ **ALWAYS RUN BEFORE PRs**
**Purpose**: Comprehensive validation before creating pull requests

**Usage**:
```bash
# Run validation
Rscript scripts/pre-pr-validation.R
```

**Checks**:
- Code formatting with styler
- Documentation completeness
- Test execution
- R CMD check
- Spell checking
- Coverage analysis

**Why This is Critical**:
- Catches issues that would fail in CI/CD
- Ensures CRAN compliance
- Validates all documentation
- Runs full package check

## Real-World Testing

### `real_world_testing/`
**Purpose**: Testing infrastructure for confidential data validation

**Contents**:
- `run_real_world_tests.R` - Main testing script
- `run_tests.sh` - Test runner script
- `real_world_test_plan.md` - Comprehensive testing plan
- `README.md` - Testing documentation

**Usage**:
```bash
# Set up testing environment (see real_world_testing/README.md)
cd zoom_real_world_testing
./run_tests.sh
```

## 🚀 **Development Workflow**

### Daily Development
1. **Get current status**: `./scripts/save-context.sh`
2. **Link context**: Use `@full-context.md` in Cursor
3. **Make changes and test**: `Rscript scripts/pre-pr-validation.R`
4. **Create PR**: Use GitHub CLI or web interface

### New Chat Setup
1. **Generate context**: `./scripts/context-for-new-chat.sh`
2. **Copy output** to new Cursor chat
3. **Start development work**

### Before PR Creation
1. **Run validation**: `Rscript scripts/pre-pr-validation.R`
2. **Fix any issues** that come up
3. **Create PR** only after all checks pass

## Quick Reference

### Essential Commands
```bash
# Get project status (RECOMMENDED)
./scripts/save-context.sh

# Generate context for new chat
./scripts/context-for-new-chat.sh

# Validate before PR
Rscript scripts/pre-pr-validation.R

# Check current issues
gh issue list --limit 10

# View specific issue
gh issue view <ISSUE_NUMBER>
```

### Context Templates
For quick context, copy and paste:

```markdown
## Project Context: zoomstudentengagement R Package

**Current Status**: EXCELLENT - Very Close to CRAN Ready
**Goal**: CRAN submission preparation
**Test Status**: 0 failures, 453 tests passing
**Coverage**: 83.41% (target: 90%)
**R CMD Check**: 0 errors, 0 warnings, 3 notes

**Key Files to Review**:
- README.md - Package overview
- PROJECT.md - Current status and CRAN readiness
- docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md - Issue workflow
- CONTRIBUTING.md - Contribution guidelines

**Current Priorities**:
1. Test coverage improvement (83.41% → 90%)
2. Test warnings cleanup (29 warnings)
3. R CMD check notes resolution
4. Real-world testing with confidential data
5. FERPA/Security compliance review
```

## 📚 **Documentation**

For detailed information about using context scripts with Cursor, see:
- [Cursor Integration Guide](../docs/development/CURSOR_INTEGRATION.md)
- [Issue Management Quick Reference](../docs/development/ISSUE_MANAGEMENT_QUICK_REFERENCE.md)
- [Real-World Testing Guide](../zoom_real_world_testing/README.md)

## 💡 **Pro Tips**

1. **Use `save-context.sh` for ongoing work** - Link with `@full-context.md`
2. **Use `context-for-new-chat.sh` for new chats** - Copy/paste output
3. **Always run `pre-pr-validation.R` before PRs** - Catches issues early
4. **Keep context files updated** - Run `save-context.sh` after major changes
5. **Link context files in Cursor** - Much easier than copying/pasting 
