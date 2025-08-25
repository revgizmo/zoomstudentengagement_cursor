# Issue Management Quick Reference
## zoomstudentengagement R Package

**For Cursor Users** - Keep this file open when working with issues

## 🎯 **Priority System**

### High Priority (Work First)
- `priority:high` + `CRAN:submission` - CRAN blockers
- `priority:high` + `area:core` - Critical functionality
- `priority:high` + `area:testing` - Test failures

### Medium Priority (Plan Next)
- `priority:medium` + `area:core` - Important features
- `priority:medium` + `area:documentation` - Documentation gaps

### Low Priority (Nice to Have)
- `priority:low` - Minor improvements, polish

## 📋 **Issue Templates**

### Bug Report
```markdown
**Bug:** [Brief description]

**Steps:**
1. [Step 1]
2. [Step 2]

**Expected:** [What should happen]
**Actual:** [What happens]

**Environment:** R [version], Package [version], OS [type]
```

### Feature Request
```markdown
**Feature:** [Brief description]

**Use Case:** [Why needed]

**Solution:** [How it should work]
```

## 🔗 **Cursor Workflow**

### When Starting Work
1. Check issue labels and priority
2. Update issue: "Starting work on this"
3. Move to "In Progress" if using project board

### During Development
1. Update issue with progress
2. Link commits: `fix: Address #71 - Add withr dependency`
3. Create PR with `Fixes #X` in description

### When Completing
1. Ensure tests pass
2. Update documentation
3. Close issue when PR merged

## 🏷️ **Essential Labels**

| Label | Meaning | When to Use |
|-------|---------|-------------|
| `priority:high` | CRAN blockers, critical bugs | Must fix before CRAN |
| `priority:medium` | Important features | Plan for next release |
| `priority:low` | Nice to have | Future releases |
| `CRAN:submission` | Blocks CRAN submission | High priority |
| `area:core` | Core functionality | Package features |
| `area:testing` | Test infrastructure | Test coverage, CI |
| `area:documentation` | Docs and examples | README, vignettes |
| `bug` | Something broken | Fix needed |
| `enhancement` | New feature | Improvement |
| `refactor` | Code cleanup | Technical debt |

## 📝 **Commit Message Format**

```
type(scope): description

fix(core): Add withr dependency for tests
feat(plotting): Add new visualization function
docs(readme): Update installation instructions
refactor(api): Standardize function names
```

## 🚨 **CRAN Submission Checklist**

Before closing any `CRAN:submission` issue:
- [ ] R CMD check passes (0 errors, 0 warnings)
- [ ] Tests pass (0 failures)
- [ ] Documentation updated
- [ ] Examples run successfully
- [ ] No spelling errors

## 🛠️ **GitHub CLI Commands**

### Creating Issues
```bash
# Check available labels first
gh label list

# Basic issue creation
gh issue create --title "Title" --body "Description"

# With labels (use existing labels only)
gh issue create --title "Title" --body "Description" --label "label1,label2"

# With assignees
gh issue create --title "Title" --body "Description" --assignee "username"
```

### Important Notes
- **Always check available labels** with `gh label list` before creating issues
- Use only existing labels - custom labels will cause errors
- Common labels: `priority:high`, `priority:medium`, `priority:low`, `area:core`, `status:blocked`, `CRAN:submission`

## 📞 **Need Help?**

- Check [docs/development/ISSUE_MANAGEMENT_GUIDELINES.md](docs/development/ISSUE_MANAGEMENT_GUIDELINES.md) for detailed information
- Review similar issues for examples
- Ask in issue comments for clarification 