---
title: CI: Right-size checks and add caching
labels: enhancement, ci
---

Tasks
- Replace custom R CMD check steps with `r-lib/actions/check-r-package@v2`
- PR CI: ubuntu-latest, R release; cache dependencies
- Nightly/main CI: full matrix (ubuntu, macOS, windows) with R {release, devel, oldrel}
- Add coverage job using `covr` and `codecov/codecov-action@v4` (non-blocking initially)
- Add separate lint job running `lintr::lint_package()`
- Pin actions with `@vX` and minimal permissions

Acceptance criteria
- CI passes on PRs quickly (<10 min)
- Scheduled/main workflow runs full matrix
- Coverage artifacts uploaded; badge added later
- Lint job fails on violations