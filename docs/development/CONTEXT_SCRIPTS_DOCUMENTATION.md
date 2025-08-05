# Context Scripts Documentation

## Overview

The context scripts provide real-time project status and context for the `zoomstudentengagement` R package. These scripts are designed to give developers and contributors immediate insight into the current state of the project, including test status, CRAN readiness, and priority issues.

## Script Architecture

### 1. `scripts/context-for-new-chat.sh` - Shell Context Script

**Purpose**: Provides comprehensive shell-based project context with dynamic status checking.

**Features**:
- Dynamic status checking (no caching - always current)
- Comprehensive error handling
- Privacy/ethical compliance checks
- Progress indicators for long operations
- Validation of dependencies and files

**Usage**:
```bash
./scripts/context-for-new-chat.sh
```

**Output Sections**:
1. **Project Status Summary** - Reads from PROJECT.md
2. **Key Metrics** - Dynamic test status, R CMD check, coverage, function count
3. **Privacy & Ethical Compliance** - Checks for privacy/ethical/FERPA issues
4. **Critical Issues** - High priority GitHub issues
5. **CRAN Submission Blockers** - Issues blocking CRAN submission
6. **Recent Activity** - Latest GitHub issues
7. **Essential Files** - Key documentation files
8. **Development Focus** - Dynamic priorities based on current issues
9. **Quick Commands** - Useful commands for context
10. **Project Structure** - File counts and organization
11. **Development Workflow** - Standard workflow steps
12. **CRAN Readiness Status** - Dynamic readiness assessment
13. **Next Steps** - Actionable next steps based on current status

**Dependencies**:
- `Rscript` (required)
- `gh` (GitHub CLI, optional but recommended)
- `jq` (JSON parsing, optional but recommended)

### 2. `scripts/context-for-new-chat.R` - R Context Script

**Purpose**: Provides R-specific context and package health information.

**Features**:
- Dynamic status checking (no caching - always current)
- Comprehensive error handling with tryCatch
- Progress indicators for long operations
- Validation of package structure and dependencies
- Privacy/ethical compliance checks

**Usage**:
```bash
Rscript scripts/context-for-new-chat.R
```

**Output Sections**:
1. **Package Loading Status** - Package load success/failure
2. **Test Status** - Dynamic test results with counts
3. **Test Coverage** - Coverage percentage and low-coverage files
4. **R CMD Check Status** - Errors, warnings, notes count
5. **Package Structure** - File counts by type
6. **Exported Functions** - Function count and examples
7. **Dependencies** - Imports and suggests
8. **Documentation Status** - Documentation completeness check
9. **Privacy & Ethical Compliance** - Educational data considerations
10. **Quick Health Check Commands** - Useful R commands
11. **Common Issues and Solutions** - Troubleshooting tips
12. **Development Tips** - Best practices

**Dependencies**:
- `devtools` package (recommended)
- `covr` package (optional, for coverage)

### 3. `scripts/save-context.sh` - Context File Saver

**Purpose**: Saves context output to files for linking in Cursor chats.

**Features**:
- Validation of required scripts and dependencies
- Comprehensive error handling
- Progress indicators
- Backup of existing files
- Clean error messages

**Usage**:
```bash
./scripts/save-context.sh
```

**Output Files**:
- `.cursor/context.md` - Shell context (link with `@context.md`)
- `.cursor/r-context.md` - R-specific context (link with `@r-context.md`)
- `.cursor/full-context.md` - Combined context (link with `@full-context.md`)
- `.cursor/context_YYYYMMDD_HHMMSS.md` - Timestamped version

**Backup Files**:
- `.cursor/context_backup_YYYYMMDD_HHMMSS.md`
- `.cursor/r-context_backup_YYYYMMDD_HHMMSS.md`
- `.cursor/full-context_backup_YYYYMMDD_HHMMSS.md`

### 4. `scripts/get-context.sh` - Combined Context Script

**Purpose**: Runs both context scripts and provides clean output for Cursor chats.

**Features**:
- Validation of required scripts
- Error handling for failed script execution
- Clean output formatting
- Progress indicators

**Usage**:
```bash
./scripts/get-context.sh
```

## Privacy & Ethical Compliance

### Labels Created
- `privacy` - Privacy and data protection concerns
- `ethical` - Ethical use and equitable participation concerns
- `FERPA` - FERPA compliance and student data protection

### Existing Issues
- **Issue #84**: "Review and implement FERPA/security compliance" (labeled: privacy, FERPA)
- **Issue #85**: "Review functions for ethical use and equitable participation focus" (labeled: ethical)

### Compliance Checks
The scripts automatically check for open privacy/ethical issues and provide:
- Count of open privacy issues
- Count of open ethical issues
- Count of open FERPA issues
- References to existing compliance issues

## Error Handling

### Shell Scripts
- Use `set -eo pipefail` for error handling
- Trap errors with line number reporting
- Graceful fallbacks for missing dependencies
- Validation of required files and executables

### R Scripts
- Use `tryCatch()` for comprehensive error handling
- Suppress warnings and messages where appropriate
- Provide helpful error messages and fallback options
- Handle missing packages gracefully

## Performance Considerations

### No Caching
- Scripts always provide current information
- No stale data or outdated status
- Real-time GitHub issue fetching
- Dynamic test and coverage results

### Timeout Protection
- R CMD check limited to first 50 lines to avoid hanging
- Test execution with minimal output
- Graceful handling of long-running operations

## Usage Examples

### Quick Context Check
```bash
# Get shell context only
./scripts/context-for-new-chat.sh

# Get R context only
Rscript scripts/context-for-new-chat.R

# Get combined context
./scripts/get-context.sh
```

### Save Context for Cursor
```bash
# Save all context files
./scripts/save-context.sh

# Then link in Cursor with:
# @context.md
# @r-context.md
# @full-context.md
```

### Integration with Development Workflow
```bash
# Before starting work
./scripts/context-for-new-chat.sh

# After making changes
./scripts/save-context.sh

# For new Cursor chats
# Copy output from get-context.sh
```

## Troubleshooting

### Common Issues

1. **Script fails with "command not found"**
   - Install missing dependencies (R, gh, jq)
   - Check PATH environment variable

2. **GitHub API errors**
   - Ensure `gh` is authenticated: `gh auth login`
   - Check network connectivity

3. **R package errors**
   - Install required packages: `install.packages(c("devtools", "covr"))`
   - Check R environment and dependencies

4. **Permission errors**
   - Make scripts executable: `chmod +x scripts/*.sh`
   - Check file permissions

### Debug Mode
```bash
# Run with debug output
bash -x ./scripts/context-for-new-chat.sh

# Check specific section
Rscript -e "devtools::test()"
```

## Best Practices

### For Developers
1. Run context scripts before starting work
2. Save context files before sharing in Cursor
3. Check privacy/ethical compliance for new features
4. Update context after significant changes

### For Contributors
1. Use context scripts to understand current status
2. Check CRAN readiness before submitting PRs
3. Review privacy/ethical implications of changes
4. Follow the development workflow outlined in scripts

### For Maintainers
1. Keep context scripts updated with new features
2. Monitor privacy/ethical compliance issues
3. Update labels and issue organization as needed
4. Review and improve error handling regularly

## Future Enhancements

### Planned Improvements
1. **Real-world Testing Integration** - Add real-world testing status checks
2. **Performance Metrics** - Add performance benchmarking
3. **Security Scanning** - Integrate security vulnerability checks
4. **Documentation Coverage** - Add documentation completeness metrics
5. **Automated Compliance** - Add automated privacy/ethical compliance checks

### Potential Features
1. **Web Dashboard** - Web-based status dashboard
2. **Slack Integration** - Automated status updates
3. **Email Reports** - Periodic status reports
4. **Trend Analysis** - Historical status tracking
5. **Custom Metrics** - User-defined status checks

## Contributing

### Adding New Context Checks
1. Follow existing script patterns
2. Add proper error handling
3. Include validation and fallbacks
4. Update documentation
5. Test across different environments

### Script Maintenance
1. Keep dependencies minimal
2. Maintain backward compatibility
3. Add comprehensive error messages
4. Test regularly with different R versions
5. Update as project evolves

---

**Last Updated**: 2025-08-04
**Version**: 1.0.0
**Maintainer**: Project maintainers 