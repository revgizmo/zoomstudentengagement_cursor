## MCP learnings and recommended stack

This document summarizes recommended Model Context Protocol (MCP) tools to
support this repository's R package workflow and CRAN-readiness goals.

### Goals
- Keep R code executed in R (not shell wrappers)
- Support PR-first, protected-main workflow
- Enable reproducible checks and docs builds
- Provide privacy/FERPA audits as first-class actions

### Recommended MCPs
- Filesystem: manage package files, test data, and artifacts
- Git: create topic branches, conventional commits, tags
- GitHub: open/label issues and PRs, check CI statuses
- Docker: run R CMD check, coverage, pkgdown builds reproducibly
- HTTP/OpenAPI: talk to a local Plumber API for structured dev tasks
- Web/Browser: access CRAN policies and external docs during reviews
- Optional SQLite: query `revdep` and cached results

### Plumber API endpoints (HTTP/OpenAPI)
Expose these as JSON endpoints to keep logic in R:
- style: `styler::style_pkg()`
- lint: `lintr::lint_package()`
- document: `devtools::document()`
- test: `devtools::test()`
- coverage: `covr::package_coverage()`
- check: `devtools::check()`
- build: `devtools::build()`
- privacy_audit: `validate_privacy_compliance()` and related helpers

### Workflow alignment
- Pre-PR validation triggers the endpoints above; artifacts are written under
  `docs/`, `revdep/`, or a temp results directory and summarized in PR checks.
- Topic branches and PRs are managed through Git/GitHub MCPs.
- Docker MCP ensures local runs match CI environments.

### Next steps
1. Add a minimal Plumber service that exposes the endpoints above
2. Add MCP client config for Filesystem, Git, GitHub, Docker, HTTP/OpenAPI, Web
3. Validate CI parity by running checks in Docker locally and in CI
4. Iterate on endpoint responses for structured JSON outputs and artifact paths

