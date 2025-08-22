---
name: Task (markdown)
about: Small, well-scoped task with clear acceptance criteria
title: "task: <concise description>"
labels: ["type: chore"]
assignees: []
---

### Background

...

### Scope

- In:
- Out:

### Acceptance Criteria

- [ ] All code styled; no `lintr` warnings
- [ ] Tests added/updated; coverage unchanged or improved
- [ ] `devtools::document()` run; examples runnable
- [ ] CI green; `devtools::check()` 0 errors, 0 warnings
- [ ] User-facing change reflected in `README.Rmd`/vignettes/`NEWS.md`

### Test Plan

- Unit tests in `tests/testthat/`
- Example runs clean in `@examples`
- Edge cases and negative tests included

### Docs Impact

- `README.Rmd`
- Vignette(s)
- Function docs via roxygen2

### Links

Closes #

