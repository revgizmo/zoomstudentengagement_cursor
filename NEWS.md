# zoomstudentengagement News

## 1.0.0 (2025-08-14)
- **CRAN Release**: First stable release ready for CRAN submission
- **Comprehensive Refactoring**: Complete code quality overhaul with schema validation and error handling
- **Privacy Framework**: Enhanced FERPA compliance with privacy-first design and data anonymization
- **Performance Optimization**: Fixed critical performance issues and added benchmarking infrastructure
- **Testing Infrastructure**: Comprehensive test suite with 1322 tests and 88.33% coverage
- **Documentation**: Complete roxygen2 documentation for all 59 exported functions
- **Code Quality**: Consistent styling, error handling, and API design throughout
- **Infrastructure**: Enhanced CI/CD pipeline with comprehensive workflows and validation

### Patch: docs/metadata and parsing hardening (unreleased)
- **Documentation fixes**: Resolved Rd “lost braces” by formatting regex/file patterns with code fencing in roxygen; regenerated man pages.
- **LICENSE**: Kept CRAN-compliant stub in `LICENSE` and added full MIT text in `LICENSE.md` for GitHub readability.
- **Parsing hardening**: Stabilized `load_zoom_recorded_sessions_list()` to support named/unnamed regex capture groups; corrected timezone parsing and session end buffer; added tests.
- **Quiet logs**: Gated verbose diagnostics in `load_zoom_recorded_sessions_list()` behind `options(zoomstudentengagement.verbose)` (default FALSE).
- **Quality gates**: All tests pass; R CMD check: 0 errors / 0 warnings / 0 notes.

## 0.2.0 (Unreleased)
- Project-wide refactor for consistency, safety, and velocity
- CI streamlined with caching and lint/coverage
- Standardized API verbs and argument conventions
- Added schema validators and privacy enforcement at entry points
- Improved tests (fixtures, integration, selective plot snapshots)
- Central plotting theme and doc improvements
- Dependency audit and performance tuning on hotspots
- Introduced deprecation shims and lifecycle guidance

## 0.1.2

- New unified plotting API: `plot_users()` with `facet_by` and `mask_by` options.
- New unified writer: `write_metrics()` for engagement, summary, and session_summary outputs.
- New orchestration: `analyze_transcripts()` for one-call folder→metrics flow.
- New `privacy_audit()` helper to summarize masking coverage.
- Added provenance attributes to `summarize_transcript_metrics()` outputs: `schema_version`, `source_files`, `processing_timestamp`, `privacy_level`.
- Legacy functions now delegate (soft-deprecated):
  - `plot_users_by_metric()`, `plot_users_masked_section_by_metric()` → `plot_users()`
  - `write_engagement_metrics()`, `write_transcripts_summary()`, `write_transcripts_session_summary()` → `write_metrics()`
- README: added 5-minute whole-game example using the unified APIs.
