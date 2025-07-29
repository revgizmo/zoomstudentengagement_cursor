# zoomstudentengagement R Package

## Project Overview
R package for analyzing and visualizing student engagement from Zoom transcripts. Currently in development, preparing for CRAN submission.

## Current Status
- **CRAN Readiness**: NOT READY - Multiple critical issues blocking submission
- **Test Status**: 18 failures, 33 warnings (395 total tests)
- **Documentation**: Example failures and global variable binding issues
- **Code Quality**: Column naming regression from recent cleanup
- **Repository State**: Clean main branch, feature branch in progress
- **Issue Tracking**: Comprehensive audit completed, all issues documented

## Key Components
1. Core Functionality:
   - Transcript processing and analysis
   - Student engagement metrics calculation
   - Visualization tools for engagement data
   - Data management utilities

2. Package Structure:
   - R/ directory: Core functions
   - tests/ directory: Test suite
   - man/ directory: Documentation
   - inst/ directory: Package resources
   - vignettes/: Package usage examples
   - .github/: CI/CD and issue templates

## Project Management & Workflow
1. GitHub Issues:
   - Used for tracking all tasks, bugs, and enhancements
   - Issues are organized by labels:
     - Priority: High, Medium, Low
     - Type: Bug, Enhancement, Documentation, Test
     - Status: Blocked, In Progress, Needs Review
     - Area: Core, UI, Testing, Documentation
     - CRAN: Submission, Review, Compliance

2. Pull Request Process:
   - Create from feature/bugfix branch
   - Link to relevant issues using "Fixes #X" or "Closes #X"
   - Must pass all CI checks (R CMD check, tests)
   - Requires review before merge
   - PRs are automatically linked to project board

3. Project Board (GitHub Projects v2):
   - Columns: To Do, In Progress, Review, Done
   - Manual management of issue/PR status
   - Weekly review of project board
   - Regular cleanup of stale issues

4. Issue Templates:
   - Bug Report
   - Feature Request
   - Documentation Update
   - Test Enhancement
   - CRAN Submission Task

## Current Goals
1. CRAN Preparation:
   - Pass R CMD check with no errors/warnings/notes
   - Complete documentation overhaul
   - Achieve >90% test coverage
   - Review DESCRIPTION and NAMESPACE

2. Code Quality:
   - Enforce tidyverse style
   - Refactor function names for clarity
   - Improve error handling

3. Critical Issues (Blocking CRAN):
   - **Test Failures**: 18 failures due to column naming regression ([Issue #57](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/57))
   - **Example Failures**: Missing data objects in function examples ([Issue #58](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/58))
   - **Global Variables**: 15 undefined global variable warnings ([Issue #59](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/59))
   - **Test Suite**: Comprehensive restoration needed ([Issue #24](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/24))
   - **Documentation**: Complete audit and fixes required ([Issue #19](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/19))
   - **Documentation Organization**: README.Rmd restructuring and vignette infrastructure ([Issue #2](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/2), [Issue #45](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/45))

## Development Guidelines
1. Branch Strategy:
   - main: Production-ready code
   - feature/*: New features
   - bugfix/*: Bug fixes
   - docs/*: Documentation updates
   - test/*: Test-related changes
   - release/*: Release preparation

2. Commit Conventions:
   - feat: New feature
   - fix: Bug fix
   - docs: Documentation changes
   - style: Code style changes
   - refactor: Code refactoring
   - test: Test-related changes
   - chore: Maintenance tasks

3. PR Workflow:
   - Create branch from main
   - Make changes and commit following conventions
   - Push branch and create PR
   - Link to relevant issues
   - Wait for CI checks and review
   - Merge after approval

4. Issue Management:
   - Create issues for all tasks
   - Use appropriate templates
   - Add relevant labels
   - Link to project board
   - Update status as work progresses

5. Testing Requirements:
   - Aim for >90% test coverage
   - Use testthat for unit tests
   - Include both positive and negative test cases
   - Test edge cases and error conditions
   - Run tests locally before PR submission

6. Code Style:
   - Follow tidyverse style guide
   - Use styler::style_pkg() for formatting
   - Run lintr::lint_package() for style checks

## Dependencies
- Core: tidyverse, dplyr, ggplot2
- Testing: testthat, covr
- Documentation: roxygen2, pkgdown
- Development: devtools, styler, lintr

## Resources
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [R Packages Book](https://r-pkgs.org/)
- [GitHub Repository](https://github.com/revgizmo/zoomstudentengagement_cursor)
- [Project Board](https://github.com/revgizmo/zoomstudentengagement_cursor/projects)
- [Issues](https://github.com/revgizmo/zoomstudentengagement_cursor/issues)
- [Tidyverse Style Guide](https://style.tidyverse.org/)

## Environment Setup
1. Required Tools:
   - R >= 4.0.0
   - RStudio (recommended)
   - Git
   - GitHub CLI

2. Development Environment:
   - Install devtools: `install.packages("devtools")`
   - Install package dependencies: `devtools::install_deps()`
   - Load package for development: `devtools::load_all()`
   - Run tests: `devtools::test()`
   - Check package: `devtools::check()`

3. CI/CD:
   - GitHub Actions for automated testing
   - R CMD check on pull requests
   - Test coverage reporting
   - Documentation building

## AI Agent Guidelines
1. Context Management:
   - Keep context file up to date with latest changes
   - Document all significant decisions and their rationale
   - Track ongoing work and blockers
   - Maintain clear status of all components

2. Code Generation:
   - Follow R package best practices
   - Include comprehensive documentation
   - Add appropriate tests for new code
   - Ensure CRAN compliance
   - Use consistent naming conventions

3. Issue Resolution:
   - Document problem and solution approach
   - Link related issues and PRs
   - Track resolution progress
   - Update context with outcomes

4. Documentation:
   - Keep README current
   - Maintain up-to-date function documentation
   - Document all exported functions
   - Include usage examples
   - Keep vignettes current

## Cursor-Specific Guidelines
1. File Organization:
   - Keep related files together
   - Use consistent file naming
   - Maintain clear directory structure
   - Document file purposes

2. Code Navigation:
   - Use semantic search for finding relevant code
   - Leverage file search for quick access
   - Maintain clear function relationships
   - Document complex code paths

3. Development Workflow:
   - Use Cursor's AI features for code generation
   - Leverage built-in testing tools
   - Utilize documentation helpers
   - Follow Cursor's best practices for R development 