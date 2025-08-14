---
title: Tests: Fixtures, integration tests, selective plot snapshots, coverage
labels: enhancement, testing
---

Tasks
- Add `tests/testthat/fixtures/` with minimal synthetic datasets
- Write integration tests for end-to-end small pipeline runs
- Add `vdiffr` snapshot tests for a curated subset of plots
- Use `withr` for temp dirs and local options in tests
- Add coverage workflow and badge in README

Acceptance criteria
- Tests run in isolation and do not rely on external state
- Integration tests cover typical pipelines
- Plot snapshots limited to stable outputs and pass on CI
- Coverage reported via CI