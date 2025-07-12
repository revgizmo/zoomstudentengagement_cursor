# Project Plan: zoomstudentengagement

## Overview
A package to analyze and visualize student engagement from Zoom transcripts, aimed at instructors and educational researchers.

## Goals
- Prepare for CRAN submission
- Improve documentation and usability
- Ensure robust testing and error handling

## Current Status (Updated: July 4, 2025)
**Package Status: Development Phase - Pre-CRAN Preparation**

### What's Working ✅
- **Core Functionality**: All 33 exported functions implemented and functional
- **Package Structure**: Standard R package layout with proper DESCRIPTION, NAMESPACE
- **Test Infrastructure**: 30+ test files with good coverage of exported functions
- **Basic Documentation**: README.md with comprehensive workflow examples (918 lines)
- **Repository Setup**: Clean main branch, no open PRs, proper git workflow

### What Needs Work ❌
- **Documentation Completeness**: Many functions have incomplete roxygen2 documentation
- **Test Quality**: Some test warnings in `make_clean_names_df.R` need resolution
- **CRAN Compliance**: License specification incomplete ("TBD Open Source")
- **Code Quality**: Need style consistency and error handling improvements

## CRAN Readiness Audit Results (July 2025)

### Critical Issues (Block CRAN submission)
1. **Incomplete Documentation**: Many functions have `@examples` tags but no actual examples
2. **Test Warnings**: `make_clean_names_df.R` has test warnings that need resolution
3. **License Specification**: "TBD Open Source" is not acceptable for CRAN
4. **R CMD Check**: Need to verify no errors/warnings/notes

### Immediate Action Items
1. **Documentation Fixes** (Priority: HIGH)
   - Audit all 33 exported functions for complete roxygen2 documentation
   - Fix functions with incomplete `@examples` sections
   - Ensure all examples are runnable

2. **Test Resolution** (Priority: HIGH)
   - Investigate and fix `make_clean_names_df.R` test warnings
   - Verify all tests pass without warnings

3. **CRAN Compliance** (Priority: HIGH)
   - Replace "TBD Open Source" with proper MIT license
   - Run full `devtools::check()` to verify compliance

### Verification Commands
```r
# Quick checks during development
devtools::load_all()           # Load package
devtools::test()               # Run tests
devtools::check_man()          # Check documentation

# Pre-CRAN submission checks
devtools::check()                    # Full package check
covr::package_coverage()             # Check test coverage
devtools::check_examples()           # Check examples run
styler::style_pkg()                  # Check code style
```

## Milestones & Timeline
- [ ] Codebase audit (by MM/DD)
- [ ] Documentation overhaul (by MM/DD)
- [ ] Expand test coverage (by MM/DD)
- [ ] CRAN compliance check (by MM/DD)
- [ ] Submit to CRAN (by MM/DD)

## Task Breakdown

### Code Quality
- [ ] Enforce tidyverse style
- [ ] Refactor function names for clarity

### Documentation
- [ ] Add roxygen2 docs to all exported functions
- [ ] Write vignette for full workflow
- [ ] Update README

### Testing
- [ ] Achieve >90% test coverage
- [ ] Add tests for edge cases

### CRAN Prep
- [ ] Pass R CMD check with no errors/warnings/notes
- [ ] Review DESCRIPTION and NAMESPACE

## Decisions & Rationale
- Will use tidyverse as a core dependency for consistency and user familiarity.

## References
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [R Packages Book](https://r-pkgs.org/)

## Using GitHub Projects/Issues for Tracking Progress

### GitHub Issues
- **Create an Issue:** Go to the "Issues" tab in your repo and click "New issue."
- **Title & Description:** Use clear, descriptive titles. In the description, provide context, steps to reproduce (for bugs), or acceptance criteria (for features).
- **Labels:** Use labels like `bug`, `enhancement`, `documentation`, `question`, etc.
- **Assignees & Milestones:** Assign issues to yourself or collaborators, and link them to milestones (e.g., "CRAN Submission").
- **Checklists:** Use markdown checklists for multi-step tasks.

### GitHub Projects (Projects v2)
- [x] Create project board (Projects v2)
- [x] Add initial issues to project board
- [x] Set up columns (To Do, In Progress, Review, Done)
- [ ] Manual management: Move issues/cards between columns as work progresses
- [ ] Contributors: Update project status manually when working on or closing issues/PRs
- [ ] Set up issue templates for different types of work (bug, enhancement, documentation)
- [ ] Create labels for better issue categorization
- [ ] Set up automation rules for issue/PR status updates
- [ ] Document project board workflow in CONTRIBUTING.md
- Note: Projects v2 does not currently support built-in automation (e.g., auto-move on PR merge/close). Monitor GitHub updates for future automation features.
- Not recommended: Classic Projects (deprecated by GitHub)

### Project Board Workflow
1. **Issue Creation**
   - Use appropriate issue template
   - Add relevant labels
   - Assign to appropriate milestone
   - Add to project board in "To Do" column

2. **Work Progress**
   - Move issue to "In Progress" when starting work
   - Update issue with progress comments
   - Link PRs to issues using "Fixes #X" or "Closes #X"
   - Move to "Review" when PR is ready

3. **Review Process**
   - Reviewers: Check PR against acceptance criteria
   - Move to "Done" after successful review and merge
   - Close related issues automatically via PR merge

4. **Regular Maintenance**
   - Weekly review of project board
   - Update issue priorities
   - Clean up stale issues
   - Update project status in team meetings

### Issue Templates
Create the following issue templates:
- Bug Report
- Feature Request
- Documentation Update
- Test Enhancement
- CRAN Submission Task

### Labels
Set up the following label categories:
- Priority: High, Medium, Low
- Type: Bug, Enhancement, Documentation, Test
- Status: Blocked, In Progress, Needs Review
- Area: Core, UI, Testing, Documentation
- CRAN: Submission, Review, Compliance

### Automation Rules
Set up the following automation rules:
- When PR is opened: Move linked issue to "Review"
- When PR is merged: Move linked issue to "Done"
- When issue is closed: Remove from project board
- When issue is reopened: Add back to "To Do"

### Project Board Metrics
Track the following metrics:
- Issue completion rate
- Average time in each column
- Number of issues per milestone
- Contributor activity
- PR review time

### Workflow Example
1. **Break down your project plan into issues:**  
   - "Refactor function names for clarity"
   - "Add roxygen2 documentation to all exported functions"
   - "Expand test coverage to 90%"
   - "Prepare for CRAN submission"

2. **Assign issues to milestones:**  
   - "CRAN v1.0 Release"

3. **Organize issues in a Project board:**  
   - Move issues from "To Do" to "In Progress" as you work on them, and to "Done" when finished.

4. **Reference issues in commits and pull requests:**  
   - Use `Fixes #12` in a commit or PR description to automatically close the issue when merged.

### Resources
- [GitHub Issues Documentation](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues)
- [GitHub Projects Documentation](https://docs.github.com/en/issues/organizing-your-work-with-project-boards/managing-project-boards)
- [GitHub Project Boards for Open Source](https://github.com/orgs/community/discussions/16925)

## Dependencies & Version Management
- [ ] Review and document all package dependencies
- [ ] Specify minimum version requirements in DESCRIPTION
- [ ] Document any system requirements
- [ ] Consider using renv for reproducible environments
- [ ] Document any external data requirements

## Repository Setup & Management

### Initial Setup
- [ ] Create new GitHub repository
  - Name: zoomstudentengagement_cursor
  - Description: R package for analyzing student engagement in Zoom sessions
  - Public visibility
  - No README, .gitignore, or license (will add manually)
- [ ] Configure repository settings
  - Enable branch protection for main
  - Set up GitHub Actions
  - Configure issue templates
- [ ] Set up local git environment
  - Configure user name and email
  - Set up SSH keys
  - Initialize repository
  - Add remote

### Branching Strategy
- main: Production-ready code
- develop: Integration branch
- feature/*: New features
- release/*: Release preparation
- hotfix/*: Emergency fixes

### Git Workflow
- Commit conventions
  - feat: New feature
  - fix: Bug fix
  - docs: Documentation changes
  - style: Code style changes
  - refactor: Code refactoring
  - test: Test-related changes
  - chore: Maintenance tasks
- Pull request process
  - Create from feature branch
  - Link to issues
  - Review checklist
  - CI checks
- Release process
  - Version tagging
  - Changelog updates
  - Documentation updates

### Repository Maintenance
- Regular cleanup of stale branches
- Issue triage
- Documentation updates
- Dependency updates

#### GitHub CLI Workaround
- [x] Troubleshoot and fix IDE shell environment issue affecting gh CLI output
    - Issue: gh CLI output was broken in IDE terminal but worked in plain terminal
    - Resolution: Cleaned up .zshrc configuration, particularly the conda initialization block
    - Current status: gh CLI now works correctly in both IDE and plain terminals
    - All gh CLI functionality is now available without workarounds

## Continuous Integration & Deployment

### CI/CD Plan
- **Stage 1:** Set up basic GitHub Actions workflow to run R CMD check and testthat tests on push/PR (Ubuntu, latest R)
  - [x] Initial workflow setup with R-CMD-check.yaml
  - [ ] Optimize dependency installation:
    - [ ] Add R package caching using `actions/cache`
    - [ ] Use `r-lib/actions/setup-r-dependencies@v2` for efficient dependency management
    - [ ] Configure dependency installation to only install necessary packages
    - [ ] Add caching for system dependencies
  - [ ] Monitor and optimize workflow performance:
    - [ ] Track installation times
    - [ ] Identify bottlenecks
    - [ ] Document optimization strategies
- **Stage 2:** Add code coverage reporting (covr)
- **Stage 3:** Add code style/linting checks (lintr)
- **Stage 4:** Add automated documentation builds (pkgdown)
- **Stage 5:** Expand to multiple OSes (macOS, Windows) and R versions as needed

### GitHub Actions Optimization
- **Current Issues:**
  - Long dependency installation times (7+ minutes)
  - Inefficient package caching
  - Redundant dependency installations

- **Optimization Strategy:**
  1. **Package Caching:**
     - Implement R package caching using `actions/cache`
     - Cache both CRAN and GitHub packages
     - Set appropriate cache keys and paths

  2. **Dependency Management:**
     - Replace manual dependency installation with `r-lib/actions/setup-r-dependencies@v2`
     - Configure to install only necessary dependencies
     - Use `dependencies: c("Depends", "Imports", "LinkingTo")` instead of `TRUE`

  3. **System Dependencies:**
     - Cache system package installations
     - Optimize apt-get update/install commands
     - Consider using pre-built Docker images

  4. **Workflow Structure:**
     - Separate dependency installation from testing
     - Use matrix builds for different R versions
     - Implement conditional steps based on changes

  5. **Monitoring:**
     - Add timing information to workflow steps
     - Track cache hit rates
     - Monitor workflow performance metrics

- **Implementation Steps:**
  1. Create new branch for workflow optimization
  2. Update R-CMD-check.yaml with optimized configuration
  3. Test workflow performance
  4. Document optimization results
  5. Create pull request with changes

- **Expected Benefits:**
  - Reduced workflow execution time
  - More reliable dependency installation
  - Better resource utilization
  - Improved developer experience

## Accessibility & Internationalization
- [ ] Ensure colorblind-friendly plotting
- [ ] Add alt text for all visualizations
- [ ] Consider non-English transcript support
- [ ] Document character encoding requirements
- [ ] Test with screen readers

## Performance & Scalability
- [ ] Profile package performance
- [ ] Document memory requirements
- [ ] Optimize for large transcript files
- [ ] Consider parallel processing options
- [ ] Document performance considerations

## Security & Privacy
- [ ] Review data handling practices
- [ ] Document privacy considerations
- [ ] Implement secure file handling
- [ ] Add data anonymization options
- [ ] Document security best practices

## Community & Support
- [ ] Create CONTRIBUTING.md
- [ ] Add CODE_OF_CONDUCT.md
- [ ] Set up issue templates
- [ ] Plan for user support channels
- [ ] Document contribution guidelines

## Release Management
- [ ] Define version numbering scheme
- [ ] Plan for pre-release testing
- [ ] Document release checklist
- [ ] Plan for post-release monitoring
- [ ] Set up automated release notes

## Quality Assurance
- [ ] Implement linting with lintr
- [ ] Set up spell checking for documentation
- [ ] Add package-level documentation
- [ ] Create NEWS.md for version history
- [ ] Document all exported functions
- [ ] Add examples for all exported functions
- [ ] Ensure all examples are runnable
- [ ] Add package startup messages
- [ ] Document package options

## Maintenance & Backward Compatibility
- [ ] Document deprecation policy
- [ ] Plan for handling breaking changes
- [ ] Set up automated dependency updates
- [ ] Document upgrade paths
- [ ] Plan for long-term support
- [ ] Create maintenance schedule
- [ ] Document supported R versions
- [ ] Plan for dependency updates

## Data Management
- [ ] Document data storage practices
- [ ] Plan for data versioning
- [ ] Add data validation checks
- [ ] Document data format requirements
- [ ] Add data cleaning utilities
- [ ] Plan for data migration tools
- [ ] Document data backup procedures

## Error Handling & Debugging
- [ ] Implement consistent error messages
- [ ] Add debug mode options
- [ ] Document common error scenarios
- [ ] Add troubleshooting guide
- [ ] Implement graceful degradation
- [ ] Add logging capabilities
- [ ] Document debugging procedures

## Documentation Standards
- [ ] Create documentation templates
- [ ] Set up pkgdown website
- [ ] Add function families
- [ ] Document parameter conventions
- [ ] Add cross-references
- [ ] Create concept documentation
- [ ] Add package vignettes
- [ ] Document development practices

## Risk Management

### Technical Risks
- [ ] **Zoom API Changes**
  - Risk: Zoom changes their transcript format or API
  - Mitigation: Document format requirements, add validation, create test fixtures
  - Monitoring: Subscribe to Zoom developer updates

- [ ] **Performance Issues**
  - Risk: Package becomes unusable with large transcripts
  - Mitigation: Implement chunking, add progress bars, document memory requirements
  - Monitoring: Add performance benchmarks

- [ ] **Dependency Issues**
  - Risk: Key dependencies become deprecated or incompatible
  - Mitigation: Document minimum versions, test with multiple versions
  - Monitoring: Set up dependency update alerts

### Project Risks
- [ ] **Scope Creep**
  - Risk: Project becomes too complex to maintain
  - Mitigation: Define clear MVP, document feature requests separately
  - Monitoring: Regular scope reviews

- [ ] **Documentation Debt**
  - Risk: Documentation falls behind code changes
  - Mitigation: Make documentation part of PR requirements
  - Monitoring: Regular documentation audits

- [ ] **Testing Gaps**
  - Risk: Critical bugs slip through
  - Mitigation: Implement test coverage requirements
  - Monitoring: Regular test coverage reports

### User Experience Risks
- [ ] **Learning Curve**
  - Risk: Package is too complex for target users
  - Mitigation: Create detailed tutorials, add helper functions
  - Monitoring: User feedback collection

- [ ] **Data Privacy**
  - Risk: Accidental exposure of sensitive student data
  - Mitigation: Implement strict data handling, add anonymization
  - Monitoring: Regular security audits

### Maintenance Risks
- [ ] **Bus Factor**
  - Risk: Single point of failure in maintenance
  - Mitigation: Document all processes, encourage contributions
  - Monitoring: Regular contributor check-ins

- [ ] **Version Compatibility**
  - Risk: Breaking changes in R or dependencies
  - Mitigation: Test matrix, version constraints
  - Monitoring: CI/CD on multiple R versions

### Mitigation Strategy
- [ ] Create risk assessment document
- [ ] Set up automated monitoring
- [ ] Document contingency plans
- [ ] Establish regular risk review meetings
- [ ] Create issue templates for risk reporting

## License
- [ ] Add MIT License to repository
- [ ] Update DESCRIPTION with license information
- [ ] Add license badge to README
- [ ] Document license requirements in CONTRIBUTING.md

The package is licensed under the MIT License:

```
MIT License

Copyright (c) 2024 revgizmo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## Codebase Audit (2024-06)
- [ ] [Master Tracking Issue: #15](https://github.com/revgizmo/zoomstudentengagement_cursor/issues/15)
- [ ] Review function naming and API consistency
- [ ] Refactor duplicated code
- [ ] Improve error messages
- [ ] Update documentation
- [ ] Increase test coverage
- [ ] Review dependencies and CRAN readiness
- [ ] Address technical debt and future improvements 