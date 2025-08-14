---
title: Lint/Style: Tighten `.lintr`, enforce styler, pre-commit hooks
labels: enhancement, tooling
---

Tasks
- Update `.lintr` to use defaults; only disable linters with inline comments and rationale
- Run `styler::style_pkg()` and commit changes
- Add a pre-commit config using `pre-commit` + `R` hooks or a simple `./scripts/pre-commit.sh` to run lintr and styler on staged files
- Add CI lint job to fail on issues

Acceptance criteria
- Lint/styler clean repo-wide
- Pre-commit checks run locally and prevent style regressions
- CI lint job enforces standards