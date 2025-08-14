---
title: Dependencies: Audit, trim, and justify
labels: enhancement, dependencies
---

Tasks
- Review `DESCRIPTION` Imports/Suggests for necessity
- Add `cli` (and optionally `fs`) if UX benefits; avoid adding `checkmate` unless necessary
- Prefer a single grammar (`dplyr`) unless benchmarks justify `data.table`
- Ensure vignettes/tests guard Suggested packages

Acceptance criteria
- `DESCRIPTION` reflects minimal, justified deps
- No unnecessary hard dependencies
- Benchmarks justify any heavy additions