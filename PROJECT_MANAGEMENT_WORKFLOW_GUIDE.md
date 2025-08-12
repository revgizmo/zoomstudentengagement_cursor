# Project Management Workflow Guide
## Replicating the zoomstudentengagement System

This guide provides a complete template for setting up the project management workflow used in the `zoomstudentengagement` R package. This system combines GitHub Issues, dynamic context scripts, and comprehensive documentation to create an AI-friendly development environment.

## 🎯 **What This System Provides**

### For AI Assistants
- **Instant Context**: Real-time project status without manual investigation
- **Clear Priorities**: Automated issue prioritization and CRAN readiness tracking
- **Workflow Guidance**: Standardized development processes and commands
- **Error Prevention**: Built-in validation and compliance checks

### For Human Developers
- **Status Visibility**: Always-current project metrics and blockers
- **Issue Organization**: Structured labeling and priority system
- **Documentation**: Comprehensive guides and quick references
- **Automation**: Scripts that reduce manual status checking

## 📋 **Prerequisites**

Before implementing this system, ensure you have:

### Required Tools
- **GitHub CLI** (`gh`) - For issue management and API access
- **R** (for R packages) or equivalent language runtime
- **jq** - For JSON parsing in scripts
- **Git** - For version control

### Repository Setup
- GitHub repository with Issues enabled
- Branch protection rules configured
- Issue templates set up (optional but recommended)

## 🔧 **GitHub Repository Setup**

### Step 1: Create Repository
```bash
# Create new repository via GitHub CLI
gh repo create [PROJECT_NAME] --public --description "[PROJECT_DESCRIPTION]"

# Or create manually on GitHub.com and clone
git clone https://github.com/[USERNAME]/[PROJECT_NAME].git
cd [PROJECT_NAME]
```

### Step 2: Configure Branch Protection
Enable branch protection for the main branch:

**Via GitHub Web Interface:**
1. Go to Settings → Branches
2. Add rule for `main` branch
3. Configure these settings:
   - ✅ Require a pull request before merging
   - ✅ Require approvals (1 or more)
   - ✅ Dismiss stale PR approvals when new commits are pushed
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date before merging
   - ✅ Include administrators
   - ✅ Restrict pushes that create files larger than 100 MB

**Via GitHub CLI:**
```bash
# Create branch protection rule
gh api repos/[USERNAME]/[PROJECT_NAME]/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null
```

### Step 3: Set Up Issue Templates
Create `.github/ISSUE_TEMPLATE/` directory and add templates:

**Bug Report Template** (`.github/ISSUE_TEMPLATE/bug_report.md`):
```markdown
---
name: Bug Report
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

**Environment:**
 - OS: [e.g. macOS, Windows, Linux]
 - Version: [e.g. 1.0.0]
 - Language: [e.g. R, Python, JavaScript]

**Additional context**
Add any other context about the problem here.
```

**Feature Request Template** (`.github/ISSUE_TEMPLATE/feature_request.md`):
```markdown
---
name: Feature Request
about: Suggest an idea for this project
title: '[FEATURE] '
labels: ['enhancement']
assignees: ''
---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is.

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
```

### Step 4: Configure GitHub Actions (Optional)
Create `.github/workflows/ci.yml` for automated testing:

```yaml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up R
      uses: r-lib/actions/setup-r@v2
      with:
        r-version: 'release'
    
    - name: Install dependencies
      uses: r-lib/actions/setup-r-dependencies@v2
      with:
        packages: any::devtools, any::testthat, any::covr
    
    - name: Check package
      run: Rscript -e "devtools::check()"
    
    - name: Run tests
      run: Rscript -e "devtools::test()"
    
    - name: Check coverage
      run: Rscript -e "covr::package_coverage()"
```

### Step 5: Set Up Project Board (Optional)
Create a project board for issue tracking:

```bash
# Create project board
gh project create --title "[PROJECT_NAME] Development" --format json

# Add columns to project board
gh project column create [PROJECT_ID] --name "To Do"
gh project column create [PROJECT_ID] --name "In Progress"
gh project column create [PROJECT_ID] --name "Review"
gh project column create [PROJECT_ID] --name "Done"
```

### Step 6: Configure Repository Settings
**Via GitHub Web Interface:**
1. **General Settings:**
   - ✅ Allow forking
   - ✅ Allow squash merging
   - ✅ Allow rebase merging
   - ❌ Allow merge commits (optional)
   - ✅ Automatically delete head branches

2. **Issues Settings:**
   - ✅ Enable issues
   - ✅ Enable issue templates
   - ✅ Enable issue forms (if using)

3. **Pages Settings** (if applicable):
   - Source: Deploy from a branch
   - Branch: `gh-pages` or `main`
   - Folder: `/docs` or `/ (root)`

**Via GitHub CLI:**
```bash
# Enable squash merging
gh api repos/[USERNAME]/[PROJECT_NAME] \
  --method PATCH \
  --field allow_squash_merge=true \
  --field allow_rebase_merge=true \
  --field delete_branch_on_merge=true

# Enable issues
gh api repos/[USERNAME]/[PROJECT_NAME] \
  --method PATCH \
  --field has_issues=true
```

### Step 7: Set Up GitHub CLI Authentication
```bash
# Authenticate with GitHub
gh auth login

# Verify authentication
gh auth status

# Set default repository
gh repo set-default [USERNAME]/[PROJECT_NAME]
```

### Step 8: GitHub Workflow Best Practices

#### Branch Strategy
```bash
# Main branch (protected)
main                    # Production-ready code

# Development branches
develop                 # Integration branch (optional)
feature/issue-XX        # Feature branches
bugfix/issue-XX         # Bug fix branches
hotfix/issue-XX         # Emergency fixes
```

#### Commit Message Format
Use conventional commit messages:
```bash
# Format: type(scope): description
git commit -m "feat(core): Add new analysis function"
git commit -m "fix(testing): Resolve test failures"
git commit -m "docs(readme): Update installation instructions"
git commit -m "refactor(api): Standardize function names"
git commit -m "test(coverage): Add tests for edge cases"
```

#### Pull Request Workflow
```bash
# 1. Create feature branch
git checkout -b feature/issue-XX

# 2. Make changes and commit
git add .
git commit -m "feat(core): Address #XX - Add new feature"

# 3. Push to remote
git push -u origin feature/issue-XX

# 4. Create pull request
gh pr create --title "feat: Address #XX - Add new feature" --body "Fixes #XX - Implements requested feature"

# 5. Merge with admin override (if needed)
gh pr merge --auto --delete-branch --admin
```

#### Issue Management Workflow
```bash
# Create issue with labels
gh issue create --title "Add new analysis function" --body "Description" --label "enhancement,priority:medium,area:core"

# Update issue status
gh issue edit [NUMBER] --add-label "status:in-progress"

# Link PR to issue
gh pr create --title "feat: Address #XX" --body "Fixes #XX - Implements requested feature"

# Close issue when PR is merged
# (Automatically done when PR description contains "Fixes #XX")
```

#### Branch Protection Bypass Guidelines
When it's safe to bypass branch protection:
- All local checks pass (`devtools::check()` with 0 errors, 0 warnings)
- Tests pass (`devtools::test()`)
- Code coverage is adequate (>90%)
- Documentation is complete
- No spelling errors

```bash
# Bypass branch protection for auto-merge
gh pr merge --auto --delete-branch --admin
```

#### GitHub CLI Best Practices
```bash
# Always escape parentheses in gh pr create commands
gh pr create --title "fix: Address lintr warnings" --body "Use seq_len\(\) instead of 1:nrow\(\)"

# Or use single quotes to avoid escaping
gh pr create --title "fix: Address lintr warnings" --body 'Use seq_len() instead of 1:nrow()'

# Use --admin flag when merging with branch protection
gh pr merge <PR_NUMBER> --merge --admin
```

### Step 9: AI-Friendly Repository Setup

#### Create .cursor Directory
```bash
# Create directory for AI context files
mkdir -p .cursor

# Add to .gitignore to avoid committing context files
echo ".cursor/" >> .gitignore
echo "*.backup.*" >> .gitignore
```

#### Set Up Context Scripts
Create the context scripts that provide real-time project status:

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Test context generation
./scripts/context-for-new-chat.sh

# Save context for AI linking
./scripts/save-context.sh
```

#### Configure Cursor Integration
For optimal AI assistant integration:

1. **Link Context Files**: In Cursor chats, link context files using:
   - `@context.md` - Shell context
   - `@r-context.md` - R-specific context  
   - `@full-context.md` - Combined context

2. **Update Context Regularly**: Run context scripts before starting work:
   ```bash
   ./scripts/save-context.sh
   ```

3. **Use Context in AI Prompts**: Include context in AI assistant prompts:
   ```
   Please review the current project status in @full-context.md and help me with [specific task].
   ```

#### Repository Metadata
Add repository metadata for better AI understanding:

**Create `.github/ISSUE_TEMPLATE/config.yml`:**
```yaml
blank_issues_enabled: false
contact_links:
  - name: Project Documentation
    url: https://github.com/[USERNAME]/[PROJECT_NAME]/blob/main/README.md
    about: Please read the documentation before creating an issue.
  - name: Development Guide
    url: https://github.com/[USERNAME]/[PROJECT_NAME]/blob/main/CONTRIBUTING.md
    about: Please read the contributing guidelines.
```

**Create `.github/FUNDING.yml` (if applicable):**
```yaml
github: [USERNAME]
patreon: [PATREON_USERNAME]
open_collective: [PROJECT_NAME]
ko_fi: [KO_FI_USERNAME]
tidelift: [TIDELIFT_LINK]
community_bridge: [COMMUNITY_BRIDGE_LINK]
liberapay: [LIBERAPAY_USERNAME]
issuehunt: [ISSUEHUNT_USERNAME]
otechie: [OTECHIE_USERNAME]
custom: [CUSTOM_LINK]
```

#### Repository Description and Topics
Set up repository metadata for discoverability:

```bash
# Update repository description
gh repo edit --description "[PROJECT_DESCRIPTION]"

# Add topics for discoverability
gh repo edit --add-topic "r-package,data-analysis,education,zoom,student-engagement"

# Enable features
gh repo edit --enable-issues --enable-wiki --enable-projects
```

## 🏗️ **System Architecture**

### Core Components
1. **PROJECT.md** - Central status document with dynamic sections
2. **Context Scripts** - Real-time status checking and reporting
3. **Issue Management** - Structured labeling and priority system
4. **Quick Reference** - Essential workflow documentation
5. **Development Scripts** - Automation and validation tools

### File Structure
```
project-root/
├── PROJECT.md                           # Central status document
├── ISSUE_MANAGEMENT_QUICK_REFERENCE.md  # Workflow guide
├── CONTRIBUTING.md                      # Contribution guidelines
├── scripts/
│   ├── context-for-new-chat.sh         # Shell context script
│   ├── context-for-new-chat.R          # Language-specific context
│   ├── save-context.sh                 # Context file saver
│   ├── get-context.sh                  # Combined context
│   └── pre-pr-validation.R             # Pre-PR checks
├── .cursor/
│   ├── context.md                      # Saved shell context
│   ├── r-context.md                    # Saved R context
│   └── full-context.md                 # Combined context
└── docs/
    └── development/
        ├── CONTEXT_SCRIPTS_DOCUMENTATION.md
        ├── ISSUE_MANAGEMENT_GUIDELINES.md
        └── AUDIT_LOG.md
```

## 🚀 **Implementation Steps**

### Step 1: Create Core Documentation

#### PROJECT.md Template
Create a central status document with these sections:

```markdown
# Project Plan: [PROJECT_NAME]

> **🤖 For AI Assistants**: Before starting work, run `./scripts/save-context.sh` to get current project status and avoid working on already-resolved issues.

## Overview
[Brief project description and goals]

## Current Status (Updated: [DATE])
**Project Status: [STATUS]**

### What's Working ✅
- [Key achievements and working components]

### What Needs Work ❌
- [Critical issues and blockers]

### Active Issues
- [List of high-priority issues with links]

### Completed Issues ✅
- [Recently completed work]

## Development Workflow
[Standard development process]

## CRAN/Release Readiness
[Release preparation status and checklist]

## Context Scripts
[Information about the context system]

## Milestones & Timeline
[Project milestones and deadlines]
```

#### ISSUE_MANAGEMENT_QUICK_REFERENCE.md
Create a quick reference for issue management:

```markdown
# Issue Management Quick Reference
## [PROJECT_NAME]

**For AI Users** - Keep this file open when working with issues

## 🎯 Priority System
[Define your priority levels and labels]

## 📋 Issue Templates
[Standard templates for different issue types]

## 🔗 Workflow
[Standard development workflow]

## 🏷️ Essential Labels
[Required labels and their meanings]

## 📝 Commit Message Format
[Standard commit message format]

## 🚨 Release Checklist
[Pre-release validation steps]
```

### Step 2: Set Up Context Scripts

#### Shell Context Script (`scripts/context-for-new-chat.sh`)
Create a script that provides real-time project status:

```bash
#!/bin/bash

# Context Script for [PROJECT_NAME]
# Use this script to provide current project context to new AI chats

set -eo pipefail
trap 'echo "❌ Script failed at line $LINENO"' ERR

echo "🔍 Generating context for [PROJECT_NAME]..."
echo "=================================================="

# Validate dependencies
echo "🔍 Validating dependencies..."
[validation code]

# Get current status
echo "📅 Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "🌿 Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo "📊 Uncommitted changes: $(git status --porcelain | wc -l | tr -d ' ')"

# 1. Project Status Summary
echo "🎯 PROJECT STATUS SUMMARY"
echo "------------------------"
[status checking code]

# 2. Key Metrics
echo "📈 KEY METRICS"
echo "-------------"
[metrics checking code]

# 3. Critical Issues
echo "🚨 CRITICAL ISSUES (High Priority)"
echo "--------------------------------"
[issue fetching code]

# 4. Recent Activity
echo "🕒 RECENT ACTIVITY"
echo "----------------"
[recent activity code]

# 5. Essential Files
echo "📁 ESSENTIAL FILES TO REVIEW"
echo "---------------------------"
[file listing]

# 6. Development Focus
echo "🎯 CURRENT DEVELOPMENT FOCUS"
echo "---------------------------"
[focus determination]

# 7. Quick Commands
echo "⚡ QUICK COMMANDS FOR CONTEXT"
echo "---------------------------"
[useful commands]

# 8. Project Structure
echo "📂 PROJECT STRUCTURE"
echo "-------------------"
[structure overview]

# 9. Development Workflow
echo "🔄 DEVELOPMENT WORKFLOW"
echo "---------------------"
[workflow steps]

# 10. Release Readiness
echo "📦 RELEASE READINESS STATUS"
echo "-------------------------"
[readiness assessment]

# 11. Next Steps
echo "🎯 IMMEDIATE NEXT STEPS"
echo "---------------------"
[actionable steps]

echo "=================================================="
echo "💡 TIP: Copy the output above and paste it into your new AI chat"
echo "=================================================="
```

#### Language-Specific Context Script
Create a script for your specific language/framework:

```r
# Context Script for [PROJECT_NAME] R Package
# Use this script to provide R-specific project context

cat("🔍 Generating R context for [PROJECT_NAME]...\n")
cat("==================================================\n\n")

# Package loading status
cat("📦 PACKAGE LOADING STATUS\n")
cat("------------------------\n")
[package loading code]

# Test status
cat("🧪 TEST STATUS\n")
cat("-------------\n")
[test checking code]

# Coverage status
cat("📊 TEST COVERAGE\n")
cat("---------------\n")
[coverage checking code]

# Package structure
cat("📂 PACKAGE STRUCTURE\n")
cat("------------------\n")
[structure analysis]

# Quick health check commands
cat("⚡ QUICK HEALTH CHECK COMMANDS\n")
cat("----------------------------\n")
[useful commands]

cat("==================================================\n")
```

#### Context File Saver (`scripts/save-context.sh`)
Create a script to save context for AI linking:

```bash
#!/bin/bash

# Save context output to files for linking in AI chats
# Usage: ./scripts/save-context.sh

set -euo pipefail
trap 'echo "❌ Script failed at line $LINENO"' ERR

echo "💾 Saving context output to files for linking..."
echo "=================================================="

# Validate dependencies and scripts
echo "🔍 Validating dependencies and scripts..."
[validation code]

# Create .cursor directory
echo "📁 Creating .cursor directory..."
mkdir -p .cursor

# Backup existing files
echo "💾 Backing up existing context files..."
[backup code]

# Save shell context
echo "📝 Saving shell context to .cursor/context.md..."
./scripts/context-for-new-chat.sh > .cursor/context.md

# Save language-specific context
echo "📝 Saving [LANGUAGE] context to .cursor/[LANGUAGE]-context.md..."
[LANGUAGE_SCRIPT] > .cursor/[LANGUAGE]-context.md

# Save combined context
echo "📝 Saving combined context to .cursor/full-context.md..."
./scripts/get-context.sh > .cursor/full-context.md

echo "✅ All context files saved successfully!"
echo "=================================================="
echo "📁 Context files saved:"
echo "   • .cursor/context.md - Shell context (link with @context.md)"
echo "   • .cursor/[LANGUAGE]-context.md - [LANGUAGE] context (link with @[LANGUAGE]-context.md)"
echo "   • .cursor/full-context.md - Combined context (link with @full-context.md)"
echo ""
echo "💡 Usage in AI chats:"
echo "   • Link shell context: @context.md"
echo "   • Link [LANGUAGE] context: @[LANGUAGE]-context.md"
echo "   • Link full context: @full-context.md"
echo "=================================================="
```

### Step 3: Set Up Issue Management

#### GitHub Labels
Create these essential labels in your repository:

**Priority Labels:**
- `priority:high` - Must fix before release
- `priority:medium` - Important features
- `priority:low` - Nice to have

**Area Labels:**
- `area:core` - Core functionality
- `area:testing` - Test infrastructure
- `area:documentation` - Documentation
- `area:performance` - Performance issues
- `area:security` - Security concerns

**Status Labels:**
- `status:blocked` - Blocked by other issues
- `status:in-progress` - Currently being worked on
- `status:needs-review` - Ready for review

**Release Labels:**
- `release:blocker` - Blocks next release
- `release:next` - Planned for next release
- `release:future` - Future consideration

#### Issue Templates
Create templates for different issue types:

**Bug Report Template:**
```markdown
**Bug:** [Brief description]

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]

**Expected Behavior:** [What should happen]
**Actual Behavior:** [What happens]

**Environment:** [OS, version, etc.]
```

**Feature Request Template:**
```markdown
**Feature:** [Brief description]

**Use Case:** [Why this is needed]

**Proposed Solution:** [How it should work]

**Alternatives Considered:** [Other approaches]
```

### Step 4: Create Development Scripts

#### Pre-PR Validation Script
Create a script for pre-pull request validation:

```r
# Pre-PR Validation Script for [PROJECT_NAME]
# Run this before creating pull requests

cat("🔍 Running pre-PR validation...\n")
cat("==================================================\n\n")

# Phase 1: Code Quality
cat("📝 Phase 1: Code Quality\n")
cat("----------------------\n")
[code quality checks]

# Phase 2: Documentation
cat("📚 Phase 2: Documentation\n")
cat("------------------------\n")
[documentation checks]

# Phase 3: Testing
cat("🧪 Phase 3: Testing\n")
cat("-----------------\n")
[testing checks]

# Phase 4: Final Validation
cat("✅ Phase 4: Final Validation\n")
cat("---------------------------\n")
[final checks]

cat("==================================================\n")
cat("🎉 Pre-PR validation complete!\n")
```

### Step 5: Set Up Documentation

#### CONTRIBUTING.md
Create contribution guidelines:

```markdown
# Contributing to [PROJECT_NAME]

## Development Workflow

### Before Starting Work
1. Run `./scripts/save-context.sh` to get current status
2. Check existing issues to avoid duplication
3. Create a feature branch: `git checkout -b feature/issue-XX`

### During Development
1. Follow the coding standards
2. Write tests for new functionality
3. Update documentation as needed
4. Run pre-PR validation: `Rscript scripts/pre-pr-validation.R`

### Creating Pull Requests
1. Ensure all tests pass
2. Update documentation
3. Create PR with descriptive title
4. Link to issues using `Fixes #X`

## Code Standards
[Your coding standards]

## Testing Requirements
[Testing requirements]

## Documentation Standards
[Documentation requirements]
```

## 🔧 **Customization Guide**

### For Different Project Types

#### R Package Projects
- Use R-specific context scripts
- Include CRAN submission checks
- Add package-specific metrics (test coverage, R CMD check)
- Include vignette and documentation checks

#### Python Package Projects
- Replace R scripts with Python equivalents
- Include PyPI submission checks
- Add Python-specific metrics (test coverage, linting)
- Include documentation generation checks

#### Web Application Projects
- Include deployment status checks
- Add performance metrics
- Include security scanning
- Add user acceptance testing status

#### Library/Framework Projects
- Include API documentation checks
- Add backward compatibility checks
- Include performance benchmarking
- Add integration testing status

### For Different Team Sizes

#### Solo Developer
- Simplified workflow
- Focus on automation
- Minimal overhead
- Quick context updates

#### Small Team (2-5 developers)
- Standard workflow
- Code review requirements
- Issue assignment
- Regular status updates

#### Large Team (5+ developers)
- Enhanced workflow
- Multiple review stages
- Automated CI/CD integration
- Detailed reporting

### For Different Release Cycles

#### Rapid Release (Weekly/Monthly)
- Automated release preparation
- Quick validation scripts
- Minimal manual steps
- Automated changelog generation

#### Standard Release (Quarterly)
- Comprehensive validation
- Manual review steps
- Detailed release notes
- Extended testing period

#### Long-term Release (6+ months)
- Extensive validation
- Multiple review cycles
- Comprehensive documentation
- Extended beta testing

## 📊 **Metrics and KPIs**

### Essential Metrics
- **Test Coverage**: Target 90%+
- **Build Status**: 0 errors, 0 warnings
- **Issue Resolution Time**: Track average time to close
- **Release Readiness**: Percentage of blockers resolved

### Optional Metrics
- **Code Quality**: Linting scores, complexity metrics
- **Performance**: Benchmark results, memory usage
- **Security**: Vulnerability scan results
- **Documentation**: Coverage and freshness

## 🚨 **Troubleshooting**

### Common Issues

#### Context Scripts Not Working
- Check dependencies are installed
- Verify file permissions
- Check GitHub API access
- Validate script syntax

#### Issues Not Updating
- Check GitHub CLI authentication
- Verify label names match exactly
- Check network connectivity
- Validate JSON parsing

#### PROJECT.md Out of Sync
- Run `./scripts/save-context.sh --fix-project-md`
- Check for manual edits
- Verify section markers
- Review backup files

### Debug Mode
```bash
# Enable debug output
bash -x ./scripts/context-for-new-chat.sh

# Check specific components
gh issue list --limit 5
Rscript -e "devtools::test()"
```

## 🔄 **Maintenance**

### Regular Tasks
- **Weekly**: Update context scripts with new features
- **Monthly**: Review and update issue labels
- **Quarterly**: Audit and improve documentation
- **Annually**: Review and optimize workflow

### Continuous Improvement
- Monitor script performance
- Collect user feedback
- Track issue resolution efficiency
- Optimize automation

## 📚 **Resources**

### Documentation
- [GitHub Issues Documentation](https://docs.github.com/en/issues)
- [GitHub CLI Documentation](https://cli.github.com/)
- [R Package Development](https://r-pkgs.org/) (for R projects)
- [Python Packaging](https://packaging.python.org/) (for Python projects)

### Tools
- [GitHub CLI](https://cli.github.com/) - Issue management
- [jq](https://stedolan.github.io/jq/) - JSON processing
- [devtools](https://devtools.r-lib.org/) - R development tools
- [pytest](https://docs.pytest.org/) - Python testing

## 🎯 **Success Metrics**

### Implementation Success
- [ ] Context scripts provide accurate, current information
- [ ] Issues are properly organized and prioritized
- [ ] Development workflow is clear and followed
- [ ] Release process is streamlined and reliable

### Team Adoption
- [ ] All team members use context scripts
- [ ] Issues are consistently labeled and updated
- [ ] Pull requests follow the standard workflow
- [ ] Documentation is kept current

### Project Health
- [ ] Test coverage meets targets
- [ ] Build status is consistently clean
- [ ] Issues are resolved in reasonable time
- [ ] Releases are delivered on schedule

---

**Template Version**: 1.0.0
**Based on**: zoomstudentengagement R package workflow
**Last Updated**: 2025-08-11
**Maintainer**: [Your Name/Team]
