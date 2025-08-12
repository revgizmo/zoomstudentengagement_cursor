---
title: Repo hygiene: Test data, ignores, and layout
labels: enhancement, maintenance
---

Tasks
- Move large `.rds` to `tests/testthat/fixtures/` or release assets; ensure `.Rbuildignore` excludes
- Keep minimal example data in `inst/extdata/`
- Ensure `scripts/` remain ignored and reproducible
- Add `tests/testthat/helper-fixtures.R` utilities

Acceptance criteria
- Package tarball excludes large artifacts
- Tests rely on small, deterministic fixtures
- Clear layout for data and scripts