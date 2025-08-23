# Contributing to zoomstudentengagement

Thank you for your interest in contributing to the zoomstudentengagement package! This document outlines the development workflow and best practices.

## Quick Start

### For New Contributors
1. **Read this guide** - Understand the development workflow
2. **Check the AI guidelines** - [AI-Assisted Development Guide](docs/development/AI_ASSISTED_DEVELOPMENT.md)
3. **Review current issues** - `gh issue list --limit 10`
4. **Pick an issue** - Start with "good first issue" or "priority:medium"
5. **Follow the workflow** - Create branch, make changes, test, submit PR

### For AI-Assisted Development
- **Use the context scripts** - `./scripts/context-for-new-chat.sh`
- **Follow AI guidelines** - [AI-Assisted Development Guide](docs/development/AI_ASSISTED_DEVELOPMENT.md)
- **Maintain ethical standards** - Privacy first, FERPA compliance
- **Validate all changes** - Run pre-PR validation checklist

## Development Workflow

### Branching Strategy

We use the following branch structure:

- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/*`: New features (e.g., `feature/improve-visualizations`)
- `bugfix/*`: Bug fixes (e.g., `bugfix/fix-name-matching`)
- `docs/*`: Documentation updates
- `test/*`: Test-related changes
- `release/*`: Release preparation

### Git Commit Messages

Follow these conventions for commit messages:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test-related changes
- `chore`: Maintenance tasks

Examples:
```
feat(visualization): add engagement heatmap plot
fix(name-matching): handle special characters in student names
docs(readme): update installation instructions
```

### Pull Requests

1. Create a new branch from `develop`
2. Make your changes
3. Run tests locally
4. Push your branch
5. Create a pull request to `develop`
6. Link to relevant issues using `Fixes #X` or `Closes #X`
7. Request review from maintainers

## Pull Request Review

### Quick Review Checklist
- [ ] **CRAN Compliance**: No submission blockers, examples work
- [ ] **Privacy-First**: FERPA compliance, data protection
- [ ] **Quality Standards**: Code quality, testing, documentation
- [ ] **Merge Readiness**: Conflicts resolved, CI passing
- [ ] **Project Alignment**: Supports CRAN submission goals

### Decision Criteria
- **APPROVE**: Meets all criteria, ready for merge
- **REVISE**: Has merit but needs specific improvements
- **REJECT**: Doesn't meet standards or conflicts with priorities

### Common Scenarios
- **Clean Merge**: Standard process, no conflicts
- **Merge Conflicts**: Rebase required before merge
- **Branch Protection**: Use admin override when appropriate
- **CI Pending**: Acceptable for documentation, require fixes for code changes

### Time Estimates
- **Low**: <10 files, documentation (10-15 min)
- **Medium**: 10-50 files, code changes (15-25 min)
- **High**: >50 files, infrastructure (25-40 min)

*Note: For complex PRs or team reviews, see PR_REVIEW_PROMPT_GENERATOR_OPTIMIZED.md for detailed guidance.*

## Development Guidelines

### Code Quality Standards

#### **R Style Guidelines**
- Follow the [tidyverse style guide](https://style.tidyverse.org/)
- Use `styler::style_pkg()` to format code
- Run `lintr::lint_package()` to check for style issues
- Prefer `<-` for assignment over `=`
- Use snake_case for function and variable names
- Use camelCase for data frame column names when appropriate
- Maximum line length: 80 characters

#### **Function Design**
- All exported functions must have complete roxygen2 documentation
- Include `@param`, `@return`, `@examples` sections
- Use `@export` tag for public functions
- Use `@keywords internal` for internal functions
- All examples must be runnable and tested

#### **Error Handling**
- Use `stop()` for fatal errors with informative messages
- Use `warning()` for recoverable issues
- Use `message()` for informational output
- Validate input parameters early in functions
- Provide helpful error messages that guide users

#### **Performance Considerations**
- Use data.table for large data operations
- Implement chunking for large transcript files
- Add progress indicators for long operations
- Consider parallel processing for batch operations
- Profile functions for performance bottlenecks

### Testing Requirements

#### **Test Coverage**
- Aim for >90% test coverage
- Use `testthat` for unit tests
- Include both positive and negative test cases
- Test edge cases and error conditions
- Run tests locally before PR submission

#### **Test Organization**
Tests are organized by function/module:
```
tests/
  testthat/
    test-name-matching.R
    test-transcript-processing.R
    test-visualization.R
    test-engagement-metrics.R
```

#### **Running Tests**

```r
# Run all tests
devtools::test()

# Run specific test file
devtools::test("tests/testthat/test-name-matching.R")

# Check test coverage
covr::package_coverage()

# Run tests with verbose output
devtools::test(reporter = "verbose")
```

#### **Test Best Practices**
- Write tests before implementing features (TDD)
- Test both success and failure cases
- Use descriptive test names
- Group related tests with `describe()` blocks
- Use `testthat::skip_on_cran()` for tests requiring external data
- Create minimal test datasets in `inst/extdata/`

### Documentation Standards

#### **Function Documentation**
- Use roxygen2 for all function documentation
- Include `@title`, `@description`, `@param`, `@return`, `@examples`
- Use `@seealso` to link related functions
- Use `@family` to group related functions
- Include `@export` for public functions
- Use `@keywords internal` for internal functions

#### **Examples**
- All examples must be runnable
- Use `\dontrun{}` for examples that require external data
- Use `\donttest{}` for examples that are slow
- Provide realistic examples with sample data
- Test all examples with `devtools::check_examples()`

#### **Package Documentation**
- Keep README.md comprehensive and up-to-date
- Create vignettes for complex workflows
- Use `devtools::build_readme()` to rebuild README from README.Rmd
- Include installation instructions and basic usage examples
- Update NEWS.md for user-facing changes

### Pre-PR Validation

Before creating a pull request, run these checks:

```r
# Phase 1: Code Quality (5-10 minutes)
styler::style_pkg()                  # Ensure consistent formatting
lintr::lint_package()               # Check code quality

# Phase 2: Documentation (2-5 minutes)
devtools::document()                 # Update roxygen2 documentation
devtools::build_readme()             # Rebuild README.md
devtools::spell_check()              # Check for typos

# Phase 3: Testing (3-5 minutes)
devtools::test()                     # Run all tests
covr::package_coverage()             # Check test coverage

# Phase 4: Final Validation (5-10 minutes)
devtools::check()                    # Full package check
devtools::build()                    # Create distributable package
```

### Diagnostic Output Policy

- Default to quiet output. Provide a `verbose = FALSE` argument for functions that may emit diagnostics.
- Gate any `print()`, `message()`, or `cat()` calls behind both the verbose flag and the test guard, for example:
  ```r
  if (isTRUE(verbose) && Sys.getenv("TESTTHAT") != "true") {
    message("detailed status...")
  }
  ```
- Guard interactive prompts with `interactive()` and provide non-interactive fallbacks:
  ```r
  if (interactive()) {
    # prompt user
  } else {
    # fallback path without prompting
  }
  ```
- Keep examples runnable and quiet by default; avoid stray diagnostics in examples and tests.
- The pre-PR validator enforces this policy; ensure it reports "All diagnostic output properly conditional" before opening a PR.

### Managing Issues from Markdown Plans

We maintain a Markdown plan at `ISSUES/docs_overhaul_plan.md` and sync it to GitHub Issues.

- Local usage:
  - Dry run:
    ```bash
    DRY_RUN=1 bash scripts/create_issues_from_plan.sh ISSUES/docs_overhaul_plan.md
    ```
  - Create/update issues:
    ```bash
    export GH_TOKEN=YOUR_TOKEN
    UPDATE_IF_EXISTS=1 bash scripts/create_issues_from_plan.sh ISSUES/docs_overhaul_plan.md
    ```
- GitHub Actions:
  - Run workflow “Sync issues from plan” with inputs:
    - `plan_path`: path to the plan (default: `ISSUES/docs_overhaul_plan.md`)
    - `update`: `true` to update existing issues with matching titles

Plan format:
- Front matter: `milestone`, `tracking_issue_title`
- Each `## Heading` becomes an issue; optional `Labels:` and `Assignees:` lines per section.

### Validation Requirements

#### **Code Quality**
- [ ] Code follows tidyverse style guide
- [ ] No lintr warnings or errors
- [ ] Consistent naming conventions
- [ ] Proper error handling
- [ ] Input validation implemented

#### **Documentation**
- [ ] All exported functions documented
- [ ] Examples are runnable and tested
- [ ] README.md is current
- [ ] No spelling errors
- [ ] Vignettes are up to date

#### **Testing**
- [ ] All tests pass
- [ ] Coverage >90% for new code
- [ ] Edge cases covered
- [ ] Error conditions tested
- [ ] Performance considerations addressed

#### **CRAN Compliance**
- [ ] R CMD check passes (0 errors, 0 warnings)
- [ ] Package builds successfully
- [ ] All examples run without errors
- [ ] No global variable warnings
- [ ] License and metadata correct

## Development Setup

### Required Tools
- R >= 4.0.0
- RStudio (recommended)
- Git
- GitHub CLI
  - **For AI agents**: See [GitHub CLI Best Practices](docs/development/CURSOR_INTEGRATION.md#-github-cli-best-practices-for-ai-agents) for detailed PR comment analysis

### Environment Setup

1. **Fork the repository**
2. **Clone your fork**
3. **Install development dependencies**:
   ```r
   # Install devtools
   install.packages("devtools")
   
   # Install package dependencies
   devtools::install_deps()
   
   # Install development dependencies
   devtools::install_dev_deps()
   ```
4. **Load package for development**:
   ```r
   devtools::load_all()
   ```
5. **Create a new branch**
6. **Make your changes**
7. **Run tests and checks**
8. **Submit a pull request**

### Development Environment

```r
# Load package for development
devtools::load_all()

# Run tests
devtools::test()

# Check package
devtools::check()

# Build package
devtools::build()

# Install package locally
devtools::install()
```

## CRAN Preparation

### CRAN Submission Requirements

#### **Critical Requirements**
- All tests must pass (`devtools::test()`)
- Code coverage >90% (`covr::package_coverage()`)
- No spelling errors (`devtools::spell_check()`)
- All examples run (`devtools::check_examples()`)
- R CMD check passes with 0 errors, 0 warnings (`devtools::check()`)
- Package builds successfully (`devtools::build()`)

#### **Documentation Completeness**
- All exported functions have complete roxygen2 documentation
- All examples are runnable and tested
- README.md is current and comprehensive
- Vignettes are created for complex workflows
- No missing documentation warnings

#### **Package Metadata**
- `DESCRIPTION` has correct version, license (MIT), and dependencies
- `NAMESPACE` is properly generated
- All dependencies are specified with version constraints
- License file is present and correct

### CRAN Preparation Workflow

#### **Phase 1: Pre-Submission Validation (1-2 days)**
```r
# Run comprehensive validation
devtools::check()                    # Full package check
devtools::test()                     # Test suite
covr::package_coverage()             # Coverage check
devtools::spell_check()              # Spell check
devtools::check_examples()           # Examples check
devtools::build()                    # Build package
```

#### **Phase 2: Address Issues**
- **Test Coverage**: Ensure >90% coverage
- **R CMD Check**: Resolve any errors, warnings, or notes
- **Documentation**: Update any missing or incomplete docs
- **Examples**: Ensure all examples run without errors
- **Spelling**: Fix any spelling errors

#### **Phase 3: Final Validation (1 day)**
```r
# Final validation checklist
devtools::check()                    # Should be 0 errors, 0 warnings, 0 notes
devtools::test()                     # Should be 0 failures
covr::package_coverage()             # Should be >90%
devtools::spell_check()              # Should be 0 errors
devtools::check_examples()           # Should be 0 errors
devtools::build()                    # Should create .tar.gz file
```

#### **Phase 4: CRAN Submission**
1. **Submit to CRAN**
   - Go to https://cran.r-project.org/submit.html
   - Upload package tarball
   - Fill out submission form
   - Submit for review

2. **Monitor submission**
   - Check email for CRAN feedback
   - Address any issues promptly
   - Resubmit if needed

### Current CRAN Status

**Overall Status**: EXCELLENT - Very Close to CRAN Ready
**Progress**: 90% Complete
**Estimated Time**: 1-2 weeks
**Confidence Level**: HIGH

**Current Metrics**:
- ✅ **Test Suite**: 453 tests passing, 0 failures
- 🔄 **Code Coverage**: 83.41% (target: 90%)
- ✅ **R CMD Check**: 0 errors, 0 warnings, 3 notes
- ✅ **Documentation**: Complete for all exported functions
- ✅ **Spell Check**: 0 errors

**Remaining Tasks**:
- **Test Coverage**: Increase to 90% (currently 83.41%)
- **R CMD Check Notes**: Address 3 minor notes
- **Test Warnings**: Clean up 29 test warnings

For detailed CRAN preparation tracking, see [CRAN_CHECKLIST.md](CRAN_CHECKLIST.md).

## Release Process

1. Create `release/vX.Y.Z` branch from `develop`
2. Update version in DESCRIPTION
3. Update NEWS.md
4. Run R CMD check
5. Submit to CRAN
6. Merge to `main` and tag release
7. Merge back to `develop`

### Development Workflow

For detailed pre-CRAN development workflow, including pre-PR validation, PR creation, and merge processes, see the [Pre-CRAN Development Workflow section in PROJECT.md](PROJECT.md#pre-cran-development-workflow).

Key points:
- Follow the 4-phase pre-PR validation before creating PRs
- Use `devtools::check()` for final validation
- Consider bypassing branch protection when confident in changes
- Link PRs to issues using `Fixes #X` or `Closes #X`

### CRAN Submission (Future)

For CRAN submission workflow when the package is ready for CRAN, see the [CRAN Submission Workflow section in PROJECT.md](PROJECT.md#cran-submission-workflow-future).

## Ethical Development Practices

### Privacy and Security
- **Never log or expose** sensitive student data
- **Always anonymize** data in examples and tests
- **Validate input** to prevent injection attacks
- **Follow FERPA guidelines** for all data handling
- **Use secure practices** for file operations

### Equitable Participation
- Focus on participation equity in all features
- Ensure inclusive design in visualizations
- Consider accessibility in all implementations
- Document ethical considerations in code

### Transparency
- Document AI-assisted changes and their rationale
- Maintain clear audit trails for all modifications
- Provide clear explanations for design decisions
- Include context in commit messages

## Troubleshooting

### Common Issues

#### **Test Failures**
- Check test data and function changes
- Verify test environment setup
- Review test assumptions and edge cases
- Check for missing dependencies

#### **Documentation Errors**
- Run `devtools::document()` to update roxygen2
- Check for syntax errors in roxygen2 comments
- Verify all examples are runnable
- Check for missing imports in NAMESPACE

#### **R CMD Check Issues**
- Review global variable warnings
- Check for missing dependencies
- Verify file timestamps and structure
- Ensure all examples run without errors

#### **Performance Issues**
- Profile functions for bottlenecks
- Use data.table for large operations
- Implement chunking for large files
- Consider parallel processing where appropriate

### Getting Help

#### **When Stuck**
1. Check existing issues for similar problems
2. Review the [AI-Assisted Development Guide](docs/development/AI_ASSISTED_DEVELOPMENT.md)
3. Run context scripts to get current status
4. Check PROJECT.md for current priorities
5. Create an issue with detailed information

#### **For Complex Problems**
1. Include full error messages
2. Provide minimal reproducible examples
3. Include environment information
4. Describe expected vs actual behavior
5. Link to related issues or documentation

## Questions?

If you have questions about contributing, please:
1. Check the documentation
2. Search existing issues
3. Create a new issue with the "question" label

### Creating Issues

1. Go to the GitHub repository
2. Click on "Issues" tab
3. Click "New issue"
4. Choose the appropriate template from the list
5. Fill in the template with your issue details
6. Add appropriate labels
7. Submit the issue

For bug reports, include:
- Clear description of the bug
- Steps to reproduce
- Expected behavior
- Minimal reproducible example
- Environment details

For feature requests, include:
- Clear description of the feature
- Use case and benefits
- Implementation suggestions (if any)
- Related issues (if any)

## Additional Resources

### Documentation
- [R Packages Book](https://r-pkgs.org/)
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [tidyverse style guide](https://style.tidyverse.org/)
- [testthat documentation](https://testthat.r-lib.org/)

### Tools
- `devtools` for package development
- `roxygen2` for documentation
- `testthat` for testing
- `styler` for code formatting
- `lintr` for code quality
- `covr` for test coverage

### Project-Specific Guides
- [AI-Assisted Development Guide](docs/development/AI_ASSISTED_DEVELOPMENT.md) - Comprehensive AI guidelines
- [PROJECT.md](PROJECT.md) - Current project status and priorities
- [CRAN_CHECKLIST.md](CRAN_CHECKLIST.md) - CRAN submission checklist
- [ISSUE_MANAGEMENT_QUICK_REFERENCE.md](ISSUE_MANAGEMENT_QUICK_REFERENCE.md) - Issue workflow

### Best Practices
- Follow R package development best practices
- Use consistent naming conventions
- Write comprehensive documentation
- Maintain high test coverage
- Regular code reviews and updates 

## Branch Management and Workflow Best Practices

### Branch Lifecycle Management

#### **Regular Branch Pruning**
- **Check merged branches**: `git branch -r --merged origin/main`
- **Verify unmerged work**: `git log --oneline <branch> --not origin/main`
- **Prune remote references**: `git fetch --prune`
- **Document decisions**: Record branch pruning rationale

#### **Branch Status Analysis**
```bash
# List all remote branches
git branch -r

# Check which branches are merged
git branch -r --merged origin/main

# See commits ahead of main
git log --oneline <branch> --not origin/main

# View commit statistics
git show --stat <commit-hash>
```

### Pull Request Workflow

#### **Pre-PR Validation**
```bash
# Run comprehensive validation
Rscript scripts/pre-pr-validation.R

# Commit context updates
git add docs/development/archive/issue-160/README.md
git commit -m "chore(context): save context files before PR"

# Push to remote
git push origin <branch-name>
```

#### **PR Creation and Merge**
```bash
# Create PR with detailed description
gh pr create --title "type: description" --body "## Summary..."

# Merge with admin override (if needed)
gh pr merge <PR_NUMBER> --merge --admin

# Clean up local branch
git checkout main
git pull origin main
git branch -d <branch-name>
```

### Git Merge Strategy Insights

#### **Automatic Conflict Resolution**
- **ORT Strategy**: Git's "Ostensibly Recursive's Twin" strategy can automatically handle compatible changes
- **No Manual Resolution**: Sometimes what appears to be conflicts are actually compatible changes
- **Smart Merging**: Git recognizes when changes can be merged without manual intervention

#### **Best Practices**
- **Always test merges**: Use `git merge main` to test compatibility
- **Document findings**: Record lessons learned about merge strategies
- **Regular cleanup**: Prevent repository bloat with systematic pruning

### Recent Branch Pruning Experience (2025-08-13)

#### **Successfully Pruned Branches**
- ✅ `origin/feature/status-update-2025-08-08` - Status documentation (merged)
- ✅ `origin/fix/name-matching-privacy-masking-issue-160` - Privacy implementation (merged)  
- ✅ `origin/cursor/prepare-product-requirements-document-for-realignment-e85c` - PRD updates (merged)
- ✅ `origin/cursor/user-perspective-review-of-r-package-45f9` - Issue backup functionality (merged)

#### **Key Learnings**
1. **Git Merge Strategy Sophistication**: ORT strategy automatically handled "conflicts" that weren't actually conflicts
2. **Compatible Changes**: Despite overlapping work, changes were compatible and merged cleanly
3. **Automatic Conflict Resolution**: Git recognized that changes could be merged without manual intervention
4. **Branch Lifecycle Management**: Regular pruning prevents repository bloat and confusion

For detailed refactoring roadmap and branch management tasks, see [`.github/ISSUES/refactor/011-repo-hygiene-and-data.md`](.github/ISSUES/refactor/011-repo-hygiene-and-data.md). 