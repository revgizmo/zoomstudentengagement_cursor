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
- **Existing GitHub Issues**: 26 open issues (including master audit issue #15)
- **Comprehensive Documentation**: PROJECT.md, CRAN_CHECKLIST.md, AUDIT_LOG.md, CONTRIBUTING.md
- **Clean Repository**: No open PRs, well-structured package
- **Good Test Coverage**: 341 tests passing, 100% coverage

### What's Missing
- **Issue Integration**: Documentation references local files instead of GitHub issues
- **Project Board**: No GitHub Projects for task management
- **Issue Consolidation**: Some overlap between local and GitHub issues
- **Automation**: No GitHub Actions integration with issues

## Existing GitHub Issues Analysis

### Master Tracking Issue (#15)
- **Title**: "Codebase Audit: Master Tracking Issue"
- **Status**: Open, tracks comprehensive codebase audit
- **Sub-issues**: 16-34 (various audit tasks)
- **Relevance**: This is the main audit tracking issue referenced in AUDIT_LOG.md

### Key Existing Issues
- **#15**: Master audit tracking (priority:high, audit)
- **#16**: Function naming and API consistency (priority:high, audit)
- **#17**: Refactor duplicated code (priority:high, audit, refactor)
- **#18**: Improve error messages (priority:high, audit)
- **#19**: Update documentation (documentation, priority:high, audit)
- **#20**: Increase test coverage (priority:high, test, audit)
- **#21**: Review dependencies and CRAN readiness (priority:high, audit)
- **#22**: Address technical debt (priority:medium, audit)
- **#23**: Replace acronyms in exported functions (priority:high, audit, refactor)
- **#24**: Restore passing test suite (bug, priority:high, audit)
- **#28-34**: Various refactoring and documentation tasks
- **#36**: Cross-reference issues and track progress (documentation)
- **#39**: Optimize GitHub Actions workflow (enhancement)

### Issue Overlap Analysis
- **Local `fix_r_cmd_check_warnings.md`** ↔ **GitHub #21** (CRAN readiness)
- **Local `make_clean_names_df_test_warnings.md`** ↔ **GitHub #24** (test suite)
- **PROJECT.md CRAN issues** ↔ **GitHub #21** (CRAN readiness)

## Revised Action Plan

### Phase 0: Existing Issues Assessment (15 minutes)
**Objective**: Analyze existing GitHub issues and identify overlaps/conflicts

#### Step 0.1: Map Local Issues to GitHub Issues
1. **Local `fix_r_cmd_check_warnings.md`** → **GitHub #21** (CRAN readiness)
   - **Action**: Update GitHub #21 with local content, then archive local file
   - **Status**: Consolidate, don't duplicate

2. **Local `make_clean_names_df_test_warnings.md`** → **GitHub #24** (test suite)
   - **Action**: Update GitHub #24 with local content, then archive local file
   - **Status**: Consolidate, don't duplicate

#### Step 0.2: Identify Missing Issues
- **License specification**: Not covered in existing issues
- **Deprecated function removal**: Partially covered in #28
- **Documentation completeness**: Covered in #19, #32, #35

#### Step 0.3: Update Existing Issues
- **GitHub #21**: Add CRAN-specific checklist items
- **GitHub #24**: Add specific test warning details
- **GitHub #19**: Add roxygen2 documentation requirements

### Phase 1: Issue Consolidation (30 minutes)
**Objective**: Consolidate local issues into existing GitHub issues instead of creating duplicates

#### Step 1.1: Update GitHub #21 (CRAN Readiness)
- Add content from `fix_r_cmd_check_warnings.md`
- Add specific CRAN compliance checklist
- Update labels: add `cran`, `compliance`

#### Step 1.2: Update GitHub #24 (Test Suite)
- Add content from `make_clean_names_df_test_warnings.md`
- Add specific test warning details
- Update labels: add `testing`

#### Step 1.3: Create Missing Issues (if needed)
- **Issue #40**: "Replace 'TBD Open Source' with proper MIT license"
  - Labels: `cran`, `compliance`, `high-priority`
  - Milestone: "CRAN v1.0 Release"

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
- Add all existing audit issues (#15-34)
- Add workflow optimization issue (#39)
- Add new CRAN compliance issues
- Organize by priority and milestone

### Phase 3: Documentation Updates (45 minutes)
**Objective**: Update all documentation to reference GitHub issues instead of local files

#### Step 3.1: Update PROJECT.md
- Remove outdated "Current Status (Updated: July 4, 2025)"
- Add "Current Status (Updated: [Current Date])"
- Replace local issue references with GitHub issue numbers
- Update timeline with realistic dates
- Add "Active Issues" section with links to existing GitHub issues

#### Step 3.2: Update CRAN_CHECKLIST.md
- Mark completed items with ✅
- Link remaining items to specific GitHub issues
- Add "Current Status Summary" section
- Update "Immediate Action Items" with issue numbers

#### Step 3.3: Update AUDIT_LOG.md
- Add current date entry with status update
- Reference existing GitHub issue numbers (#15-34)
- Mark completed audit items
- Update "Current Status" section
- Link to master tracking issue #15

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
- Document which GitHub issues contain the consolidated content

#### Step 4.2: Update README.Rmd
- Remove references to local issue files
- Add section about GitHub issue tracking
- Update any workflow documentation

### Phase 5: Repository Configuration (30 minutes)
**Objective**: Set up GitHub repository for better issue management

#### Step 5.1: Configure Labels
- **Priority**: High, Medium, Low (already exists)
- **Type**: Bug, Enhancement, Documentation, Test (already exists)
- **Status**: Blocked, In Progress, Needs Review
- **Area**: Core, UI, Testing, Documentation
- **CRAN**: Submission, Review, Compliance (new)

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

### Phase 0 Success
- [x] Local issues mapped to existing GitHub issues
- [x] No duplicate issues created
- [x] Existing issues updated with local content

### Phase 1 Success
- [x] GitHub #21 updated with CRAN compliance details
- [x] GitHub #24 updated with test warning details
- [x] Missing issues identified (license covered in #21)
- [x] All issues properly labeled and assigned

### Phase 2 Success (SKIPPED - Not Essential)
- [x] **Decision**: Skip project board setup
- [x] **Rationale**: Existing issue organization with labels and milestones is sufficient
- [x] **Alternative**: Use issue labels and milestones for progress tracking

### Phase 3 Success
- [x] PROJECT.md updated with current status
- [x] CRAN_CHECKLIST.md linked to specific issues
- [x] AUDIT_LOG.md reflects current state
- [x] CONTRIBUTING.md is current

### Phase 4 Success
- [x] Local issue files archived
- [x] README.Rmd updated (no references found)
- [x] No broken references to local files

### Phase 5 Success
- [ ] Labels configured and applied
- [ ] Milestones created
- [ ] Branch protection enabled

### Overall Success
- [ ] Single source of truth for issue tracking
- [ ] Clear path to CRAN submission
- [ ] Improved collaboration workflow
- [ ] Better project visibility
- [ ] No duplicate or conflicting issues

## Risk Mitigation

### Potential Issues
1. **Issue Duplication**: Consolidate instead of creating duplicates
2. **Information Loss**: Preserve all information from local files in existing issues
3. **Workflow Disruption**: Maintain existing workflow during transition
4. **Conflicting Information**: Ensure consistency between local and GitHub content

### Mitigation Strategies
1. **Consolidation**: Update existing issues instead of creating new ones
2. **Backup**: Keep local files in archive with migration notes
3. **Testing**: Verify all links and references work
4. **Gradual Transition**: Update one document at a time
5. **Documentation**: Maintain clear migration notes

## Timeline

### Week 1
- **Day 1**: Phases 0-1 (Issue consolidation)
- **Day 2**: Phase 2 (Project board setup)
- **Day 3**: Phase 3 (Documentation updates)
- **Day 4**: Phase 4 (Cleanup)
- **Day 5**: Phase 5 (Configuration)

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