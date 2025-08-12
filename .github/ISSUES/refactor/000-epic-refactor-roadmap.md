---
title: Epic: Refactor roadmap for clean, consistent, and robust package
labels: enhancement, refactor, epic
---

This epic tracks the end-to-end refactor to align the package with best practices: consistent API, stronger tests/CI, privacy guarantees, and improved docs.

Goals
- Consistency: naming, arguments, returns, errors
- Separation: pure transforms vs I/O
- Safety: privacy validation and determinism
- Velocity: tooling, CI gates, and contribution guidance

Scope
- CI right-sizing and caching
- Lint/style standardization
- API contracts and naming conventions
- Schema validators and data model contracts
- Privacy centralization and guarantees
- Testing improvements (fixtures, integration, selective plot snapshots)
- Plot theme and UX consistency
- Documentation (pkgdown, README, vignettes, NEWS)
- Dependency hygiene
- Performance hotspots
- Repository hygiene (large files, ignores)
- Deprecations and migration

Child issues
- # CI: Right-size checks and caching (001)
- # Lint/Style: Tighten `.lintr`, pre-commit hooks, styler (002)
- # API: Contracts, naming, and returns (003)
- # Schema: Validators and expected columns/types (004)
- # Privacy: Centralize PII detection and policy (005)
- # Tests: Fixtures, integration, snapshots (006)
- # Plotting: Theme and `vdiffr` snapshots (007)
- # Docs: `_pkgdown.yml`, README, NEWS (008)
- # Dependencies: Audit and trim (009)
- # Performance: Identify and optimize hotspots (010)
- # Repo hygiene: Data and ignores (011)
- # Deprecations: Plan and lifecycle (012)

Acceptance criteria
- All child issues closed; R CMD check and lintr clean on CI matrix
- Coverage ≥ 85%
- pkgdown site builds and deploys
- Consistent API and privacy checks at boundaries