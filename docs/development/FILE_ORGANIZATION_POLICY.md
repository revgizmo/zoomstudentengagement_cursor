
# File Organization Policy

## Root Level Files
Only the following files should be at the root level:
- Essential package files (DESCRIPTION, NAMESPACE, LICENSE, etc.)
- Essential project files (README.md, PROJECT.md, etc.)
- Package directories (R/, man/, inst/, tests/, vignettes/)
- Configuration files (.Rbuildignore, .gitignore, etc.)

## Development Documentation
All development documentation should be organized in appropriate subdirectories:

### docs/development/
- Implementation guides (*_IMPLEMENTATION_GUIDE.md)
- Consolidated plans (*_CONSOLIDATED_PLAN.md)
- Completion summaries (*_COMPLETION_SUMMARY.md)
- Assessments (*_ASSESSMENT.md)
- Other development files

### docs/analysis/
- Analysis reports (*_ANALYSIS_REPORT.md)
- Verification reports (*_VERIFICATION_REPORT.md)
- Investigation reports (*_INVESTIGATION_REPORT.md)
- Lessons learned (*_LESSONS_LEARNED.md)

## Prevention Measures
1. Run this script before committing changes
2. Use proper directory structure for new files
3. Update references when moving files
4. Add new directories to .Rbuildignore as needed

## Automated Checks
This script should be run:
- Before creating pull requests
- As part of CI/CD pipeline
- During regular maintenance

