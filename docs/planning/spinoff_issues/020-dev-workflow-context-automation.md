## Spin-offs: Dev Workflow & Context Automation

Scope: Package and publish developer workflow accelerators and context tooling.

Related doc: `docs/planning/SPINOFF_PROJECTS_PLAN.md`

### Subprojects
1) Pre-PR Validator (R CLI)
- Source: `scripts/pre-pr-validation.R`
- Deliverables: R package/CLI; config; optional GH Action
- Tasks: [ ] modularize checks; [ ] flags; [ ] examples; [ ] CI

2) Context Automation Kit
- Source: `scripts/save-context.sh`, `scripts/context-for-new-chat.sh`, `scripts/context-for-new-chat.R`, docs in `docs/development/*`
- Deliverables: Shell + R scripts; docs; optional PROJECT.md updater
- Tasks: [ ] repo-agnostic defaults; [ ] gh/jq optionality; [ ] templates

3) GH CLI Helpers (Issues/PRs)
- Source: `scripts/create-issue.sh`, `scripts/create-pr.sh`
- Deliverables: Robust wrappers; docs
- Tasks: [ ] label validation; [ ] examples; [ ] error handling

4) CRAN Readiness Kit
- Source: `.Rbuildignore`, `.lintr`, `CRAN_CHECKLIST.md`, `docs/development/CRAN_SUBMISSION.md`
- Deliverables: Template + guide; `usethis`-style snippets

5) AI-Assisted Dev Playbook
- Source: `docs/development/AI_ASSISTED_DEVELOPMENT.md`, `CURSOR_INTEGRATION.md`, `CONTEXT_PROVISION.md`
- Deliverables: Public guide; samples

### Acceptance criteria
- [ ] Pre-PR validator published as R package/CLI
- [ ] Context Kit extracted with minimal config; runs without gh/jq
- [ ] GH helpers documented; safe for varied repos

### Labels
Suggested: `priority:high`, `area:development`, `area:documentation`, `enhancement`