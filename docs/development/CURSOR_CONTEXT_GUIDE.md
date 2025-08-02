# AI-Assisted Development Guide for zoomstudentengagement

## Overview

This guide provides comprehensive best practices and tools for AI-assisted development in the zoomstudentengagement R package. It covers context provision, AI agent guidelines, development workflows, and integration strategies for effective AI collaboration.

## Why AI-Assisted Development Matters

AI assistants can significantly accelerate development when properly guided with:
- Current project context and status
- Clear development priorities and constraints
- Project-specific conventions and standards
- Ethical considerations and compliance requirements
- Proper workflow integration

Effective AI collaboration helps:
- Reduce development time and errors
- Maintain code quality and consistency
- Ensure compliance with project standards
- Scale development capacity
- Improve documentation and testing

---

## 🤖 AI Agent Guidelines

### Core Principles for AI Collaboration

#### 1. **Context-First Approach**
- Always provide comprehensive project context before asking questions
- Include current status, priorities, and constraints
- Reference relevant issues, documentation, and recent changes
- Use the provided context scripts for consistent information

#### 2. **Ethical Development Practices**
- **Privacy First**: Never expose sensitive student data or personal information
- **FERPA Compliance**: Ensure all suggestions comply with educational privacy laws
- **Equitable Participation**: Focus on participation equity and inclusive design
- **Transparency**: Document AI-assisted changes and their rationale
- **Human Oversight**: Always review and validate AI-generated code

#### 3. **Code Quality Standards**
- Follow [tidyverse style guide](https://style.tidyverse.org/)
- Maintain >90% test coverage for all new code
- Include comprehensive roxygen2 documentation
- Ensure CRAN compliance for all changes
- Use consistent naming conventions and patterns

#### 4. **Development Workflow Integration**
- Create feature branches for all changes
- Link changes to relevant GitHub issues
- Follow the established PR workflow
- Run pre-PR validation checks
- Update documentation with changes

### AI Agent Responsibilities

#### **Context Management**
- Keep context file up to date with latest changes
- Document all significant decisions and their rationale
- Track ongoing work and blockers
- Maintain clear status of all components
- Update PROJECT.md with current information

#### **Code Generation**
- Follow R package best practices
- Include comprehensive documentation
- Add appropriate tests for new code
- Ensure CRAN compliance
- Use consistent naming conventions
- Validate input parameters and error handling

#### **Issue Resolution**
- Document problem and solution approach
- Link related issues and PRs
- Track resolution progress
- Update context with outcomes
- Provide clear acceptance criteria

#### **Documentation**
- Keep README current and comprehensive
- Maintain up-to-date function documentation
- Document all exported functions
- Include usage examples
- Keep vignettes current and relevant

### AI Agent Best Practices

#### **Before Starting Work**
1. **Gather Context**: Run context scripts and review current status
2. **Understand Requirements**: Read issue descriptions and acceptance criteria
3. **Check Dependencies**: Review related issues and existing code
4. **Plan Approach**: Outline solution strategy and implementation steps
5. **Validate Assumptions**: Confirm understanding with human developer

#### **During Development**
1. **Follow Conventions**: Use established patterns and naming conventions
2. **Write Tests First**: Create tests before implementing features
3. **Document as You Go**: Add roxygen2 documentation immediately
4. **Validate Incrementally**: Test changes frequently and thoroughly
5. **Communicate Progress**: Update context and issue status regularly

#### **Before Submitting Work**
1. **Run Validation**: Execute pre-PR validation checklist
2. **Review Code**: Self-review for quality and compliance
3. **Update Documentation**: Ensure all changes are documented
4. **Test Thoroughly**: Verify all functionality works as expected
5. **Prepare Context**: Update context for next development session

### AI Agent Constraints and Limitations

#### **Data Privacy and Security**
- **Never log or expose** sensitive student data
- **Always anonymize** data in examples and tests
- **Validate input** to prevent injection attacks
- **Follow FERPA guidelines** for all data handling
- **Use secure practices** for file operations

#### **Code Quality Requirements**
- **No hardcoded secrets** or sensitive information
- **Proper error handling** for all functions
- **Input validation** for all parameters
- **Memory efficiency** for large data operations
- **Performance considerations** for scalability

#### **CRAN Compliance**
- **All examples must run** without errors
- **No global variable warnings** in R CMD check
- **Proper package structure** and metadata
- **Complete documentation** for all exports
- **License compliance** and attribution

---

## 🎯 Cursor-Specific Guidelines

### File Organization and Navigation

#### **Project Structure Understanding**
- **R/**: Core functions (33 exported)
- **tests/**: Test suite (30+ test files)
- **man/**: Documentation (auto-generated)
- **vignettes/**: Usage examples
- **inst/extdata/**: Sample data
- **docs/**: Development documentation
- **scripts/**: Development utilities

#### **Code Navigation Strategies**
- Use semantic search for finding relevant code
- Leverage file search for quick access
- Maintain clear function relationships
- Document complex code paths
- Use consistent file naming conventions

#### **Development Workflow Integration**
- Use Cursor's AI features for code generation
- Leverage built-in testing tools
- Utilize documentation helpers
- Follow Cursor's best practices for R development
- Integrate with version control workflows

### Cursor AI Features Best Practices

#### **Code Generation**
- Provide clear, specific prompts
- Include context about existing code patterns
- Specify desired output format and style
- Review and validate generated code
- Iterate on suggestions as needed

#### **Code Review and Refactoring**
- Use AI to identify potential improvements
- Request explanations for suggested changes
- Validate refactoring suggestions
- Maintain code consistency
- Preserve existing functionality

#### **Documentation Assistance**
- Generate roxygen2 documentation
- Create usage examples
- Update README and vignettes
- Maintain documentation consistency
- Ensure all examples are runnable

---

## 📋 Pre-PR Validation Checklist

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

---

## 🚀 CRAN Submission Requirements

### Critical Requirements
- All tests must pass (`devtools::test()`)
- Code coverage >90% (`covr::package_coverage()`)
- No spelling errors (`devtools::spell_check()`)
- All examples run (`devtools::check_examples()`)
- R CMD check passes with 0 errors, 0 warnings (`devtools::check()`)
- Package builds successfully (`devtools::build()`)

### Documentation Completeness
- All exported functions have complete roxygen2 documentation
- All examples are runnable and tested
- README.md is current and comprehensive
- Vignettes are created for complex workflows
- No missing documentation warnings

### Package Metadata
- `DESCRIPTION` has correct version, license (MIT), and dependencies
- `NAMESPACE` is properly generated
- All dependencies are specified with version constraints
- License file is present and correct

---

## Why Context Matters

When starting a new chat in Cursor, the AI assistant doesn't have access to:
- Current project status and progress
- Recent changes and issues
- Development priorities and blockers
- Project structure and conventions
- Current test status and coverage

Providing this context helps the AI:
- Understand the current state of the project
- Make informed suggestions and recommendations
- Avoid suggesting work that's already completed
- Focus on the most relevant and urgent tasks
- Follow project conventions and standards

## Quick Start

### Option 1: Use the Context Scripts (Recommended)

```bash
# Generate comprehensive context
./scripts/context-for-new-chat.sh

# Generate R-specific context
Rscript scripts/context-for-new-chat.R

# Combine both for complete context
./scripts/context-for-new-chat.sh && Rscript scripts/context-for-new-chat.R
```

### Option 2: Manual Context Provision

Copy and paste the following into your new Cursor chat:

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

**Recent Issues**: [Use `gh issue list --limit 5` to get current issues]
```

## Context Scripts

### Shell Script: `scripts/context-for-new-chat.sh`

**Purpose**: Provides comprehensive project context including:
- Project status and metrics
- Current GitHub issues and priorities
- Development workflow and conventions
- CRAN readiness status
- Next steps and immediate priorities

**Usage**:
```bash
# Make executable (first time only)
chmod +x scripts/context-for-new-chat.sh

# Run the script
./scripts/context-for-new-chat.sh

# Copy output to new Cursor chat
```

**Output Includes**:
- Project status summary
- Key metrics (tests, coverage, R CMD check)
- Critical issues (high priority)
- CRAN submission blockers
- Recent activity
- Essential files to review
- Development focus areas
- Quick commands for context
- Project structure
- Development workflow
- CRAN readiness status
- Immediate next steps

### R Script: `scripts/context-for-new-chat.R`

**Purpose**: Provides R-specific context including:
- Package loading status
- Test results and coverage
- Package structure and dependencies
- Exported functions
- Common issues and solutions
- Development tips

**Usage**:
```bash
# Run the R script
Rscript scripts/context-for-new-chat.R

# Copy output to new Cursor chat
```

**Output Includes**:
- Package loading status
- Test status (failures, warnings, skips)
- Test coverage percentage
- R CMD check status
- Package structure (files, functions, tests)
- Exported functions count
- Dependencies (Imports, Suggests)
- Quick health check commands
- Common issues and solutions
- Development tips

## Best Practices for Context Provision

### 1. Always Include Essential Information

**Must-Have Context**:
- Current project status and goals
- Test status (pass/fail, coverage)
- R CMD check status
- Current priorities and blockers
- Recent activity or changes

**Nice-to-Have Context**:
- Project structure overview
- Development workflow
- Common issues and solutions
- Quick commands for validation

### 2. Keep Context Current

**Update Context When**:
- Tests fail or pass
- New issues are created
- Priorities change
- Major milestones are reached
- CRAN readiness status changes

**How to Update**:
- Run context scripts to get current status
- Update PROJECT.md with new information
- Check GitHub issues for recent activity
- Verify test and coverage status

### 3. Use Appropriate Detail Level

**For Quick Questions**:
- Project status and current focus
- Test status (pass/fail)
- Immediate priorities

**For Complex Tasks**:
- Full context from scripts
- Detailed issue information
- Development workflow
- Common solutions

**For CRAN Preparation**:
- Complete context from both scripts
- All CRAN-related issues
- Test coverage and R CMD check status
- Compliance requirements

### 4. Include Relevant Issue Information

**For Issue-Specific Work**:
```markdown
**Working on Issue #XX**: [Issue Title]
**Priority**: [High/Medium/Low]
**Status**: [Open/In Progress/Closed]
**Description**: [Brief description]
**Acceptance Criteria**: [What needs to be done]
```

**For General Development**:
- List of high-priority issues
- CRAN submission blockers
- Recent activity

## Context Templates

### Template 1: Quick Status Check

```markdown
## Quick Status: zoomstudentengagement

**Status**: [Current status]
**Tests**: [Pass/Fail count]
**Coverage**: [Percentage]
**R CMD Check**: [Status]
**Current Focus**: [Main priority]
**Recent Changes**: [Brief summary]
```

### Template 2: Issue-Specific Context

```markdown
## Working on Issue #[NUMBER]

**Issue**: [Title]
**Priority**: [Level]
**Status**: [Current status]
**Description**: [What needs to be done]
**Acceptance Criteria**: [Success metrics]
**Related Issues**: [Linked issues]
**Current Progress**: [What's been done]
```

### Template 3: CRAN Preparation Context

```markdown
## CRAN Preparation Status

**Overall Status**: [Ready/Close/Not Ready]
**Test Status**: [Pass/Fail details]
**Coverage**: [Current vs Target]
**R CMD Check**: [Errors/Warnings/Notes]
**Documentation**: [Status]
**Examples**: [Status]
**Blockers**: [List of blocking issues]
**Next Steps**: [Immediate actions needed]
```

## Integration with Development Workflow

### Pre-Chat Context Gathering

1. **Before starting a new chat**:
   ```bash
   # Get current context
   ./scripts/context-for-new-chat.sh
   Rscript scripts/context-for-new-chat.R
   ```

2. **For specific issues**:
   ```bash
   # Get issue details
   gh issue view <ISSUE_NUMBER>
   ```

3. **For recent changes**:
   ```bash
   # Check recent commits
   git log --oneline -5
   
   # Check uncommitted changes
   git status
   ```

### During Development

1. **Update context when status changes**:
   - After fixing tests
   - After resolving issues
   - After updating documentation
   - After changing priorities

2. **Reference context in commits**:
   ```bash
   git commit -m "fix: Address #XX - [description]

   Context: [Brief context about the change]
   Tests: [Test status]
   Coverage: [Coverage impact]"
   ```

### Post-Development Context Update

1. **Update PROJECT.md** with new status
2. **Close resolved issues** with appropriate comments
3. **Update context scripts** if needed
4. **Document lessons learned** for future reference

## Troubleshooting Context Issues

### Common Problems

**Scripts Don't Work**:
- Check file permissions: `chmod +x scripts/context-for-new-chat.sh`
- Verify dependencies: `gh --version`, `Rscript --version`
- Check working directory: Must be in project root

**Outdated Information**:
- Run scripts to get current status
- Check GitHub issues for recent activity
- Verify test status manually
- Update PROJECT.md with current information

**Missing Context**:
- Use both shell and R scripts
- Include issue-specific information
- Add relevant file contents
- Provide development workflow context

### Getting Help

**When Context is Insufficient**:
1. Run both context scripts
2. Check PROJECT.md for current status
3. Review recent GitHub issues
4. Check test and coverage status manually
5. Provide specific error messages or problems

**For Complex Issues**:
1. Include full error messages
2. Provide relevant file contents
3. Include test results
4. Describe expected vs actual behavior
5. Include environment information

## Advanced Context Techniques

### Custom Context Scripts

Create project-specific context scripts:

```bash
#!/bin/bash
# scripts/my-context.sh

echo "## Custom Context for [Specific Task]"
echo ""
echo "**Current Focus**: [What you're working on]"
echo "**Relevant Files**: [Files involved]"
echo "**Current Issues**: [Specific problems]"
echo "**Expected Outcome**: [What you want to achieve]"
```

### Context Automation

Set up automated context updates:

```bash
# Add to .git/hooks/pre-commit
#!/bin/bash
# Update context before committing
./scripts/context-for-new-chat.sh > .cursor/current-context.txt
```

### Context Integration

Integrate context with development tools:

```bash
# Add to your shell profile
alias context='./scripts/context-for-new-chat.sh'
alias rcontext='Rscript scripts/context-for-new-chat.R'
alias fullcontext='./scripts/context-for-new-chat.sh && Rscript scripts/context-for-new-chat.R'
```

## Conclusion

Providing good context to AI-assisted development sessions is essential for effective collaboration. Use the provided scripts, templates, and guidelines to ensure consistent, comprehensive context provision while maintaining high code quality and ethical standards.

**Key Takeaways**:
- Always provide essential project status
- Keep context current and accurate
- Use appropriate detail level for the task
- Include relevant issue information
- Integrate context into your development workflow
- Update context when project status changes
- Follow ethical development practices
- Maintain CRAN compliance standards

**Next Steps**:
1. Try the context scripts with your next AI-assisted development session
2. Customize templates for your specific needs
3. Integrate context provision into your workflow
4. Share feedback and improvements with the team
5. Review and update AI guidelines regularly 