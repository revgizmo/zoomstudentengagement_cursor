# Issue Management Guidelines
## zoomstudentengagement R Package

**Created:** July 2025  
**Purpose:** Standardize issue management practices for the zoomstudentengagement R package

## 🚀 **Cursor Quick Reference**

### For Cursor Users
When working with issues in Cursor, follow these key practices:

1. **Always check issue labels** before starting work
2. **Use conventional commit messages** that reference issues: `fix: Address issue #71 - Add withr dependency`
3. **Link PRs to issues** using `Fixes #X` or `Closes #X` in PR descriptions
4. **Update issue status** when moving between development phases

### Essential Labels to Know
- `priority:high` - CRAN blockers, work on these first
- `priority:medium` - Important but not blocking
- `priority:low` - Nice to have
- `CRAN:submission` - Related to CRAN submission
- `area:core` - Core functionality
- `area:testing` - Test-related work

### Issue Lifecycle in Cursor
1. **Create/Review** → Use templates below
2. **Development** → Update with progress, link PRs
3. **Review** → Ensure all criteria met
4. **Close** → When PR merged, add summary

## Overview

This document establishes guidelines for managing GitHub issues in the zoomstudentengagement R package repository. These guidelines ensure consistent issue tracking, proper prioritization, and efficient development workflow.

## Issue Creation Guidelines

### Issue Templates

#### Bug Report Template
```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- R version: 
- Package version: 
- Operating system: 

## Additional Context
Any other relevant information
```

#### Feature Request Template
```markdown
## Feature Description
Brief description of the requested feature

## Use Case
Why is this feature needed?

## Proposed Solution
How should this feature work?

## Alternatives Considered
Other approaches that were considered

## Additional Context
Any other relevant information
```

#### Documentation Update Template
```markdown
## Documentation Issue
Brief description of the documentation problem

## Current State
What the documentation currently says

## Desired State
What the documentation should say

## Impact
Who is affected by this issue?

## Additional Context
Any other relevant information
```

### Required Information

All issues must include:
- **Clear title** that describes the problem or request
- **Detailed description** with context and examples
- **Reproduction steps** (for bugs)
- **Expected vs actual behavior** (for bugs)
- **Impact assessment** (who is affected)
- **Proposed solution** (for features)

## Labeling System

### Priority Labels
- `priority:high` - CRAN blockers, critical bugs, security issues
- `priority:medium` - Important features, significant improvements
- `priority:low` - Nice-to-have features, minor improvements

### Type Labels
- `bug` - Something isn't working as expected
- `enhancement` - New feature or improvement
- `documentation` - Documentation updates
- `refactor` - Code cleanup and restructuring

### Area Labels
- `area:core` - Core package functionality
- `area:testing` - Test infrastructure and coverage
- `area:documentation` - Documentation and examples
- `area:infrastructure` - CI/CD and development tools

### Special Labels
- `CRAN:submission` - Related to CRAN submission
- `CRAN:compliance` - CRAN policy compliance
- `audit` - Part of codebase audit
- `good first issue` - Suitable for new contributors

## Issue Lifecycle

### 1. Creation
- Use appropriate issue template
- Add relevant labels
- Assign to appropriate milestone
- Set priority based on impact

### 2. Triage
- Review for completeness
- Verify reproducibility (for bugs)
- Assess priority and impact
- Add missing labels or information

### 3. Development
- Move to "In Progress" when work begins
- Update with progress comments
- Link related PRs using "Fixes #X" or "Closes #X"

### 4. Review
- Move to "Review" when PR is ready
- Ensure all acceptance criteria are met
- Verify tests pass and documentation is updated

### 5. Closure
- Close when PR is merged and deployed
- Add resolution summary
- Update related documentation

## Priority Assessment

### High Priority Criteria
- **CRAN Submission Blockers:** Issues that prevent CRAN submission
- **Critical Bugs:** Functionality that doesn't work at all
- **Security Issues:** Any security vulnerabilities
- **Breaking Changes:** Issues that affect existing functionality
- **Performance Issues:** Significant performance degradation

### Medium Priority Criteria
- **Important Features:** Features that significantly improve usability
- **Documentation Gaps:** Missing or unclear documentation
- **Code Quality:** Refactoring that improves maintainability
- **Test Coverage:** Improving test coverage for critical functions

### Low Priority Criteria
- **Nice-to-Have Features:** Features that would be helpful but not essential
- **Minor Improvements:** Small enhancements to existing functionality
- **Code Style:** Style improvements that don't affect functionality
- **Documentation Polish:** Minor documentation improvements

## Issue Organization

### Milestones
- **CRAN Submission Preparation:** Issues needed for CRAN submission
- **Core Functionality Enhancement:** Core package improvements
- **Code Quality and Refactoring:** Technical debt and improvements
- **Documentation and Infrastructure:** Documentation and tooling

### Project Boards
- **To Do:** New issues and planned work
- **In Progress:** Issues currently being worked on
- **Review:** Issues with PRs ready for review
- **Done:** Completed issues

## Issue Maintenance

### Regular Reviews
- **Weekly:** Review open issues for accuracy and priority
- **Monthly:** Audit issue labels and organization
- **Quarterly:** Review and update issue templates

### Cleanup Procedures
- **Stale Issues:** Close issues that are no longer relevant
- **Duplicate Issues:** Consolidate similar issues
- **Outdated Information:** Update issue descriptions as needed

## Communication Guidelines

### Issue Comments
- Be clear and concise
- Provide context for decisions
- Use @mentions when appropriate
- Link to related issues or PRs

### Status Updates
- Update issues regularly with progress
- Explain delays or blockers
- Provide estimates when possible
- Celebrate completions

## Best Practices

### Do's
- ✅ Use clear, descriptive titles
- ✅ Provide detailed descriptions with examples
- ✅ Add appropriate labels and milestones
- ✅ Update issues with progress
- ✅ Link related issues and PRs
- ✅ Close issues when resolved

### Don'ts
- ❌ Create vague or incomplete issues
- ❌ Leave issues open indefinitely
- ❌ Ignore priority labels
- ❌ Create duplicate issues
- ❌ Forget to update issue status

## Issue Templates

### Bug Report
```markdown
---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: ['bug']
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '....'
3. Scroll down to '....'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Environment (please complete the following information):**
 - OS: [e.g. macOS, Windows, Linux]
 - R version: [e.g. 4.1.0]
 - Package version: [e.g. 0.1.0]

**Additional context**
Add any other context about the problem here.
```

### Feature Request
```markdown
---
name: Feature request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: ['enhancement']
assignees: ''
---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

### Documentation Update
```markdown
---
name: Documentation update
about: Suggest improvements to documentation
title: '[DOCS] '
labels: ['documentation']
assignees: ''
---

**What documentation needs to be updated?**
A clear description of what documentation needs to be changed.

**Current state**
What the documentation currently says.

**Desired state**
What the documentation should say.

**Additional context**
Add any other context about the documentation issue here.
```

## Conclusion

These guidelines ensure consistent, efficient issue management for the zoomstudentengagement R package. Following these practices will help maintain a clean, organized issue tracker and support effective development workflow.

**Remember:** Good issue management is essential for successful open-source projects. These guidelines should be reviewed and updated regularly to ensure they remain relevant and effective. 