## Spin-offs: CI Templates for R

Scope: Publish opinionated CI workflows for R packages.

Related doc: `docs/planning/SPINOFF_PROJECTS_PLAN.md`

### Subproject
1) GitHub Actions Templates
- Source: `.github/workflows/R-CMD-check.yaml`, `.github/workflows/pages.yml`
- Deliverables: Template workflows; README with integration steps; caching guidance
- Tasks:
  - [ ] Extract workflows; document required permissions
  - [ ] Add pkgdown build notes and matrix examples
  - [ ] Provide troubleshooting section

### Acceptance criteria
- [ ] Templates published and validated on a sample repo
- [ ] Clear instructions to integrate in existing R packages

### Labels
Suggested: `priority:medium`, `area:testing`, `area:documentation`, `enhancement`