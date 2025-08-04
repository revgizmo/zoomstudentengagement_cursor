# Cursor Integration Guidelines
## zoomstudentengagement R Package

**Purpose**: Cursor-specific guidelines and best practices for AI-assisted development.

**Audience**: Developers using Cursor IDE for R package development.

**Last Updated**: August 2025

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

---

## 🤖 Cursor AI Features Best Practices

### Code Generation

#### **Effective Prompts**
- Provide clear, specific prompts
- Include context about existing code patterns
- Specify desired output format and style
- Review and validate generated code
- Iterate on suggestions as needed

#### **Context-Aware Development**
```markdown
# Good prompt example:
"Create a function that processes Zoom transcript data following the existing patterns in this package. 
The function should:
- Take a transcript file path as input
- Return a tibble with standardized columns
- Include proper error handling
- Follow the naming conventions used in other functions
- Include roxygen2 documentation"
```

#### **Code Review and Refactoring**
- Use AI to identify potential improvements
- Request explanations for suggested changes
- Validate refactoring suggestions
- Maintain code consistency
- Preserve existing functionality

### Documentation Assistance

#### **Roxygen2 Documentation**
- Generate complete function documentation
- Include all required sections (@param, @return, @examples)
- Ensure examples are runnable
- Follow package documentation standards
- Validate with `devtools::check_man()`

#### **Usage Examples**
- Create realistic examples with sample data
- Test all examples before committing
- Use `\dontrun{}` for external dependencies
- Use `\donttest{}` for slow operations
- Include edge case examples

#### **README and Vignettes**
- Keep README current and comprehensive
- Update vignettes with new features
- Ensure all links work correctly
- Test vignette rendering
- Include installation instructions

---

## 🔧 Cursor-Specific Workflow

### Pre-Development Setup

1. **Load Project Context**:
   ```bash
   # Generate context for Cursor
   ./scripts/context-for-new-chat.sh
   Rscript scripts/context-for-new-chat.R
   ```

2. **Set Up AI Guidelines**:
   - Reference [AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md)
   - Review [CONTEXT_PROVISION.md](CONTEXT_PROVISION.md)
   - Check current project status

3. **Prepare Development Environment**:
   - Ensure R and required packages are installed
   - Set up git hooks for pre-commit validation
   - Configure Cursor for R development

### During Development

1. **Use AI for Code Generation**:
   - Provide clear, specific prompts
   - Include existing code patterns as context
   - Review generated code thoroughly
   - Test functionality before committing

2. **Leverage Cursor Features**:
   - Use semantic search for finding relevant code
   - Utilize AI for code review and suggestions
   - Take advantage of built-in testing tools
   - Use documentation helpers

3. **Maintain Quality Standards**:
   - Follow tidyverse style guide
   - Ensure CRAN compliance
   - Maintain test coverage >90%
   - Update documentation with changes

### Post-Development Validation

1. **Run Pre-PR Validation**:
   ```r
   # Phase 1: Code Quality
   styler::style_pkg()
   lintr::lint_package()
   
   # Phase 2: Documentation
   devtools::document()
   devtools::build_readme()
   devtools::spell_check()
   
   # Phase 3: Testing
   devtools::test()
   covr::package_coverage()
   
   # Phase 4: Final Validation
   devtools::check()
   devtools::build()
   ```

2. **Update Context**:
   - Update PROJECT.md with new status
   - Close resolved issues
   - Document lessons learned
   - Prepare context for next session

---

## 🎯 Cursor AI Best Practices

### Prompt Engineering

#### **Clear and Specific Prompts**
```markdown
# Instead of: "Fix this function"
# Use: "Fix the error handling in process_zoom_transcript() to properly validate the file_path parameter and provide informative error messages following the pattern used in other functions in this package"
```

#### **Include Context**
```markdown
# Good prompt structure:
"Context: Working on issue #XX to improve test coverage
Current function: [function name]
Existing pattern: [reference to similar code]
Desired outcome: [specific result]
Constraints: [any limitations or requirements]"
```

#### **Iterative Refinement**
- Start with broad prompts and refine
- Ask for explanations of suggestions
- Request alternative approaches
- Validate understanding before implementation

### Code Quality Assurance

#### **AI-Generated Code Review**
- Always review generated code
- Test functionality thoroughly
- Check for security issues
- Ensure compliance with project standards
- Validate against existing patterns

#### **Documentation Validation**
- Verify roxygen2 documentation is complete
- Test all examples
- Check for spelling errors
- Ensure links work correctly
- Validate with `devtools::check_man()`

---

## 🚀 Advanced Cursor Features

### Semantic Search Integration

#### **Finding Related Code**
```markdown
# Use semantic search for:
- Finding similar functions
- Locating usage examples
- Identifying patterns
- Discovering dependencies
```

#### **Code Pattern Recognition**
- Use AI to identify common patterns
- Request pattern documentation
- Ask for pattern improvements
- Validate pattern consistency

### Automated Testing

#### **Test Generation**
- Use AI to generate test cases
- Request edge case tests
- Ask for error condition tests
- Validate test coverage

#### **Test Maintenance**
- Use AI to update tests when functions change
- Request test improvements
- Ask for performance tests
- Validate test quality

---

## 🔧 Troubleshooting Cursor Issues

### Common Problems

#### **AI Not Understanding Context**
- Provide more specific context
- Reference existing code patterns
- Include error messages and examples
- Use the context scripts for comprehensive information

#### **Generated Code Quality Issues**
- Review all generated code
- Test functionality thoroughly
- Check for security vulnerabilities
- Ensure compliance with project standards

#### **Documentation Problems**
- Validate all generated documentation
- Test examples before committing
- Check for spelling and grammar errors
- Ensure links work correctly

### Getting Help

#### **When AI Suggestions Are Poor**
1. Provide more specific context
2. Reference existing code patterns
3. Include error messages and examples
4. Ask for explanations of suggestions
5. Request alternative approaches

#### **For Complex Issues**
1. Break down the problem into smaller parts
2. Provide step-by-step context
3. Include relevant file contents
4. Reference existing solutions
5. Ask for multiple approaches

---

## 🔗 Related Documentation

- **[AI_ASSISTED_DEVELOPMENT.md](AI_ASSISTED_DEVELOPMENT.md)** - Core AI development guidelines
- **[BUGBOT.md](BUGBOT.md)** - R package review guidelines and patterns
- **[CONTEXT_PROVISION.md](CONTEXT_PROVISION.md)** - How to provide effective context
- **[PRE_PR_VALIDATION.md](PRE_PR_VALIDATION.md)** - Pre-PR validation checklist
- **[CRAN_SUBMISSION.md](CRAN_SUBMISSION.md)** - CRAN submission requirements

---

## 📋 Quick Reference

### Essential Commands
```bash
# Context generation
./scripts/context-for-new-chat.sh
Rscript scripts/context-for-new-chat.R

# Pre-PR validation
Rscript scripts/pre-pr-validation.R

# Package checks
devtools::check()
devtools::test()
covr::package_coverage()
```

### Key Files
- **PROJECT.md** - Current project status
- **ISSUE_MANAGEMENT_QUICK_REFERENCE.md** - Issue workflow
- **CONTRIBUTING.md** - Development guidelines
- **CRAN_CHECKLIST.md** - CRAN requirements

### AI Guidelines
- Always provide comprehensive context
- Follow ethical development practices
- Maintain code quality standards
- Ensure CRAN compliance
- Document all changes

---

## 🔧 GitHub CLI Best Practices for AI Agents

### **PR Review and Comment Analysis**

#### **Getting Detailed PR Comments**
When reviewing pull requests, AI agents should use the GitHub API for comprehensive comment analysis:

```bash
# ❌ Basic comments only (misses detailed Cursor Bot reports)
gh pr view --comments

# ✅ Full detailed comments with code diffs and bug reports
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments

# ✅ Open PR in browser for full review
gh pr view --web

# ✅ Get review summaries
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews
```

#### **Why This Matters**
- **Cursor Bot Comments**: Detailed bug reports with code diffs are only visible via API
- **Code Review Comments**: Line-specific comments with suggestions
- **Review Summaries**: Overall review status and recommendations
- **Full Context**: Complete comment history and discussion

#### **Example Usage**
```bash
# Check PR #117 for detailed Cursor Bot comments
gh api repos/revgizmo/zoomstudentengagement/pulls/117/comments

# Get all reviews for a PR
gh api repos/revgizmo/zoomstudentengagement/pulls/117/reviews

# Open PR in browser for full review
gh pr view 117 --web
```

#### **Common Patterns**
- **Cursor Bot Bug Reports**: Include detailed descriptions, code diffs, and fix suggestions
- **Review Comments**: Line-specific feedback with improvement suggestions
- **Discussion Comments**: General feedback and questions
- **Outdated Comments**: Comments that may be resolved by subsequent changes

### **PR Management Commands**

#### **Creating and Managing PRs**
```bash
# Create PR with proper escaping for parentheses
gh pr create --title "fix: Address issue description" --body "Detailed description"

# Merge PR with admin override if needed
gh pr merge {pr_number} --merge --admin

# Check PR status
gh pr status

# List recent PRs
gh pr list --limit 10
```

#### **Branch Management**
```bash
# Create feature branch
git checkout -b feature/issue-description

# Push and create PR
git push -u origin feature/issue-description
gh pr create --title "..." --body "..."
```

### **Context Gathering for AI Agents**

#### **Before Reviewing PRs**
1. **Get PR Details**: `gh pr view {number}`
2. **Check Comments**: `gh api repos/{owner}/{repo}/pulls/{number}/comments`
3. **Review Changes**: `gh pr diff {number}`
4. **Check Status**: `gh pr checks {number}`

#### **For Comprehensive Analysis**
- Use API endpoints for detailed information
- Check both comments and reviews
- Look for Cursor Bot bug reports
- Verify if comments are outdated
- Consider the full discussion context

---

**See Also**: [CONTRIBUTING.md](../../CONTRIBUTING.md) for general development guidelines 