# Development Scripts

This directory contains utility scripts for development and project management.

## Context Scripts for Cursor

### `context-for-new-chat.sh`
**Purpose**: Generate comprehensive project context for new Cursor chats

**Usage**:
```bash
# Make executable (first time only)
chmod +x scripts/context-for-new-chat.sh

# Generate context
./scripts/context-for-new-chat.sh

# Copy output to new Cursor chat
```

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

### `save-context.sh`
**Purpose**: Save context output to files for linking in Cursor chats

**Usage**:
```bash
# Save context to files
./scripts/save-context.sh

# Then link in Cursor:
# @context.md - Shell context
# @r-context.md - R-specific context  
# @full-context.md - Combined context
```

**Creates**:
- `.cursor/context.md` - Shell context
- `.cursor/r-context.md` - R-specific context
- `.cursor/full-context.md` - Combined context
- `.cursor/context_YYYYMMDD_HHMMSS.md` - Timestamped version

## Pre-PR Validation

### `pre-pr-validation.R`
**Purpose**: Comprehensive validation before creating pull requests

**Usage**:
```r
source("scripts/pre-pr-validation.R")
```

**Checks**:
- Code formatting with styler
- Documentation completeness
- Test execution
- R CMD check
- Spell checking
- Coverage analysis

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

## Quick Reference

### Common Commands
```bash
# Get project context
./scripts/context-for-new-chat.sh

# Get R-specific context
Rscript scripts/context-for-new-chat.R

# Run pre-PR validation
Rscript -e "source('scripts/pre-pr-validation.R')"

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
- ISSUE_MANAGEMENT_QUICK_REFERENCE.md - Issue workflow
- CONTRIBUTING.md - Contribution guidelines

**Current Priorities**:
1. Test coverage improvement (83.41% → 90%)
2. Test warnings cleanup (29 warnings)
3. R CMD check notes resolution
4. Real-world testing with confidential data
5. FERPA/Security compliance review
```

## Documentation

For detailed information about using context scripts with Cursor, see:
- [Cursor Integration Guide](../docs/development/CURSOR_INTEGRATION.md)
- [Issue Management Quick Reference](../ISSUE_MANAGEMENT_QUICK_REFERENCE.md)
- [Real-World Testing Guide](../zoom_real_world_testing/README.md) 