## Spin-offs: Testing & QA Kits (Real-World Testing, Shell QA, Segfault/Memcheck)

Scope: Extract and publish reusable testing/QA infrastructure.

Related doc: `docs/planning/SPINOFF_PROJECTS_PLAN.md`

### Subprojects
1) Real-World Testing Kit (template repo)
- Source: `scripts/real_world_testing/*`
- Deliverables: Standalone template repo; README; setup, validate, run scripts; manual Rmd; security warnings
- Initial tasks:
  - [ ] Copy infra; rename with neutral language
  - [ ] Make scripts package-agnostic (config knobs)
  - [ ] Add example dataset placeholders (no sensitive data)
  - [ ] Publish README with security guidance
2) Shell Script QA Harness
- Source: `scripts/test-shell-scripts.sh`
- Deliverables: Standalone script + docs; optional pre-commit usage
- Tasks:
  - [ ] Extract and generalize checks
  - [ ] Document usage and common patterns
3) R Segfault/Memcheck Harness
- Source: `scripts/valgrind.sh`, `scripts/debug_segfault.sh`
- Deliverables: Cross-platform wrappers + guide; minimal R repro scaffolds
- Tasks:
  - [ ] Normalize output directories/names
  - [ ] Add example minimal R scripts
  - [ ] Document installation and caveats

### Acceptance criteria
- [ ] Three public artifacts ready for reuse (template repo + two toolkits)
- [ ] Docs emphasize secure handling of confidential data
- [ ] Works on Ubuntu-latest; macOS guidance included (lldb)

### Labels
Suggested: `priority:high`, `area:testing`, `enhancement`