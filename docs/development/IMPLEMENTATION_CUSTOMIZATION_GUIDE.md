# Implementation Customization Guide
## Specific Questions and Implementation Details

This companion document provides specific questions to help you customize the project management workflow for your particular project, along with detailed implementation examples.

## 🤔 **Customization Questions**

### Project Type & Goals
1. **What type of project is this?**
   - [ ] R Package (like zoomstudentengagement)
   - [ ] Python Package
   - [ ] Web Application
   - [ ] Library/Framework
   - [ ] Documentation Site
   - [ ] Other: _______________

2. **What is your primary goal?**
   - [ ] CRAN/PyPI submission
   - [ ] Production deployment
   - [ ] Research publication
   - [ ] Internal tool
   - [ ] Open source release
   - [ ] Other: _______________

3. **What is your target audience?**
   - [ ] Academic researchers
   - [ ] Software developers
   - [ ] End users
   - [ ] Internal team
   - [ ] Open source community
   - [ ] Other: _______________

### Team & Workflow
4. **Team size and structure:**
   - [ ] Solo developer
   - [ ] Small team (2-5 people)
   - [ ] Large team (5+ people)
   - [ ] Distributed team
   - [ ] Open source contributors

5. **Release cycle:**
   - [ ] Rapid (weekly/monthly)
   - [ ] Standard (quarterly)
   - [ ] Long-term (6+ months)
   - [ ] Continuous deployment
   - [ ] On-demand

6. **Development environment:**
   - [ ] Local development only
   - [ ] CI/CD pipeline
   - [ ] Cloud-based development
   - [ ] Hybrid approach

### Technical Requirements
7. **Primary programming language:**
   - [ ] R
   - [ ] Python
   - [ ] JavaScript/TypeScript
   - [ ] Java
   - [ ] C/C++
   - [ ] Other: _______________

8. **Testing framework:**
   - [ ] testthat (R)
   - [ ] pytest (Python)
   - [ ] Jest (JavaScript)
   - [ ] JUnit (Java)
   - [ ] Custom framework
   - [ ] Other: _______________

9. **Documentation system:**
   - [ ] Roxygen2 (R)
   - [ ] Sphinx (Python)
   - [ ] JSDoc (JavaScript)
   - [ ] Javadoc (Java)
   - [ ] Markdown only
   - [ ] Other: _______________

### Compliance & Standards
10. **Compliance requirements:**
    - [ ] FERPA (educational data)
    - [ ] HIPAA (health data)
    - [ ] GDPR (privacy)
    - [ ] SOX (financial)
    - [ ] None
    - [ ] Other: _______________

11. **Quality standards:**
    - [ ] CRAN standards (R)
    - [ ] PyPI standards (Python)
    - [ ] npm standards (JavaScript)
    - [ ] Custom standards
    - [ ] None specified

### GitHub & Repository Setup
12. **Repository visibility:**
    - [ ] Public (open source)
    - [ ] Private (internal use)
    - [ ] Organization repository
    - [ ] Fork of existing project

13. **Branch protection requirements:**
    - [ ] Require pull request reviews
    - [ ] Require status checks
    - [ ] Require up-to-date branches
    - [ ] Include administrators
    - [ ] Restrict file size uploads

14. **CI/CD requirements:**
    - [ ] GitHub Actions for testing
    - [ ] Automated deployment
    - [ ] Code quality checks
    - [ ] Security scanning
    - [ ] Documentation generation

15. **Issue management:**
    - [ ] Issue templates
    - [ ] Project boards
    - [ ] Milestone tracking
    - [ ] Automated labeling
    - [ ] Issue forms

## 🛠️ **Implementation Examples**

## 🔧 **GitHub Setup Examples**

### Repository Creation Script
Create a script to set up a new repository with all the required configuration:

```bash
#!/bin/bash

# GitHub Repository Setup Script
# Usage: ./setup-github-repo.sh [PROJECT_NAME] [DESCRIPTION]

set -euo pipefail

PROJECT_NAME="${1:-}"
DESCRIPTION="${2:-}"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 [PROJECT_NAME] [DESCRIPTION]"
    exit 1
fi

echo "🔧 Setting up GitHub repository for $PROJECT_NAME..."
echo "=================================================="

# Create repository
echo "📝 Creating repository..."
gh repo create "$PROJECT_NAME" --public --description "$DESCRIPTION" --clone

cd "$PROJECT_NAME"

# Set up branch protection
echo "🛡️ Setting up branch protection..."
gh api repos/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":[]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null

# Create issue templates
echo "📋 Creating issue templates..."
mkdir -p .github/ISSUE_TEMPLATE

cat > .github/ISSUE_TEMPLATE/bug_report.md << 'EOF'
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

**Environment:**
 - OS: [e.g. macOS, Windows, Linux]
 - Version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
EOF

cat > .github/ISSUE_TEMPLATE/feature_request.md << 'EOF'
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
EOF

# Create labels
echo "🏷️ Creating labels..."
gh label create "priority:high" --color "d73a4a" --description "Must fix before release"
gh label create "priority:medium" --color "fbca04" --description "Important features"
gh label create "priority:low" --color "0e8a16" --description "Nice to have"
gh label create "area:core" --color "1d76db" --description "Core functionality"
gh label create "area:testing" --color "5319e7" --description "Test infrastructure"
gh label create "area:documentation" --color "0075ca" --description "Documentation"
gh label create "bug" --color "d73a4a" --description "Something broken"
gh label create "enhancement" --color "1d76db" --description "New feature"
gh label create "refactor" --color "5319e7" --description "Code cleanup"

# Set up repository settings
echo "⚙️ Configuring repository settings..."
gh api repos/$(gh repo view --json owner,name -q '.owner.login + "/" + .name') \
  --method PATCH \
  --field allow_squash_merge=true \
  --field allow_rebase_merge=true \
  --field delete_branch_on_merge=true \
  --field has_issues=true \
  --field has_wiki=true \
  --field has_projects=true

echo "✅ GitHub repository setup complete!"
echo "📁 Repository: https://github.com/$(gh repo view --json owner,name -q '.owner.login + "/" + .name')"
```

### GitHub Actions Workflow Templates

#### R Package CI/CD
```yaml
# .github/workflows/r-package-ci.yml
name: R Package CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  r-package:
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
        packages: any::devtools, any::testthat, any::covr, any::lintr
    
    - name: Check package
      run: Rscript -e "devtools::check()"
    
    - name: Run tests
      run: Rscript -e "devtools::test()"
    
    - name: Check coverage
      run: Rscript -e "covr::package_coverage()"
    
    - name: Lint code
      run: Rscript -e "lintr::lint_package()"
```

#### Python Package CI/CD
```yaml
# .github/workflows/python-package-ci.yml
name: Python Package CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  python-package:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.9'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install pytest pytest-cov flake8 black
        pip install -e .
    
    - name: Run tests
      run: |
        pytest --cov=[PACKAGE_NAME] --cov-report=xml
    
    - name: Check code style
      run: |
        flake8 [PACKAGE_NAME] tests
        black --check [PACKAGE_NAME] tests
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```

#### Web Application CI/CD
```yaml
# .github/workflows/web-app-ci.yml
name: Web Application CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  web-app:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Build application
      run: npm run build
    
    - name: Check code style
      run: npm run lint
    
    - name: Security audit
      run: npm audit --audit-level moderate
```

### R Package Implementation

#### Context Script Template (`scripts/context-for-new-chat.R`)
```r
#!/usr/bin/env Rscript

# Context Script for [PROJECT_NAME] R Package
# Use this script to provide R-specific project context

suppressPackageStartupMessages({
  library(tools)
  library(utils)
})

cat("🔍 Generating R context for [PROJECT_NAME]...\n")
cat("==================================================\n\n")

# Package loading status
cat("📦 PACKAGE LOADING STATUS\n")
cat("------------------------\n")
tryCatch({
  devtools::load_all(quiet = TRUE)
  cat("✅ Package loads successfully\n")
}, error = function(e) {
  cat("❌ Package fails to load: ", e$message, "\n")
})

# Test status
cat("\n🧪 TEST STATUS\n")
cat("-------------\n")
tryCatch({
  test_output <- capture.output(devtools::test(quiet = TRUE))
  test_summary <- tail(test_output, 1)
  cat("Test Summary: ", test_summary, "\n")
}, error = function(e) {
  cat("❌ Tests failed: ", e$message, "\n")
})

# Coverage status
cat("\n📊 TEST COVERAGE\n")
cat("---------------\n")
tryCatch({
  if (require(covr, quietly = TRUE)) {
    cov <- covr::package_coverage()
    coverage_pct <- round(covr::percent_coverage(cov), 2)
    cat("Coverage: ", coverage_pct, "%\n")
    
    # Show low coverage files
    low_coverage <- covr::coverage_to_list(cov)
    low_files <- names(low_coverage)[sapply(low_coverage, function(x) x < 80)]
    if (length(low_files) > 0) {
      cat("Low coverage files (<80%):\n")
      for (file in low_files) {
        cat("  • ", file, "\n")
      }
    }
  } else {
    cat("⚠️  covr package not available\n")
  }
}, error = function(e) {
  cat("❌ Coverage check failed: ", e$message, "\n")
})

# R CMD check status
cat("\n🔍 R CMD CHECK STATUS\n")
cat("-------------------\n")
tryCatch({
  check_output <- capture.output(devtools::check(quiet = TRUE), type = "message")
  check_summary <- tail(check_output, 1)
  cat("Check Summary: ", check_summary, "\n")
}, error = function(e) {
  cat("❌ R CMD check failed: ", e$message, "\n")
})

# Package structure
cat("\n📂 PACKAGE STRUCTURE\n")
cat("------------------\n")
if (file.exists("DESCRIPTION")) {
  desc <- read.dcf("DESCRIPTION")
  cat("Package: ", desc[1, "Package"], "\n")
  cat("Version: ", desc[1, "Version"], "\n")
  cat("Title: ", desc[1, "Title"], "\n")
}

# Count files
r_files <- length(list.files("R", pattern = "\\.R$", recursive = TRUE))
test_files <- length(list.files("tests/testthat", pattern = "\\.R$", recursive = TRUE))
man_files <- length(list.files("man", pattern = "\\.Rd$", recursive = TRUE))

cat("R files: ", r_files, "\n")
cat("Test files: ", test_files, "\n")
cat("Documentation files: ", man_files, "\n")

# Quick health check commands
cat("\n⚡ QUICK HEALTH CHECK COMMANDS\n")
cat("----------------------------\n")
cat("devtools::load_all()           # Load package\n")
cat("devtools::test()               # Run tests\n")
cat("devtools::check()              # Full check\n")
cat("covr::package_coverage()       # Check coverage\n")
cat("devtools::document()           # Update docs\n")
cat("devtools::build()              # Build package\n")

cat("\n==================================================\n")
```

### Python Package Implementation

#### Context Script Template (`scripts/context-for-new-chat.py`)
```python
#!/usr/bin/env python3

"""
Context Script for [PROJECT_NAME] Python Package
Use this script to provide Python-specific project context
"""

import os
import sys
import subprocess
import json
from pathlib import Path

def run_command(cmd, capture_output=True):
    """Run a command and return the result."""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=capture_output, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)

def main():
    print("🔍 Generating Python context for [PROJECT_NAME]...")
    print("=" * 50)
    print()

    # Package loading status
    print("📦 PACKAGE LOADING STATUS")
    print("-" * 24)
    success, stdout, stderr = run_command("python -c 'import [PACKAGE_NAME]; print(\"✅ Package loads successfully\")'")
    if not success:
        print(f"❌ Package fails to load: {stderr}")

    # Test status
    print("\n🧪 TEST STATUS")
    print("-" * 12)
    success, stdout, stderr = run_command("python -m pytest --tb=short")
    if success:
        print("✅ Tests pass")
    else:
        print(f"❌ Tests failed: {stderr}")

    # Coverage status
    print("\n📊 TEST COVERAGE")
    print("-" * 15)
    success, stdout, stderr = run_command("python -m pytest --cov=[PACKAGE_NAME] --cov-report=term-missing")
    if success:
        # Extract coverage percentage
        for line in stdout.split('\n'):
            if 'TOTAL' in line:
                print(f"Coverage: {line}")
                break
    else:
        print("⚠️  Coverage check failed")

    # Package structure
    print("\n📂 PACKAGE STRUCTURE")
    print("-" * 18)
    if os.path.exists("setup.py"):
        print("✅ setup.py found")
    if os.path.exists("pyproject.toml"):
        print("✅ pyproject.toml found")
    
    # Count files
    python_files = len(list(Path(".").rglob("*.py")))
    test_files = len(list(Path("tests").rglob("*.py")))
    print(f"Python files: {python_files}")
    print(f"Test files: {test_files}")

    # Quick health check commands
    print("\n⚡ QUICK HEALTH CHECK COMMANDS")
    print("-" * 29)
    print("python -m pytest                    # Run tests")
    print("python -m pytest --cov=[PACKAGE]    # Check coverage")
    print("python setup.py test                # Run setup tests")
    print("python -m build                     # Build package")
    print("python -m twine check dist/*        # Check distribution")

    print("\n" + "=" * 50)

if __name__ == "__main__":
    main()
```

### Web Application Implementation

#### Context Script Template (`scripts/context-for-new-chat.sh` for web apps)
```bash
#!/bin/bash

# Context Script for [PROJECT_NAME] Web Application
# Use this script to provide web app project context

set -eo pipefail
trap 'echo "❌ Script failed at line $LINENO"' ERR

echo "🔍 Generating context for [PROJECT_NAME] Web App..."
echo "=================================================="

# Validate dependencies
echo "🔍 Validating dependencies..."
if ! command -v node &> /dev/null; then
    echo "❌ Error: Node.js not found"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ Error: npm not found"
    exit 1
fi

# Get current status
echo "📅 Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
echo "🌿 Branch: $(git branch --show-current 2>/dev/null || echo 'unknown')"
echo "📊 Uncommitted changes: $(git status --porcelain | wc -l | tr -d ' ')"

# 1. Project Status Summary
echo "🎯 PROJECT STATUS SUMMARY"
echo "------------------------"
if [ -f "package.json" ]; then
    PROJECT_NAME=$(jq -r '.name' package.json 2>/dev/null || echo "unknown")
    PROJECT_VERSION=$(jq -r '.version' package.json 2>/dev/null || echo "unknown")
    echo "Project: $PROJECT_NAME"
    echo "Version: $PROJECT_VERSION"
else
    echo "❌ package.json not found"
fi

# 2. Key Metrics
echo "📈 KEY METRICS"
echo "-------------"

# Test status
echo "🔍 Checking test status..."
if npm test --silent 2>/dev/null; then
    echo "Test Status: PASSING"
else
    echo "Test Status: FAILING"
fi

# Build status
echo "🔍 Checking build status..."
if npm run build --silent 2>/dev/null; then
    echo "Build Status: SUCCESS"
else
    echo "Build Status: FAILED"
fi

# Dependency status
echo "🔍 Checking dependencies..."
OUTDATED_COUNT=$(npm outdated --json 2>/dev/null | jq length 2>/dev/null || echo "0")
echo "Outdated Dependencies: $OUTDATED_COUNT"

# 3. Critical Issues
echo "🚨 CRITICAL ISSUES (High Priority)"
echo "--------------------------------"
gh issue list --label "priority:high" --limit 5 --json number,title,labels --jq '.[] | "#\(.number): \(.title)"' 2>/dev/null || echo "Unable to fetch high priority issues"

# 4. Recent Activity
echo "🕒 RECENT ACTIVITY (Last 5 Issues)"
echo "--------------------------------"
gh issue list --limit 5 --json number,title,state,createdAt --jq '.[] | "#\(.number): \(.title) (\(.state))"' 2>/dev/null || echo "Unable to fetch recent issues"

# 5. Essential Files
echo "📁 ESSENTIAL FILES TO REVIEW"
echo "---------------------------"
echo "• README.md - Project overview and setup"
echo "• package.json - Dependencies and scripts"
echo "• .env.example - Environment variables"
echo "• docker-compose.yml - Development environment"
echo "• docs/ - Documentation"

# 6. Development Focus
echo "🎯 CURRENT DEVELOPMENT FOCUS"
echo "---------------------------"
HIGH_PRIORITY_COUNT=$(gh issue list --label "priority:high" --json number | jq length 2>/dev/null || echo "0")
DEPLOYMENT_ISSUES=$(gh issue list --label "deployment" --json number | jq length 2>/dev/null || echo "0")

if [ "$HIGH_PRIORITY_COUNT" -gt 0 ]; then
    echo "1. High Priority Issues ($HIGH_PRIORITY_COUNT issues)"
fi
if [ "$DEPLOYMENT_ISSUES" -gt 0 ]; then
    echo "2. Deployment Issues ($DEPLOYMENT_ISSUES issues)"
fi
echo "3. Frontend Development"
echo "4. Backend API"
echo "5. Testing and Documentation"

# 7. Quick Commands
echo "⚡ QUICK COMMANDS FOR CONTEXT"
echo "---------------------------"
echo "# Check current status:"
echo "npm test"
echo "npm run build"
echo "npm run lint"
echo ""
echo "# View recent issues:"
echo "gh issue list --limit 10"
echo ""
echo "# Check specific issue:"
echo "gh issue view <ISSUE_NUMBER>"

# 8. Project Structure
echo "📂 PROJECT STRUCTURE"
echo "-------------------"
if [ -d "src" ]; then
    echo "src/ - Source code ($(find src -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" | wc -l | tr -d ' ') files)"
fi
if [ -d "tests" ]; then
    echo "tests/ - Test files ($(find tests -name "*.js" -o -name "*.ts" | wc -l | tr -d ' ') files)"
fi
if [ -d "docs" ]; then
    echo "docs/ - Documentation ($(find docs -name "*.md" | wc -l | tr -d ' ') files)"
fi
echo "public/ - Static assets"
echo "scripts/ - Development utilities"

# 9. Development Workflow
echo "🔄 DEVELOPMENT WORKFLOW"
echo "---------------------"
echo "1. Check current issues: gh issue list"
echo "2. Create feature branch: git checkout -b feature/issue-XX"
echo "3. Install dependencies: npm install"
echo "4. Make changes and test: npm test"
echo "5. Run linting: npm run lint"
echo "6. Create PR: gh pr create --title 'fix: Address #XX'"
echo "7. Merge with admin: gh pr merge --admin"

# 10. Deployment Readiness
echo "📦 DEPLOYMENT READINESS STATUS"
echo "----------------------------"
if npm run build --silent 2>/dev/null; then
    echo "✅ Build: SUCCESS"
else
    echo "❌ Build: FAILED"
fi

if npm test --silent 2>/dev/null; then
    echo "✅ Tests: PASSING"
else
    echo "❌ Tests: FAILING"
fi

if [ "$OUTDATED_COUNT" = "0" ]; then
    echo "✅ Dependencies: UP TO DATE"
else
    echo "⚠️  Dependencies: $OUTDATED_COUNT outdated"
fi

# 11. Next Steps
echo "🎯 IMMEDIATE NEXT STEPS"
echo "---------------------"
if [ "$HIGH_PRIORITY_COUNT" -gt 0 ]; then
    echo "1. Address high priority issues ($HIGH_PRIORITY_COUNT issues)"
fi
if [ "$OUTDATED_COUNT" != "0" ]; then
    echo "2. Update dependencies ($OUTDATED_COUNT outdated)"
fi
echo "3. Complete current sprint tasks"
echo "4. Update documentation"
echo "5. Prepare for deployment"

echo "=================================================="
echo "💡 TIP: Copy the output above and paste it into your new AI chat"
echo "=================================================="
```

## 📋 **Label Customization**

### Standard Label Set
Create these labels in your GitHub repository:

```bash
# Priority labels
gh label create "priority:high" --color "d73a4a" --description "Must fix before release"
gh label create "priority:medium" --color "fbca04" --description "Important features"
gh label create "priority:low" --color "0e8a16" --description "Nice to have"

# Area labels
gh label create "area:core" --color "1d76db" --description "Core functionality"
gh label create "area:testing" --color "5319e7" --description "Test infrastructure"
gh label create "area:documentation" --color "0075ca" --description "Documentation"
gh label create "area:performance" --color "d93f0b" --description "Performance issues"
gh label create "area:security" --color "b60205" --description "Security concerns"
gh label create "area:ui" --color "c2e0c6" --description "User interface"
gh label create "area:api" --color "fef2c0" --description "API changes"

# Status labels
gh label create "status:blocked" --color "d93f0b" --description "Blocked by other issues"
gh label create "status:in-progress" --color "fbca04" --description "Currently being worked on"
gh label create "status:needs-review" --color "1d76db" --description "Ready for review"
gh label create "status:ready" --color "0e8a16" --description "Ready for implementation"

# Release labels
gh label create "release:blocker" --color "d93f0b" --description "Blocks next release"
gh label create "release:next" --color "fbca04" --description "Planned for next release"
gh label create "release:future" --color "c2e0c6" --description "Future consideration"

# Type labels
gh label create "bug" --color "d73a4a" --description "Something broken"
gh label create "enhancement" --color "1d76db" --description "New feature"
gh label create "refactor" --color "5319e7" --description "Code cleanup"
gh label create "documentation" --color "0075ca" --description "Documentation updates"
```

### Custom Labels for Your Project
Based on your project type, add these custom labels:

**For R Packages:**
```bash
gh label create "CRAN:submission" --color "d93f0b" --description "Blocks CRAN submission"
gh label create "CRAN:compliance" --color "fbca04" --description "CRAN compliance issues"
gh label create "vignette" --color "c2e0c6" --description "Vignette updates"
gh label create "roxygen2" --color "fef2c0" --description "Documentation generation"
```

**For Python Packages:**
```bash
gh label create "PyPI:submission" --color "d93f0b" --description "Blocks PyPI submission"
gh label create "PyPI:compliance" --color "fbca04" --description "PyPI compliance issues"
gh label create "sphinx" --color "c2e0c6" --description "Documentation generation"
gh label create "setup.py" --color "fef2c0" --description "Package configuration"
```

**For Web Applications:**
```bash
gh label create "deployment" --color "d93f0b" --description "Deployment issues"
gh label create "frontend" --color "1d76db" --description "Frontend changes"
gh label create "backend" --color "5319e7" --description "Backend changes"
gh label create "database" --color "0075ca" --description "Database changes"
gh label create "security" --color "b60205" --description "Security issues"
```

## 🔧 **Script Customization**

### Language-Specific Adaptations

#### For R Packages
- Replace `[PACKAGE_NAME]` with your actual package name
- Add CRAN-specific checks (R CMD check, vignette building)
- Include R-specific metrics (test coverage, documentation coverage)
- Add FERPA/ethical compliance checks if applicable

#### For Python Packages
- Replace `[PACKAGE_NAME]` with your actual package name
- Add PyPI-specific checks (setup.py validation, wheel building)
- Include Python-specific metrics (test coverage, linting scores)
- Add security scanning if applicable

#### For Web Applications
- Replace `[PROJECT_NAME]` with your actual project name
- Add deployment status checks
- Include performance metrics
- Add security vulnerability scanning
- Include user acceptance testing status

### Environment-Specific Adaptations

#### Solo Developer
- Simplify workflow steps
- Reduce validation overhead
- Focus on automation
- Quick context updates

#### Small Team
- Add code review requirements
- Include issue assignment
- Regular status updates
- Standard workflow

#### Large Team
- Enhanced workflow with multiple stages
- Automated CI/CD integration
- Detailed reporting
- Multiple review stages

## 📊 **Metrics Customization**

### Essential Metrics (All Projects)
- **Test Coverage**: Target 90%+
- **Build Status**: 0 errors, 0 warnings
- **Issue Resolution Time**: Track average time to close
- **Release Readiness**: Percentage of blockers resolved

### R Package Specific
- **R CMD Check**: 0 errors, 0 warnings, minimal notes
- **Documentation Coverage**: All exported functions documented
- **Vignette Status**: All vignettes build successfully
- **CRAN Compliance**: All CRAN requirements met

### Python Package Specific
- **PyPI Compliance**: All PyPI requirements met
- **Linting Score**: High linting scores
- **Documentation Coverage**: All modules documented
- **Security Scan**: No known vulnerabilities

### Web Application Specific
- **Deployment Status**: Successful deployments
- **Performance Metrics**: Load times, response times
- **Security Scan**: No known vulnerabilities
- **User Acceptance**: All UAT tests pass

## 🚀 **Quick Start Checklist**

### Phase 1: Basic Setup (1-2 hours)
- [ ] Create PROJECT.md with template
- [ ] Create ISSUE_MANAGEMENT_QUICK_REFERENCE.md
- [ ] Set up GitHub labels
- [ ] Create basic context script
- [ ] Test context script

### Phase 2: Enhanced Setup (2-4 hours)
- [ ] Create language-specific context script
- [ ] Set up save-context.sh
- [ ] Create pre-PR validation script
- [ ] Set up issue templates
- [ ] Test all scripts

### Phase 3: Integration (1-2 hours)
- [ ] Update CONTRIBUTING.md
- [ ] Create documentation structure
- [ ] Set up CI/CD integration (optional)
- [ ] Train team on workflow
- [ ] Monitor and adjust

### Phase 4: Optimization (ongoing)
- [ ] Collect feedback
- [ ] Optimize scripts
- [ ] Add new metrics
- [ ] Improve automation
- [ ] Update documentation

## 🎯 **Success Indicators**

### Immediate Success (Week 1)
- [ ] Context scripts provide accurate information
- [ ] Issues are properly labeled
- [ ] Team uses the workflow
- [ ] No major script errors

### Short-term Success (Month 1)
- [ ] All team members adopt the workflow
- [ ] Issue resolution time improves
- [ ] Release process is streamlined
- [ ] Documentation is current

### Long-term Success (Quarter 1)
- [ ] Project metrics meet targets
- [ ] Releases are delivered on schedule
- [ ] Team productivity improves
- [ ] System becomes self-sustaining

---

**Template Version**: 1.0.0
**Based on**: zoomstudentengagement R package workflow
**Last Updated**: 2025-08-11
**Maintainer**: [Your Name/Team]
