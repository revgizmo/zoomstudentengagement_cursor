# Issue Tracking Alignment Project Plan

## Project Overview
**Goal**: Align local issue tracking (`.github/ISSUES/`) with GitHub's native issue system to improve project management, collaboration, and CRAN submission readiness.

**Branch**: `feature/align-issue-tracking`
**Status**: Planning Phase
**Created**: January 2025

## Current State Analysis

### What We Have
- **Local Issue Tracking**: `.github/ISSUES/` with 2 documented issues
  - `fix_r_cmd_check_warnings.md` - CRAN compliance issues
  - `make_clean_names_df_test_warnings.md` - Test hygiene issues
- **Comprehensive Documentation**: PROJECT.md, CRAN_CHECKLIST.md, AUDIT_LOG.md, CONTRIBUTING.md
- **Clean Repository**: No open PRs, well-structured package
- **Good Test Coverage**: 341 tests passing, 100% coverage

### What's Missing
- **GitHub Issues**: No native GitHub issues created
- **Project Board**: No GitHub Projects for task management
- **Issue Integration**: Documentation references local files instead of GitHub issues
- **Automation**: No GitHub Actions integration with issues

## Action Plan

### Phase 1: GitHub Issues Creation (30 minutes)
**Objective**: Create GitHub issues from local `.github/ISSUES/` files

#### Step 1.1: Create Primary Issues
1. **Issue #1: Fix R-CMD-check warnings for CRAN compliance**
   - Source: `.github/ISSUES/fix_r_cmd_check_warnings.md`
   - Labels: `cran`, `compliance`, `high-priority`
   - Assignee: [Maintainer]
   - Milestone: "CRAN v1.0 Release"

2. **Issue #2: Clean up make_clean_names_df test warnings**
   - Source: `.github/ISSUES/make_clean_names_df_test_warnings.md`
   - Labels: `testing`, `medium-priority`
   - Assignee: [Maintainer]
   - Milestone: "CRAN v1.0 Release"

#### Step 1.2: Create Additional Issues from PROJECT.md
3. **Issue #3: Complete roxygen2 documentation**
   - Title: "Complete roxygen2 documentation for all exported functions"
   - Labels: `documentation`, `cran`, `high-priority`
   - Description: Many functions have incomplete `@examples` sections

4. **Issue #4: Fix license specification**
   - Title: "Replace 'TBD Open Source' with proper MIT license"
   - Labels: `cran`, `compliance`, `high-priority`
   - Description: Current license "TBD Open Source" is not acceptable for CRAN

5. **Issue #5: Remove deprecated functions**
   - Title: "Remove deprecated load_and_process_zoom_transcript function"
   - Labels: `cleanup`, `medium-priority`
   - Description: Function is deprecated but still present in codebase

### Phase 2: GitHub Project Board Setup (15 minutes)
**Objective**: Create organized project board for task management

#### Step 2.1: Create Project Board
- **Name**: "CRAN Submission & Development"
- **Description**: Track progress toward CRAN submission and ongoing development
- **Visibility**: Public

#### Step 2.2: Configure Columns
1. **To Do** (Backlog)
2. **In Progress** (Active work)
3. **Review** (Ready for review)
4. **Done** (Completed)

#### Step 2.3: Add Issues to Board
- Move all 5 issues to "To Do" column
- Set up initial priorities

### Phase 3: Documentation Updates (45 minutes)
**Objective**: Update all documentation to reference GitHub issues instead of local files

#### Step 3.1: Update PROJECT.md
- Remove outdated "Current Status (Updated: July 4, 2025)"
- Add "Current Status (Updated: [Current Date])"
- Replace local issue references with GitHub issue numbers
- Update timeline with realistic dates
- Add "Active Issues" section with links

#### Step 3.2: Update CRAN_CHECKLIST.md
- Mark completed items with ✅
- Link remaining items to specific GitHub issues
- Add "Current Status Summary" section
- Update "Immediate Action Items" with issue numbers

#### Step 3.3: Update AUDIT_LOG.md
- Add current date entry with status update
- Reference new GitHub issue numbers
- Mark completed audit items
- Update "Current Status" section

#### Step 3.4: Update CONTRIBUTING.md
- Ensure references to GitHub workflow are current
- Update any outdated references
- Add section about issue tracking workflow

### Phase 4: Local File Cleanup (15 minutes)
**Objective**: Archive local issue files and update references

#### Step 4.1: Archive Local Issues
- Create `.github/ISSUES/archive/` directory
- Move existing `.md` files to archive
- Add note about migration to GitHub issues

#### Step 4.2: Update README.Rmd
- Remove references to local issue files
- Add section about GitHub issue tracking
- Update any workflow documentation

### Phase 5: Repository Configuration (30 minutes)
**Objective**: Set up GitHub repository for better issue management

#### Step 5.1: Configure Labels
- **Priority**: High, Medium, Low
- **Type**: Bug, Enhancement, Documentation, Test
- **Status**: Blocked, In Progress, Needs Review
- **Area**: Core, UI, Testing, Documentation
- **CRAN**: Submission, Review, Compliance

#### Step 5.2: Set up Milestones
- **CRAN v1.0 Release** (Target: [Date])
- **Documentation Overhaul** (Target: [Date])
- **Test Suite Cleanup** (Target: [Date])

#### Step 5.3: Configure Branch Protection
- Enable branch protection for `main`
- Require PR reviews
- Require status checks to pass

### Phase 6: Automation Setup (Optional - 30 minutes)
**Objective**: Set up GitHub Actions integration with issues

#### Step 6.1: Update R-CMD-check Workflow
- Re-enable warning-as-error after issues are resolved
- Add issue linking in workflow
- Add status reporting

#### Step 6.2: Add Issue Templates
- Bug Report template
- Feature Request template
- Documentation Update template
- CRAN Submission Task template

## Success Criteria

### Phase 1 Success
- [ ] 5 GitHub issues created with proper labels
- [ ] All issues assigned to appropriate milestone
- [ ] Issues contain all relevant information from local files

### Phase 2 Success
- [ ] Project board created and configured
- [ ] All issues added to board
- [ ] Board is publicly accessible

### Phase 3 Success
- [ ] PROJECT.md updated with current status
- [ ] CRAN_CHECKLIST.md linked to specific issues
- [ ] AUDIT_LOG.md reflects current state
- [ ] CONTRIBUTING.md is current

### Phase 4 Success
- [ ] Local issue files archived
- [ ] README.Rmd updated
- [ ] No broken references to local files

### Phase 5 Success
- [ ] Labels configured and applied
- [ ] Milestones created
- [ ] Branch protection enabled

### Overall Success
- [ ] Single source of truth for issue tracking
- [ ] Clear path to CRAN submission
- [ ] Improved collaboration workflow
- [ ] Better project visibility

## Risk Mitigation

### Potential Issues
1. **Issue Duplication**: Ensure local files are archived, not deleted
2. **Broken References**: Test all documentation links after updates
3. **Workflow Disruption**: Maintain existing workflow during transition
4. **Information Loss**: Preserve all information from local files

### Mitigation Strategies
1. **Backup**: Keep local files in archive
2. **Testing**: Verify all links and references work
3. **Gradual Transition**: Update one document at a time
4. **Documentation**: Maintain clear migration notes

## Timeline

### Week 1
- **Day 1**: Phases 1-2 (GitHub setup)
- **Day 2**: Phase 3 (Documentation updates)
- **Day 3**: Phase 4 (Cleanup)
- **Day 4**: Phase 5 (Configuration)
- **Day 5**: Review and testing

### Week 2
- **Optional**: Phase 6 (Automation)
- **Review**: Ensure everything is working correctly
- **Documentation**: Update any missing pieces

## Next Steps After Completion

1. **Begin Issue Resolution**: Start working on high-priority CRAN issues
2. **Regular Reviews**: Weekly project board reviews
3. **Automation**: Gradually add GitHub Actions integration
4. **Community**: Encourage contributions through improved workflow

## Resources

- [GitHub Issues Documentation](https://docs.github.com/en/issues/tracking-your-work-with-issues/about-issues)
- [GitHub Projects Documentation](https://docs.github.com/en/issues/organizing-your-work-with-project-boards/managing-project-boards)
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
- [R Packages Book](https://r-pkgs.org/)

---

**Note**: This plan should be reviewed and approved before implementation. All changes will be made in the `feature/align-issue-tracking` branch and submitted as a pull request for review. 