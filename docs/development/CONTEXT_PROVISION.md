# Context Provision Guidelines
## zoomstudentengagement R Package

**Purpose**: Guidelines for providing effective context to AI assistants during development.

**Audience**: Developers using AI assistants who need to provide comprehensive project context.

**Last Updated**: August 2025

---

## 🎯 Why Context Matters

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

---

## 🚀 Quick Start Options

### Option 1: Use the Context Scripts (Recommended)

```bash
# Generate comprehensive context
./scripts/context-for-new-chat.sh

# Generate R-specific context
Rscript scripts/context-for-new-chat.R

# Combine both for complete context
./scripts/context-for-new-chat.sh && Rscript scripts/context-for-new-chat.R
```

### Option 2: Reference Key Documentation Files

For comprehensive project information, reference these key files:

#### **Essential Project Documentation**
- **`README.md`** - Package overview, installation, and quick start
- **`PROJECT.md`** - Current project status and CRAN readiness
- **`CONTRIBUTING.md`** - Development workflow and contribution guidelines
- **`CRAN_CHECKLIST.md`** - Detailed CRAN submission tracking and requirements

#### **Development Guidelines**
- **`docs/development/AI_ASSISTED_DEVELOPMENT.md`** - AI-assisted development guidelines
- **`docs/development/AUDIT_LOG.md`** - Recent audit results and findings
- **`ISSUE_MANAGEMENT_QUICK_REFERENCE.md`** - Issue workflow and management

### Option 3: Manual Context Provision

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

---

## 📋 Context Scripts

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

---

## 🎯 When to Use Context Scripts vs. Documentation References

### **Use Context Scripts When:**
- Starting a new development session
- Need current project status and metrics
- Want recent activity and issue updates
- Need quick overview of current state
- Working on time-sensitive tasks

### **Use Documentation References When:**
- Need detailed development guidelines
- Looking for comprehensive CRAN requirements
- Want to understand project structure and conventions
- Need to reference specific workflows or processes
- Working on complex features requiring deep understanding

### **Best Practice: Combine Both**
1. **Start with context scripts** for current status
2. **Reference specific documentation** for detailed guidance
3. **Use context scripts for updates** during development
4. **Reference documentation for** final validation and submission

---

## 📝 Context Templates

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

---

## 🔄 Integration with Development Workflow

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

---

## 🛠️ Advanced Context Techniques

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

---

## 🔧 Troubleshooting Context Issues

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

---

## 🔗 Related Documentation

- **[AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md)** - Core AI development guidelines
- **[CURSOR_INTEGRATION.md](CURSOR_INTEGRATION.md)** - Cursor-specific guidelines
- **[PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md)** - Pre-PR validation checklist
- **[CRAN_SUBMISSION.md](CRAN_SUBMISSION.md)** - CRAN submission requirements

---

**See Also**: [ISSUE_MANAGEMENT_QUICK_REFERENCE.md](../../ISSUE_MANAGEMENT_QUICK_REFERENCE.md) for issue workflow 