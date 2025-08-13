## Spin-offs: Privacy & Compliance Kits

Scope: Extract privacy-first defaults and FERPA utilities into reusable packages.

Related doc: `docs/planning/SPINOFF_PROJECTS_PLAN.md`

### Subprojects
1) Privacy-First Analytics Core (R)
- Source: `R/ensure_privacy.R`, `R/set_privacy_defaults.R`
- Deliverables: Lightweight R package (e.g., privacyr)
- Tasks:
  - [ ] Abstract options naming; add `init_privacy_defaults()`
  - [ ] Masking helpers (vec/data.frame), column selectors
  - [ ] Examples and tests; vignette
2) FERPA Compliance Toolkit
- Source: `R/ferpa_compliance.R`, `vignettes/ferpa-ethics.Rmd`
- Deliverables: R package + institutional guidance
- Tasks:
  - [ ] API split: validate/anonymize/report
  - [ ] Reporting template and exported functions
  - [ ] Institutional adoption guide

### Acceptance criteria
- [ ] privacyr package skeletons with tests and docs
- [ ] FERPA toolkit with report generation and guidance
- [ ] Clear security/ethics guidance included

### Labels
Suggested: `priority:medium`, `area:core`, `enhancement`, `area:documentation`