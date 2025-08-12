# Issues to Create (traceability for 0.1.2)

- API: Consolidate plotting functions into `plot_users()` and deprecate legacy plotters
  - Scope: Add unified API, delegate legacy functions, update docs/tests
- API: Consolidate writers into `write_metrics()` and deprecate legacy writers
  - Scope: Add unified writer, delegate legacy functions, update docs/tests
- Privacy: Add `privacy_audit()` helper and document usage
  - Scope: Implement audit, add tests, reference in README/vignettes
- Orchestration: Add `analyze_transcripts()` one-call flow
  - Scope: Implement function, add basic test, reference in README
- Provenance: Attach schema/version/processing/privacylevel attributes to outputs
  - Scope: Implement in `summarize_transcript_metrics()`, consider other outputs later
- Documentation: Update `README.Rmd` quickstart to use unified APIs
  - Scope: Regenerate `README.md`
- Release: Bump version to 0.1.2 and add `NEWS.md`
  - Scope: Update `DESCRIPTION`, write release notes
- Docs: Update vignettes to prefer `plot_users()`/`write_metrics()` (follow-up)
  - Scope: Edit vignettes and examples
- Tests: Add coverage for new functions and deprecation paths
  - Scope: Add tests and ensure CI green